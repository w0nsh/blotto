open Core
open Async

let listen ~port =
  let%bind server = Server.create ~port in
  Log.Global.info_s [%message "Server running at port" (port : int)];
  let%map () = Cohttp_async.Server.close_finished server in
  Log.Global.info_s [%message "Server shutting down"];
  ()

let command =
  let open Command.Let_syntax in
  Command.async ~summary:"Start server"
    ~readme:(fun () -> "Starts server at a given port")
    (let%map_open port = anon ("port" %: int) in
     fun () -> listen ~port)

let () = Command_unix.run ~version:"1.0" ~build_info:"RWO" command
