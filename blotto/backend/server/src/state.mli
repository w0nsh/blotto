open! Core
open Async
open Import

type t

val init : ?seed:int -> unit -> t
val load_data : t -> Filename.t -> unit Deferred.Or_error.t
val save_data : t -> Filename.t -> unit Deferred.Or_error.t
val create_user : t -> User_data.t -> User_token.t Or_error.t
val create_game : t -> Game_id.t -> Game.t -> unit Or_error.t

val update_game
  :  ?start_date:Time_ns.Alternate_sexp.t
  -> ?end_date:Time_ns.Alternate_sexp.t
  -> ?allowed_users:Game.Allowed_users.t
  -> t
  -> Game_id.t
  -> unit Or_error.t

val add_entry
  :  t
  -> token:User_token.t
  -> army:Army.t
  -> game_id:Game_id.t
  -> unit Or_error.t
