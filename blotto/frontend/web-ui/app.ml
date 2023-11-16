open! Core
open! Import
open Bonsai.Let_syntax

(* TODO: move *)
let games_downloader ~api =
  let%sub response, set_response =
    Bonsai.state_opt ~sexp_of_model:Get_games.Response.sexp_of_t ()
  in
  let%sub on_activate =
    let%arr set_response = set_response in
    let%bind.Effect response = Api.get_games api () in
    set_response (Some response)
  in
  let%sub () = Bonsai.Edge.lifecycle ~on_activate () in
  return response
;;

let component ~api =
  let%sub response = games_downloader ~api in
  let%sub games_list_component =
    match%sub response with
    | None -> Bonsai.const (N.text "downloading...")
    | Some games -> Games_list.component games
  in
  let%arr games_list_component = games_list_component in
  let main_view = View.vbox [ N.h1 [ N.text "Blotto" ]; games_list_component ] in
  N.div ~attrs:[ A.class_ "main-view" ] [ main_view ]
;;
