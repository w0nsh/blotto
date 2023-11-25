open! Core
open Import

let component =
  let open Bonsai.Let_syntax in
  match%sub Path.route with
  | Game game_id -> Game_view.component ~game_id
  | Index -> Index_view.component
  | Register_user -> User_registration.component
  | Scoreboard game_id -> Scoreboard_view.component ~game_id
  | Not_found -> Not_found.component
;;
