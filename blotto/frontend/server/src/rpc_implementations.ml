open! Core
open! Async
open Import

let get_games ~backend_connection =
  let f ~rpc_tag:_ _connection_state () =
    let%bind conn = Persistent_connection.Rpc.connected backend_connection in
    Get_games.dispatch conn () >>| Or_error.ok_exn
  in
  Get_games.implement f
;;

let implementations ~backend_connection =
  Rpc.Implementations.create_exn
    ~implementations:[ get_games ~backend_connection ]
    ~on_unknown_rpc:`Continue
;;
