open! Core
open! Import
open Bonsai.Let_syntax

let games_component games =
  let%arr games = games in
  let games_info =
    Hashtbl.to_alist games
    |> List.map ~f:(fun (game_id, game) ->
      N.div
        [ N.h3 [ N.text (Game_id.to_string game_id) ]
        ; N.p [ N.text (Game.sexp_of_t game |> Sexp.to_string_hum) ]
        ])
  in
  N.div [ View.vbox [ N.div games_info ] ]
;;

let component get_games_response =
  let%sub theme = View.Theme.current in
  match%sub get_games_response with
  | Ok games -> games_component games
  | Error err ->
    let%arr theme = theme
    and err = err in
    View.card theme (Error.to_string_hum err)
;;
