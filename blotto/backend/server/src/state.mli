open! Core
open Async
open Import

type t

val init : ?seed:int -> unit -> t
val load_data : t -> Filename.t -> unit Deferred.Or_error.t
val save_data : t -> Filename.t -> unit Deferred.Or_error.t
val create_user : t -> User_data.t -> User_token.t Or_error.t
val create_game : t -> Game_id.t -> Game.t -> unit Or_error.t
val get_game_info : t -> Game_id.t -> Game_info.t Or_error.t
val get_game_infos : t -> Game_info.t Game_id.Table.t
val get_game : t -> Game_id.t -> Game.t Or_error.t
val get_games : t -> Game.t Game_id.Table.t
val get_scoreboard : t -> Game_id.t -> Scoreboard.t Or_error.t
val remove_game : t -> Game_id.t -> unit Or_error.t
val list_users : t -> User_info.t User_token.Table.t

val update_game
  :  ?name:string
  -> ?description:string
  -> ?start_date:Time_ns.Alternate_sexp.t
  -> ?end_date:Time_ns.Alternate_sexp.t
  -> ?allowed_users:Game.Allowed_users.t
  -> ?rule:Rule.t
  -> t
  -> Game_id.t
  -> unit Or_error.t

val add_entry
  :  t
  -> token:User_token.t
  -> army:Army.t
  -> game_id:Game_id.t
  -> unit Or_error.t
