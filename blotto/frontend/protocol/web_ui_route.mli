open! Core
open Import

type t =
  | Game of Game_id.t option
  | Index
  | Register_user
  | Scoreboard of Game_id.t option
  | Not_found

val of_uri : Uri.t -> t
val set_path_and_query : uri:Uri.t -> t -> Uri.t
