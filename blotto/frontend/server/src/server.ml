open! Core
open! Async
open Import

let current_etag = "abeb4dbc1362d522452335a71286c21d" (* change after any change *)

let initialize_connection _initiated_from _addr _inet connection =
  { Connection_state.connection }
;;

let respond_string ?flush ?headers ?status ~content_type s =
  let headers = Cohttp.Header.add_opt headers "Content-Type" content_type in
  let headers = Cohttp.Header.add headers "ETag" current_etag in
  Cohttp_async.Server.respond_string ?flush ~headers ?status s
;;

let respond_not_modified = Cohttp_async.Server.respond (Cohttp.Code.status_of_code 304)

let respond_by_uri uri =
  match Route.of_uri uri with
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

let handler ~body:_ _inet req =
  let headers = Cohttp.Request.headers req in
  match Cohttp.Header.get headers "If-None-Match" with
  | Some etag when String.equal etag current_etag -> respond_not_modified
  | Some _ | None ->
    let uri = Cohttp.Request.uri req in
    respond_by_uri uri
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
