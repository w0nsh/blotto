open! Core
open Async

let command =
  Command.async_or_error
    ~summary:"Run Hello World RPC server"
    (let%map_open.Command () =
       Log_extended.Command.setup_via_params
         ~log_to_console_by_default:(Stderr Color)
         ~log_to_syslog_by_default:false
         ()
     and port = flag "port" (optional int) ~doc:"INT port to listen on"
     and persist_state =
       flag "persist-state" no_arg ~doc:"If set then persist the server state"
     and state_file =
       flag "state-file" (optional Filename_unix.arg_type) ~doc:"FILENAME state file"
     in
     Log.Global.set_output (Log_extended.Global.get_output ());
     fun () ->
       let port = Option.value ~default:8080 port in
       let config = { Config.port; persist_state; state_file } in
       Server.run config)
;;
