open! Core
open Async
open Blotto_backend_protocol_lib

let get_games_rpc ~where_to_connect ~query =
  Rpc.Connection.with_client where_to_connect (fun conn -> Get_games.dispatch conn query)
  >>| Result.map_error ~f:Error.of_exn
  >>| Or_error.join
;;

let create_game_rpc ~where_to_connect ~query =
  Rpc.Connection.with_client where_to_connect (fun conn ->
    Create_game.dispatch conn query)
  >>| Result.map_error ~f:Error.of_exn
  >>| Or_error.join
;;

let update_game_rpc ~where_to_connect ~query =
  Rpc.Connection.with_client where_to_connect (fun conn ->
    Update_game.dispatch conn query)
  >>| Result.map_error ~f:Error.of_exn
  >>| Or_error.join
;;

let list_users_rpc ~where_to_connect ~query =
  Rpc.Connection.with_client where_to_connect (fun conn -> List_users.dispatch conn query)
  >>| Result.map_error ~f:Error.of_exn
  >>| Or_error.join
;;

let remove_game_rpc ~where_to_connect ~query =
  Rpc.Connection.with_client where_to_connect (fun conn ->
    Remove_game.dispatch conn query)
  >>| Result.map_error ~f:Error.of_exn
  >>| Or_error.join
;;

let register_user_rpc ~where_to_connect ~query =
  Rpc.Connection.with_client where_to_connect (fun conn ->
    Register_user.dispatch conn query)
  >>| Result.map_error ~f:Error.of_exn
  >>| Or_error.join
;;

let get_scoreboard_rpc ~where_to_connect ~query =
  Rpc.Connection.with_client where_to_connect (fun conn ->
    Get_scoreboard.dispatch conn query)
  >>| Result.map_error ~f:Error.of_exn
  >>| Or_error.join
;;

let recalculate_scoreboard_rpc ~where_to_connect ~query =
  Rpc.Connection.with_client where_to_connect (fun conn ->
    Recalculate_scoreboard.dispatch conn query)
  >>| Result.map_error ~f:Error.of_exn
  >>| Or_error.join
;;
