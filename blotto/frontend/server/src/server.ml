open! Core
open! Async
open Import

let initialize_connection _initiated_from _addr _inet connection =
  { Connection_state.connection }
;;

let respond_string ?flush ?headers ?status ~content_type s =
  let headers = Cohttp.Header.add_opt headers "Content-Type" content_type in
  Cohttp_async.Server.respond_string ?flush ~headers ?status s
;;

let handler ~body:_ _inet req =
  let path = Uri.path (Cohttp.Request.uri req) in
  match Route.of_string path with
  | Script ->
    respond_string
      ~content_type:"application/javascript"
      Embedded_files.blotto_frontend_web_ui_dot_bc_dot_js
  | Style -> respond_string ~content_type:"text/css" Embedded_files.style_dot_css
  | Web_ui _ -> respond_string ~content_type:"text/html" Embedded_files.index_dot_html
  | Not_found ->
    respond_string
      ~content_type:"text/html"
      ~status:`Not_found
      Embedded_files.not_found_dot_html
;;

let attempt_to_connect host_and_port =
  Log.Global.info_s [%message "Attempting to connect to the backend server"];
  let address = Tcp.Where_to_connect.of_host_and_port host_and_port in
  let%map result = Rpc.Connection.client address >>| Or_error.of_exn_result in
  let print_result () =
    match result with
    | Ok _ -> Log.Global.info_s [%message "Connected"]
    | Error err -> Log.Global.error_s [%message "Connection failed " (err : Error.t)]
  in
  print_result ();
  result
;;

let run ~config:{ Config.port; backend_address } =
  let backend_connection =
    Persistent_connection.Rpc.create
      ~server_name:"backend connection"
      ~retry_delay:(fun () -> Time_ns.Span.of_sec 5.0)
      ~connect:attempt_to_connect
      ~address:(module Host_and_port) (* TODO: use [Tcp.Where_to_connect] here instead *)
      (fun () -> Deferred.Or_error.return backend_address)
  in
  let hostname = Unix.gethostname () in
  let%bind server =
    let http_handler () = handler in
    Rpc_websocket.Rpc.serve
      ~on_handler_error:`Ignore
      ~mode:`TCP
      ~where_to_listen:(Tcp.Where_to_listen.of_port port)
      ~http_handler
      ~implementations:(Rpc_implementations.implementations ~backend_connection)
      ~initial_connection_state:initialize_connection
      ()
  in
  Log.Global.info_s [%message "Serving at " (hostname : string) (port : int)];
  Cohttp_async.Server.close_finished server
;;
