open! Core

type t =
  | Script
  | Style
  | Web_ui of Web_ui_route.t
  | Not_found

let match_non_web_ui uri =
  let path = Uri.path uri |> Utils.normalize_path in
  match path with
  | "/script.js" -> Script
  | "/style.css" -> Style
  | _ -> Not_found
;;

let of_uri uri =
  match Web_ui_route.of_uri uri with
  | Not_found -> match_non_web_ui uri
  | route -> Web_ui route
;;
