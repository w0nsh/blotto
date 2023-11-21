open! Core
open Import

let route = Value.map Path.path ~f:Web_ui_route.of_string

let component =
  let open Bonsai.Let_syntax in
  match%sub route with
  | Game -> Game_view.component
  | Index -> Index_view.component
  | User -> Bonsai.const (N.text "not implemented")
  | _ -> Not_found.component
;;
