open! Core
open Async
open Blotto_backend_rpc_lib

let get_games_rpc ~where_to_connect ~query =
  Rpc.Connection.with_client where_to_connect (fun conn -> Get_games.dispatch conn query)
  >>| Result.map_error ~f:Error.of_exn
  >>| Or_error.join
;;
