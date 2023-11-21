open! Core
open! Async
open Import

let implement_rpc
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

let implementations ~backend_connection =
  Rpc.Implementations.create_exn
    ~implementations:
      [ implement_rpc (module Create_game) ~backend_connection
      ; implement_rpc (module Get_game) ~backend_connection
      ; implement_rpc (module Get_games) ~backend_connection
      ; implement_rpc (module Get_scoreboard) ~backend_connection
      ; implement_rpc (module List_users) ~backend_connection
      ; implement_rpc (module Register_user) ~backend_connection
      ; implement_rpc (module Remove_game) ~backend_connection
      ; implement_rpc (module Submit_entry) ~backend_connection
      ; implement_rpc (module Update_game) ~backend_connection
      ]
    ~on_unknown_rpc:`Continue
;;
