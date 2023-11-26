open! Core
open Async
open Import

let load_token_list filename =
  let%bind.Deferred.Or_error tokens =
    Deferred.Or_error.try_with (fun () -> Reader.file_lines filename)
  in
  List.map tokens ~f:User_token.create |> Or_error.all |> return
;;

let get_allowed_users filename =
  match filename with
  | None -> Deferred.Or_error.return Game.Allowed_users.Any
  | Some filename ->
    let%map.Deferred.Or_error tokens = load_token_list filename in
    Game.Allowed_users.Users (User_token.Set.of_list tokens)
;;

let create_game_rpc_command =
  Command.async_or_error
    ~summary:"Create new game"
    (let%map_open.Command host =
       flag
         "host"
         (optional_with_default "127.0.0.1" string)
         ~doc:"STRING Host to connect to"
     and port = flag "port" (optional_with_default 8080 int) ~doc:"INT Port to connect to"
     and game_id = flag "game-id" (required Game_id.arg_type) ~doc:"STRING Game id"
     and name = flag "name" (required string) ~doc:"STRING name"
     and description = flag "description" (required string) ~doc:"STRING description"
     and allowed_users =
       flag
         "allowed-users"
         (optional Filename_unix.arg_type)
         ~doc:"FILENAME file with allowed tokens for this game"
     and start_date =
       flag
         "start-date"
         (optional_with_default (Time_ns_unix.now ()) Time_ns_unix.arg_type)
         ~doc:"DATE start date"
     and end_date = flag "end-date" (required Time_ns_unix.arg_type) ~doc:"DATE end date"
     and rule = flag "rule" (required Rule.arg_type) ~doc:"RULE game rule" in
     fun () ->
       let where_to_connect =
         Tcp.Where_to_connect.of_host_and_port (Host_and_port.create ~host ~port)
       in
       let%bind.Deferred.Or_error allowed_users = get_allowed_users allowed_users in
       let%bind.Deferred.Or_error game =
         Game.create
           ~name
           ~description
           ~start_date:(Time_ns_fix.of_time_ns start_date)
           ~end_date:(Time_ns_fix.of_time_ns end_date)
           ~allowed_users
           ~rule
         |> return
       in
       let%map.Deferred.Or_error response =
         Cli.create_game_rpc ~where_to_connect ~query:{ game_id; game }
       in
       print_s [%sexp (response : unit)])
;;

let update_game_rpc_command =
  Command.async_or_error
    ~summary:"Create new game"
    (let%map_open.Command host =
       flag
         "host"
         (optional_with_default "127.0.0.1" string)
         ~doc:"STRING Host to connect to"
     and port = flag "port" (optional_with_default 8080 int) ~doc:"INT Port to connect to"
     and game_id = flag "game-id" (required Game_id.arg_type) ~doc:"STRING Game id"
     and name = flag "name" (optional string) ~doc:"STRING name"
     and allowed_users =
       flag
         "allowed-users"
         (optional Filename_unix.arg_type)
         ~doc:"FILENAME allowed user tokens"
     and description = flag "description" (optional string) ~doc:"STRING description"
     and start_date =
       flag "start-date" (optional Time_ns_unix.arg_type) ~doc:"DATE start date"
     and end_date = flag "end-date" (optional Time_ns_unix.arg_type) ~doc:"DATE end date"
     and rule = flag "rule" (optional Rule.arg_type) ~doc:"RULE game rule" in
     fun () ->
       let where_to_connect =
         Tcp.Where_to_connect.of_host_and_port (Host_and_port.create ~host ~port)
       in
       let%bind.Deferred.Or_error allowed_users =
         match allowed_users with
         | None -> Deferred.Or_error.return None
         | Some filename ->
           let%map.Deferred.Or_error tokens = load_token_list filename in
           Some (Game.Allowed_users.Users (User_token.Set.of_list tokens))
       in
       let query =
         { Update_game.Query.id = game_id
         ; name
         ; description
         ; start_date = Option.map ~f:Time_ns_fix.of_time_ns start_date
         ; end_date = Option.map ~f:Time_ns_fix.of_time_ns end_date
         ; rule
         ; allowed_users
         }
       in
       let%bind.Deferred response = Cli.update_game_rpc ~where_to_connect ~query in
       (match response with
        | Error error -> print_endline [%string "Error: %{Error.to_string_hum error}."]
        | Ok response -> print_s [%sexp (response : Update_game.Response.t)]);
       Deferred.Or_error.ok_unit)
;;

let get_games_rpc_command =
  Command.async_or_error
    ~summary:"List games"
    (let%map_open.Command host =
       flag
         "host"
         (optional_with_default "127.0.0.1" string)
         ~doc:"STRING Host to connect to"
     and port =
       flag "port" (optional_with_default 8080 int) ~doc:"INT Port to connect to"
     in
     fun () ->
       let where_to_connect =
         Tcp.Where_to_connect.of_host_and_port (Host_and_port.create ~host ~port)
       in
       let%map.Deferred.Or_error response =
         Cli.get_games_rpc ~where_to_connect ~query:()
       in
       print_s [%sexp (response : Game_info.t Game_id.Table.t)])
;;

let remove_game_rpc_command =
  Command.async_or_error
    ~summary:"Remove game"
    (let%map_open.Command host =
       flag
         "host"
         (optional_with_default "127.0.0.1" string)
         ~doc:"STRING Host to connect to"
     and port = flag "port" (optional_with_default 8080 int) ~doc:"INT Port to connect to"
     and game_id = anon ("game_id" %: Game_id.arg_type) in
     fun () ->
       let where_to_connect =
         Tcp.Where_to_connect.of_host_and_port (Host_and_port.create ~host ~port)
       in
       Cli.remove_game_rpc ~where_to_connect ~query:game_id)
;;

let get_scoreboard_rpc_command =
  Command.async_or_error
    ~summary:"Get scoreboard"
    (let%map_open.Command host =
       flag
         "host"
         (optional_with_default "127.0.0.1" string)
         ~doc:"STRING Host to connect to"
     and port = flag "port" (optional_with_default 8080 int) ~doc:"INT Port to connect to"
     and game_id = anon ("game_id" %: Game_id.arg_type) in
     fun () ->
       let where_to_connect =
         Tcp.Where_to_connect.of_host_and_port (Host_and_port.create ~host ~port)
       in
       let%map.Deferred.Or_error scoreboard =
         Cli.get_scoreboard_rpc ~where_to_connect ~query:game_id
       in
       print_s [%sexp (scoreboard : Scoreboard.t)])
;;

let list_users_rpc_command =
  Command.async_or_error
    ~summary:"List users"
    (let%map_open.Command host =
       flag
         "host"
         (optional_with_default "127.0.0.1" string)
         ~doc:"STRING Host to connect to"
     and port =
       flag "port" (optional_with_default 8080 int) ~doc:"INT Port to connect to"
     in
     fun () ->
       let where_to_connect =
         Tcp.Where_to_connect.of_host_and_port (Host_and_port.create ~host ~port)
       in
       let%map.Deferred.Or_error response =
         Cli.list_users_rpc ~where_to_connect ~query:()
       in
       print_s [%sexp (response : User_info.t User_token.Table.t)])
;;

let register_user_rpc_command =
  Command.async_or_error
    ~summary:"Register user"
    (let%map_open.Command host =
       flag
         "host"
         (optional_with_default "127.0.0.1" string)
         ~doc:"STRING Host to connect to"
     and port = flag "port" (optional_with_default 8080 int) ~doc:"INT Port to connect to"
     and name = anon ("name" %: string)
     and email = anon ("email" %: string) in
     fun () ->
       let where_to_connect =
         Tcp.Where_to_connect.of_host_and_port (Host_and_port.create ~host ~port)
       in
       let%bind.Deferred.Or_error user_data = User_data.create ~name ~email |> return in
       let%map.Deferred.Or_error response =
         Cli.register_user_rpc ~where_to_connect ~query:user_data
       in
       print_s [%sexp (response : User_token.t)])
;;

let command =
  Command.group
    ~summary:"Blotto backend CLI"
    [ "get-games", get_games_rpc_command
    ; "create-game", create_game_rpc_command
    ; "update-game", update_game_rpc_command
    ; "list-users", list_users_rpc_command
    ; "remove-game", remove_game_rpc_command
    ; "register-user", register_user_rpc_command
    ; "get-scoreboard", get_scoreboard_rpc_command
    ]
;;
