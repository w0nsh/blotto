open! Core
open! Async

let initialize_connection _initiated_from _addr _inet connection =
  { Connection_state.connection }
;;

let respond_string ~content_type ?flush ?headers ?status s =
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
      Log.Global.info "Serving http://%s:%d/\n%!" hostname port;
      Cohttp_async.Server.close_finished server)
  in
  match result with
  | Error err ->
    Log.Global.error_s [%message "Connection to the backend server failed " (err : exn)]
  | Ok () -> ()
;;

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
       run ~config:{ port; backend_address = Host_and_port.of_string backend_address })
;;
