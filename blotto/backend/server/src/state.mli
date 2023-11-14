open! Core
open Async
open Blotto_kernel_lib

type t [@@deriving sexp]

val init : unit -> t Deferred.Or_error.t
val load : Filename.t -> t Deferred.Or_error.t
val save : t -> Filename.t -> unit Deferred.Or_error.t
val create_user : t -> User_data.t -> User_token.t Or_error.t
val create_game : t -> Game.t -> Game_id.t Or_error.t

val update_game
  :  ?start_date:Time_ns.Alternate_sexp.t
  -> t
  -> Game_id.t
  -> unit Or_error.t
