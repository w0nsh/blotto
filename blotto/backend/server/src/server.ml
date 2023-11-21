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

let update_game_implementation
  ~state
  ~rpc_tag
  rpc_state
  { Update_game.Query.id; start_date; end_date; allowed_users; rule }
  =
  log_rpc rpc_state rpc_tag;
  let%bind.Deferred.Or_error () =
    State.update_game ?start_date ?end_date ?allowed_users ?rule state id |> return
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
    ]
  in
  Rpc.Implementations.create_exn ~implementations ~on_unknown_rpc:(`Call unkown_rpc)
;;

let run (config : Config.t) =
  let where_to_listen = Tcp.Where_to_listen.of_port config.port in
  let state = State.init () in
  Log.Global.info_s
    [%message "Spinning up server" (where_to_listen : Tcp.Where_to_listen.inet)];
  let%bind server =
    Rpc.Connection.serve
      ~implementations:(implementations state)
      ~initial_connection_state:(fun address connection -> address, connection)
      ~where_to_listen
      ()
  in
  ignore server;
  Deferred.never ()
;;
