open Core
open Async

let command =
  let open Command.Let_syntax in
  Command.async
    ~summary:"Start blotto http server"
    ~readme:(fun () -> "Starts server at a given port")
    (let%map_open () =
       Log_extended.Command.setup_via_params
         ~log_to_console_by_default:(Stderr Color)
         ~log_to_syslog_by_default:false
         ()
     and port = anon ("port" %: int)
     and backend_address = anon ("backend_address" %: string) in
     fun () ->
       Server.run
         ~config:{ port; backend_address = Host_and_port.of_string backend_address })
;;
