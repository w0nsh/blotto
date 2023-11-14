open! Core
open Async
open Blotto_kernel_lib

let get_games_rpc_command =
  Command.async_or_error
    ~summary:"Get games rpc"
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
       match response with
       | Error error -> print_endline [%string "Error: %{Error.to_string_hum error}."]
       | Ok response -> print_s [%sexp (response : Game.t Game_id.Table.t)])
;;

let command =
  Command.group ~summary:"Blotto backend CLI" [ "get-games", get_games_rpc_command ]
;;
