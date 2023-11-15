open! Core
open! Import

type t

val create : Rpc.Connection.t -> t
val get_games : t -> Get_games.Query.t -> Get_games.Response.t Ui_effect.t
