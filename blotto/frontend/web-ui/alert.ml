open! Core
open Import

let effect =
  let alert s = Js_of_ocaml.Dom_html.window##alert (Js_of_ocaml.Js.string s) in
  Effect.of_sync_fun alert
;;
