open! Core
open Import

module And_query = struct
  type t =
    { path : string
    ; query : (string * string list) list
    }
end

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
let path = Value.map uri ~f:Uri.path
let query key = Value.map uri ~f:(fun uri -> Uri.get_query_param uri key)

let set_route =
  let open Js_of_ocaml in
  let set { And_query.path = new_path; query = new_query } =
    let uri =
      let curr = get_uri () in
      let curr = Uri.with_path curr new_path in
      Uri.with_query curr new_query
    in
    let str_uri = Js.string (Uri.to_string uri) in
    Dom_html.window##.history##pushState Js.null str_uri (Js.Opt.return str_uri);
    Var.set uri_var uri
  in
  Effect.of_sync_fun set
;;

let link_attr and_query =
  A.many
    [ A.on_click (fun e ->
        Js_of_ocaml.Dom.preventDefault e;
        set_route and_query)
    ; A.style (Css_gen.create ~field:"cursor" ~value:"pointer")
    ]
;;

let game_id_query =
  let game_id_of_string s = Option.try_with (fun () -> Game_id.of_string s) in
  Value.map (query "game_id") ~f:(Option.bind ~f:game_id_of_string)
;;
