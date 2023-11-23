open! Core

type t =
  | Game
  | Index
  | Scoreboard
  | User
  | Not_found

let of_string str =
  match Utils.normalize_path str with
  | "" -> Index
  | "/game" -> Game
  | "/scoreboard" -> Scoreboard
  | "/user" -> User
  | _ -> Not_found
;;
