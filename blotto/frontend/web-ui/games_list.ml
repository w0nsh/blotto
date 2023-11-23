open! Core
open! Import
open Bonsai.Let_syntax

let games_component ~active games =
  let games =
    List.map games ~f:(fun (game_id, game) ->
      Pane.component
        ~attrs:
          [ Path.link_attr
              { Path.And_query.path = (if active then "/game" else "/scoreboard")
              ; query = [ "game_id", [ Game_id.to_string game_id ] ]
              }
          ; A.class_ "game-list-entry"
          ]
        [ N.h3 [ N.text (Game_id.to_string game_id) ]
        ; N.p [ N.text (Game_info.sexp_of_t game |> Sexp.to_string_hum) ]
        ])
  in
  Pane.component games
;;

let sort_partition_games game_infos =
  let sort =
    List.sort
      ~compare:
        (fun
          (_, { Game_info.start_date = a; _ }) (_, { Game_info.start_date = b; _ }) ->
        Time_ns.compare a b)
  in
  let partition =
    let now = Time_ns.now () in
    List.partition_tf ~f:(fun (_, { Game_info.end_date; _ }) ->
      Time_ns.O.(end_date >= now))
  in
  sort game_infos |> partition
;;

let games_response_component ~theme games_response =
  match%sub games_response with
  | Ok games ->
    let%arr games = games in
    let games = Hashtbl.to_alist games in
    let ongoing_games, old_games = sort_partition_games games in
    N.div
      [ games_component ~active:true ongoing_games
      ; games_component ~active:false old_games
      ]
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
    ~attrs:[ A.class_ "games-list" ]
    [ View.button theme ~on_click:refresh "refresh"; games_list ]
;;
