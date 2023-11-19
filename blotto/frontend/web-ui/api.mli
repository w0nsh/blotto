open! Core
open! Import

type t

val create : Persistent_connection.Rpc.t -> t
val get_games : t -> Get_games.Query.t -> Get_games.Response.t Or_error.t Ui_effect.t
