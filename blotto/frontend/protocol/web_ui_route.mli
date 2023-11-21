type t =
  | Game
  | Index
  | User
  | Not_found

val of_string : string -> t
