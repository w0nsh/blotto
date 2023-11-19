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
  View.vbox [ N.div games_info ]
;;

let games_response_component ~theme games_response =
  match%sub games_response with
  | Ok games -> games_component games
  | Error err ->
    let%arr theme = theme
    and err = err in
    View.card theme (Error.to_string_hum err)
;;

(* TODO: move to api once an interface for the rpcs is ready *)
let downloader_with_refresh f =
  let open Bonsai.Let_syntax in
  let%sub response, set_response =
    Bonsai.state_opt ~sexp_of_model:(Or_error.sexp_of_t Get_games.Response.sexp_of_t) ()
  in
  let%sub download =
    let%arr set_response = set_response in
    fun query ->
      let%bind.Effect () = set_response None in
      let%bind.Effect response = f query in
      set_response (Some response)
  in
  return (Value.both response download)
;;

let component ~api =
  let%sub theme = View.Theme.current in
  let%sub games_response, refresh = downloader_with_refresh (Api.get_games api) in
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
  View.vbox [ View.button theme ~on_click:refresh "refresh"; games_list ]
;;
