open! Core
open! Async
open Import

let run_rpc
  (type response_type query_type)
  (module M : Rpc_intf.S
    with type Response.t = response_type
     and type Query.t = query_type)
  ~backend_connection
  =
  let f ~rpc_tag:_ _connection_state query =
    let%bind conn = Persistent_connection.Rpc.connected backend_connection in
    (* move this to other module and add timeout *)
    M.dispatch conn query
  in
  M.implement f
;;

let get_games = run_rpc (module Get_games)

let implementations ~backend_connection =
  Rpc.Implementations.create_exn
    ~implementations:[ get_games ~backend_connection ]
    ~on_unknown_rpc:`Continue
;;
