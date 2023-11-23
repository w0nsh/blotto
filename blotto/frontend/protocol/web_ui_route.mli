type t =
  | Game
  | Index
  | Scoreboard
  | User
  | Not_found

val of_string : string -> t
