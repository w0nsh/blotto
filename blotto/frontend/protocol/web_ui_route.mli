type t =
  | Index
  | User
  | Not_found

val of_string : string -> t
