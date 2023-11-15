open Core
open Async

let listen ~port =
  let%bind server = Server.create ~port in
  Log.Global.info_s [%message "Server running at port" (port : int)];
  let%map () = Cohttp_async.Server.close_finished server in
  Log.Global.info_s [%message "Server shutting down"];
  ()
;;

let command =
  let open Command.Let_syntax in
  Command.async
    ~summary:"Start server"
    ~readme:(fun () -> "Starts server at a given port")
    (let%map_open () =
       Log_extended.Command.setup_via_params
         ~log_to_console_by_default:(Stderr Color)
         ~log_to_syslog_by_default:false
         ()
     and port = anon ("port" %: int) in
     fun () -> listen ~port)
;;
