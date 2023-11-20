open! Core
open Import

let get_uri () =
  let open Js_of_ocaml in
  Dom_html.window##.location##.href |> Js.to_string |> Uri.of_string
;;

let uri_var = Var.create (get_uri ())
let path = Var.value uri_var |> Value.map ~f:Uri.path
let query = Var.value uri_var |> Value.map ~f:Uri.query

let set_route =
  let open Js_of_ocaml in
  let set new_path =
    let uri =
      let curr = get_uri () in
      Uri.with_path curr new_path
    in
    let str_uri = Js.string (Uri.to_string uri) in
    Dom_html.window##.history##pushState Js.null str_uri (Js.Opt.return str_uri);
    Var.set uri_var uri
  in
  Effect.of_sync_fun set
;;

let link_attr path =
  A.many
    [ A.href path
    ; A.on_click (fun e ->
        Js_of_ocaml.Dom.preventDefault e;
        set_route path)
    ]
;;
