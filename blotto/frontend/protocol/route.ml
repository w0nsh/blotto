open! Core

type t =
  | Script
  | Style
  | Web_ui of Web_ui_route.t
  | Not_found

let match_non_web_ui str =
  match Utils.normalize_path str with
  | "/script.js" -> Script
  | "/style.css" -> Style
  | _ -> Not_found
;;

let of_string str =
  match Web_ui_route.of_string str with
  | Not_found -> match_non_web_ui str
  | route -> Web_ui route
;;
