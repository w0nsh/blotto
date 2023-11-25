open! Core

type t =
  | Script
  | Style
  | Web_ui of Web_ui_route.t
  | Not_found

val of_uri : Uri.t -> t
