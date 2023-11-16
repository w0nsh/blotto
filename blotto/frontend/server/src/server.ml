open! Core
open! Async

let initialize_connection _initiated_from _addr _inet connection =
  { Connection_state.connection }
;;

let respond_string ?flush ?headers ?status ~content_type s =
  let headers = Cohttp.Header.add_opt headers "Content-Type" content_type in
  Cohttp_async.Server.respond_string ?flush ~headers ?status s
;;

let handler ~body:_ _inet req =
  let path = Uri.path (Cohttp.Request.uri req) in
  match path with
  | "" | "/" | "/index.html" ->
    respond_string ~content_type:"text/html" Embedded_files.index_dot_html
  | "/script.js" ->
    respond_string
      ~content_type:"application/javascript"
      Embedded_files.blotto_frontend_web_ui_dot_bc_dot_js
  | "/style.css" -> respond_string ~content_type:"text/css" Embedded_files.style_dot_css
  | _ ->
    respond_string
      ~content_type:"text/html"
      ~status:`Not_found
      Embedded_files.not_found_dot_html
;;

let run ~config:{ Config.port; backend_address } =
  let backend_address = Tcp.Where_to_connect.of_host_and_port backend_address in
  let%map result =
    Rpc.Connection.with_client backend_address (fun backend_connection ->
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
      Cohttp_async.Server.close_finished server)
  in
  match result with
  | Ok () -> ()
  | Error err ->
    Log.Global.error_s [%message "Connection to the backend server failed " (err : exn)]
;;
