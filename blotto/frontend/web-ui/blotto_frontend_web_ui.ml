open! Core
open! Import

let attempt_to_connect () =
  log_s [%message "Attempting to connect to the backend server"];
  let%map result = Rpc.Connection.client () in
  let print_result () =
    match result with
    | Ok _ -> log_s [%message "Connected"]
    | Error err -> log_s [%message "Connection failed " (err : Error.t)]
  in
  print_result ();
  result
;;

let run () =
  Async_js.init ();
  let server_connection =
    Persistent_connection.Rpc.create
      ~server_name:"server connection"
      ~retry_delay:(fun () -> Time_ns.Span.of_sec 2.0)
      ~connect:attempt_to_connect
      ~address:(module Unit)
      (fun () -> Deferred.Or_error.return ())
  in
  let api = Api.create server_connection in
  let app = App.component ~api in
  let theme =
    Kado.theme
      ~style:Kado.Style.Light
      ~set_min_height_to_100vh:()
      ~version:Kado.Version.Bleeding
      ()
  in
  let themed_app = View.Theme.set_for_app (Value.return theme) app in
  let () = Bonsai_web.Start.start themed_app in
  (* don't_wait_for (some_rpc ~conn); *)
  return ()
;;

let () = don't_wait_for (run ())
