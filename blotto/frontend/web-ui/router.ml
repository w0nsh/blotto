open! Core
open Import

let route = Value.map Path.path ~f:Web_ui_route.of_string

let component =
  let open Bonsai.Let_syntax in
  match%sub route with
  | Index -> Index.component
  | User -> Bonsai.const (N.text "not implemented")
  | _ -> Not_found.component
;;
