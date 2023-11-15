open! Core
open! Import
open Bonsai.Let_syntax

let list_of_games games =
  N.text ((Game_id.Table.sexp_of_t Game.sexp_of_t) games |> Sexp.to_string)
;;

let component ~api =
  let%sub theme = View.Theme.current in
  let%sub response, set_response =
    Bonsai.state_opt ~sexp_of_model:Get_games.Response.sexp_of_t ()
  in
  let%sub on_activate =
    let%arr set_response = set_response in
    let%bind.Effect response = Api.get_games api () in
    set_response (Some response)
  in
  let%sub () = Bonsai.Edge.lifecycle ~on_activate () in
  let%arr response = response
  and theme = theme in
  let games =
    match response with
    | Some response ->
      (match response with
       | Error err -> N.text (Error.to_string_hum err)
       | Ok games -> list_of_games games)
    | None -> N.text "waiting for response"
  in
  [ games
  ; N.text (View.Theme.name theme)
  ; View.button theme ~on_click:(Effect.return ()) "button"
  ]
  |> List.intersperse ~sep:(N.br ())
  |> N.div ~attrs:[ A.class_ "main-view" ]
;;
