open! Core

type t =
  | Index
  | User
  | Not_found

let of_string str =
  match Utils.normalize_path str with
  | "" -> Index
  | "/user" -> User
  | _ -> Not_found
;;
