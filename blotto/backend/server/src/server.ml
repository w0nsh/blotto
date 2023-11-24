open! Core
open Async
open Import

module Rpc_state = struct
  type t = Socket.Address.Inet.t * Rpc.Connection.t [@@deriving sexp_of]
end

let log_rpc rpc_state rpc_tag =
  Log.Global.debug_s [%message "New Rpc" (rpc_state : Rpc_state.t) rpc_tag]
;;

let unkown_rpc rpc_state ~rpc_tag ~version =
  Log.Global.error_s
    [%message "Unkown rpc" (rpc_state : Rpc_state.t) rpc_tag (version : int)];
  `Close_connection
;;

let get_game_implementation ~state ~rpc_tag rpc_state (game_id : Get_game.Query.t) =
  log_rpc rpc_state rpc_tag;
  State.get_game_info state game_id |> return
;;

let get_games_implementation ~state ~rpc_tag rpc_state (() : Get_games.Query.t) =
  log_rpc rpc_state rpc_tag;
  Deferred.Or_error.return (State.get_game_infos state)
;;

let create_game_implrementation ~state ~rpc_tag rpc_state (query : Create_game.Query.t) =
  log_rpc rpc_state rpc_tag;
  State.create_game state query.game_id query.game |> return
;;

let register_user_implementation ~state ~rpc_tag rpc_state (query : Register_user.Query.t)
  =
  log_rpc rpc_state rpc_tag;
  State.create_user state query |> return
;;

let get_scoreboard_implementation
  ~state
  ~rpc_tag
  rpc_state
  (query : Get_scoreboard.Query.t)
  =
  log_rpc rpc_state rpc_tag;
  State.get_scoreboard state query |> return
;;

let get_ui_scoreboard_implementation
  ~state
  ~rpc_tag
  rpc_state
  (query : Get_ui_scoreboard.Query.t)
  =
  log_rpc rpc_state rpc_tag;
  let%bind.Deferred.Or_error game = State.get_game state query |> return in
  if Time_ns.(now () < game.info.end_date)
  then
    Or_error.error_s
      [%message
        "Cannot show scoreboard before end of a game."
          (game.info.end_date : Time_ns.Alternate_sexp.t)]
    |> return
  else (
    let%bind.Deferred.Or_error scoreboard = State.get_scoreboard state query |> return in
    let entries = Scoreboard.to_list scoreboard in
    List.map entries ~f:(fun (token, army, score) ->
      let%map.Or_error user_info = State.get_user_info state token in
      { Ui_entry.army; score; user_data = user_info.data })
    |> Or_error.all
    |> return)
;;

let update_game_implementation
  ~state
  ~rpc_tag
  rpc_state
  { Update_game.Query.id; name; description; start_date; end_date; allowed_users; rule }
  =
  log_rpc rpc_state rpc_tag;
  let%bind.Deferred.Or_error () =
    State.update_game
      ?name
      ?description
      ?start_date
      ?end_date
      ?allowed_users
      ?rule
      state
      id
    |> return
  in
  let%bind.Deferred.Or_error game = State.get_game state id |> return in
  Deferred.Or_error.return { Update_game.Response.Result.id; game }
;;

let remove_game_implementation ~state ~rpc_tag rpc_state game_id =
  log_rpc rpc_state rpc_tag;
  State.remove_game state game_id |> return
;;

let list_users_implementation ~state ~rpc_tag rpc_state () =
  log_rpc rpc_state rpc_tag;
  State.list_users state |> Deferred.Or_error.return
;;

let submit_entry_implementation
  ~state
  ~rpc_tag
  rpc_state
  { Submit_entry.Query.game_id; token; army }
  =
  log_rpc rpc_state rpc_tag;
  State.add_entry state ~token ~army ~game_id |> return
;;

(* TODO: Get scoreboard. *)
let implementations state =
  let implementations =
    [ Get_game.implement (get_game_implementation ~state)
    ; Get_games.implement (get_games_implementation ~state)
    ; Create_game.implement (create_game_implrementation ~state)
    ; Register_user.implement (register_user_implementation ~state)
    ; Update_game.implement (update_game_implementation ~state)
    ; Remove_game.implement (remove_game_implementation ~state)
    ; List_users.implement (list_users_implementation ~state)
    ; Submit_entry.implement (submit_entry_implementation ~state)
    ; Get_scoreboard.implement (get_scoreboard_implementation ~state)
    ; Get_ui_scoreboard.implement (get_ui_scoreboard_implementation ~state)
    ]
  in
  Rpc.Implementations.create_exn ~implementations ~on_unknown_rpc:(`Call unkown_rpc)
;;

let init_state filename =
  let state = State.init () in
  let%map.Deferred.Or_error () =
    match filename with
    | None -> Deferred.Or_error.ok_unit
    | Some filename ->
      Log.Global.info_s
        [%message "Loading initial state from file" (filename : Filename.t)];
      State.load_data state filename
  in
  state
;;

let run (config : Config.t) =
  let where_to_listen = Tcp.Where_to_listen.of_port config.port in
  Log.Global.info_s
    [%message
      "Spinning up server"
        (config : Config.t)
        (where_to_listen : Tcp.Where_to_listen.inet)];
  let%bind state =
    match%map init_state config.state_file with
    | Error error ->
      Log.Global.error_s
        [%message
          "Cannot load server state from file (this is expected on the first run of the \
           server)"
            (error : Error.t)
            (config : Config.t)];
      State.init ()
    | Ok state -> state
  in
  let%bind server =
    Rpc.Connection.serve
      ~implementations:(implementations state)
      ~initial_connection_state:(fun address connection -> address, connection)
      ~where_to_listen
      ()
  in
  ignore server;
  let%bind.Deferred.Or_error () =
    match config.persist_state with
    | false -> Deferred.Or_error.ok_unit
    | true ->
      (match config.state_file with
       | None ->
         Deferred.Or_error.error_s
           [%message "Cannot persist state if no state file given." (config : Config.t)]
       | Some state_file ->
         Deferred.forever () (fun () ->
           let%bind () = Async.after (Time_float.Span.of_sec 10.) in
           Log.Global.debug_s
             [%message "Persisting server state." (state_file : Filename.t)];
           State.save_data state state_file >>| Or_error.ok_exn);
         Deferred.Or_error.ok_unit)
  in
  Deferred.never ()
;;
