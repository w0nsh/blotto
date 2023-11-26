open! Core
open Async
open Blotto_backend_protocol_lib

val get_games_rpc
  :  where_to_connect:[< Socket.Address.t ] Tcp.Where_to_connect.t
  -> query:Get_games.Query.t
  -> Get_games.Response.t Deferred.Or_error.t

val create_game_rpc
  :  where_to_connect:[< Socket.Address.t ] Tcp.Where_to_connect.t
  -> query:Create_game.Query.t
  -> Create_game.Response.t Deferred.Or_error.t

val update_game_rpc
  :  where_to_connect:[< Socket.Address.t ] Tcp.Where_to_connect.t
  -> query:Update_game.Query.t
  -> Update_game.Response.t Deferred.Or_error.t

val list_users_rpc
  :  where_to_connect:[< Socket.Address.t ] Tcp.Where_to_connect.t
  -> query:List_users.Query.t
  -> List_users.Response.t Deferred.Or_error.t

val remove_game_rpc
  :  where_to_connect:[< Socket.Address.t ] Tcp.Where_to_connect.t
  -> query:Remove_game.Query.t
  -> Remove_game.Response.t Deferred.Or_error.t

val register_user_rpc
  :  where_to_connect:[< Socket.Address.t ] Tcp.Where_to_connect.t
  -> query:Register_user.Query.t
  -> Register_user.Response.t Deferred.Or_error.t

val get_scoreboard_rpc
  :  where_to_connect:[< Socket.Address.t ] Tcp.Where_to_connect.t
  -> query:Get_scoreboard.Query.t
  -> Get_scoreboard.Response.t Deferred.Or_error.t

val recalculate_scoreboard_rpc
  :  where_to_connect:[< Socket.Address.t ] Tcp.Where_to_connect.t
  -> query:Recalculate_scoreboard.Query.t
  -> Recalculate_scoreboard.Response.t Deferred.Or_error.t
