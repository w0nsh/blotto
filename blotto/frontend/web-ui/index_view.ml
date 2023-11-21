open! Core
open! Import
open Bonsai.Let_syntax

let games_component games =
  let%arr games = games in
  let games_info =
    Hashtbl.to_alist games
    |> List.map ~f:(fun (game_id, game) ->
      Pane.component
        ~attrs:
          [ Path.link_attr
              { Path.And_query.path = "/game"
              ; query = [ "game_id", [ Game_id.to_string game_id ] ]
              }
          ; A.class_ "game-list-entry"
          ]
        [ N.h3 [ N.text (Game_id.to_string game_id) ]
        ; N.p [ N.text (Game_info.sexp_of_t game |> Sexp.to_string_hum) ]
        ])
  in
  View.vbox ~cross_axis_alignment:Center games_info
;;

let games_response_component ~theme games_response =
  match%sub games_response with
  | Ok games -> games_component games
  | Error err ->
    let%arr theme = theme
    and err = err in
    View.card theme (Error.to_string_hum err)
;;

let component =
  let%sub theme = View.Theme.current in
  let%sub games_response, refresh = Api.Get_games.dispatcher in
  let refresh = Value.map refresh ~f:(fun f -> f ()) in
  let%sub () = Bonsai.Edge.lifecycle ~on_activate:refresh () in
  let%sub games_list =
    match%sub games_response with
    | None -> Bonsai.const (N.text "downloading...")
    | Some games_response -> games_response_component ~theme games_response
  in
  let%arr games_list = games_list
  and refresh = refresh
  and theme = theme in
  Pane.component
    ~attrs:[ A.class_ "index-view" ]
    [ View.button theme ~on_click:refresh "refresh"; games_list ]
;;
