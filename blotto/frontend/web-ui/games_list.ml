open! Core
open! Import
open Bonsai.Let_syntax

let game_component ~active ~game_id ~(game : Game_info.t) =
  let attrs =
    [ Path.link_attr
        (if active
         then Web_ui_route.Game (Some game_id)
         else Web_ui_route.Scoreboard (Some game_id))
    ; A.class_ "game-list-entry"
    ]
  in
  Pane.component ~attrs [ N.h4 [ N.text game.name ]; N.p [ N.text game.description ] ]
;;

let games_component ~active games =
  let games =
    List.map games ~f:(fun (game_id, game) -> game_component ~active ~game_id ~game)
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
    >> List.rev
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
      [ N.h3 [ N.text "Bieżące gry" ]
      ; games_component ~active:true ongoing_games
      ; N.h3 [ N.text "Zakończone gry" ]
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
  and refresh = refresh in
  let refresh_button =
    Feather_icon.svg
      ~extra_attrs:[ A.on_click (fun _ -> refresh); A.class_ "refresh-button" ]
      Feather_icon.Refresh_ccw
  in
  Pane.component
    ~attrs:[ A.class_ "games-list" ]
    [ N.h2 ~attrs:[ A.class_ "games-header" ] [ N.text "Gry"; refresh_button ]
    ; games_list
    ]
;;
