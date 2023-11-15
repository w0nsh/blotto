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
