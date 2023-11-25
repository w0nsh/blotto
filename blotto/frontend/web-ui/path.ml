open! Core
open Import

let get_uri () =
  let open Js_of_ocaml in
  Dom_html.window##.location##.href |> Js.to_string |> Uri.of_string
;;

let uri_var = Var.create (get_uri ())

let () =
  let open Js_of_ocaml in
  Dom_html.window##.onpopstate
  := Dom_html.handler (fun _ ->
       Var.set uri_var (get_uri ());
       Js._false)
;;

let uri = Var.value uri_var
let route = Value.map uri ~f:Web_ui_route.of_uri
(* let path = Value.map uri ~f:Uri.path
   let query key = Value.map uri ~f:(fun uri -> Uri.get_query_param uri key) *)

let set_route =
  let open Js_of_ocaml in
  let set route =
    let uri =
      let curr = get_uri () in
      Web_ui_route.set_path_and_query ~uri:curr route
    in
    let str_uri = Js.string (Uri.to_string uri) in
    Dom_html.window##.history##pushState Js.null str_uri (Js.Opt.return str_uri);
    Var.set uri_var uri
  in
  Effect.of_sync_fun set
;;

let link_attr route =
  A.many
    [ A.on_click (fun e ->
        Js_of_ocaml.Dom.preventDefault e;
        set_route route)
    ; A.style (Css_gen.create ~field:"cursor" ~value:"pointer")
    ]
;;
