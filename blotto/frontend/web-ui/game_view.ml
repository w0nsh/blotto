open! Core
open Import
open Bonsai.Let_syntax

let view_game_info ~game_id ~game_info =
  let%sub submit_strategy = Submit_strategy.component ~game_id in
  let%arr { Game_info.name; description; start_date; end_date; rule } = game_info
  and submit_strategy = submit_strategy in
  Pane.component
    [ N.h1 [ N.text name ]
    ; N.p [ N.text description ]
    ; N.p [ N.text (Time_ns.to_string_utc start_date) ]
    ; N.p [ N.text (Time_ns.to_string_utc end_date) ]
    ; N.p [ N.text (Rule.description rule) ]
    ; submit_strategy
    ]
;;

let view ~game_id =
  let%sub game_info, refresh = Api.Get_game.dispatcher in
  let%sub refresh =
    let%arr game_id = game_id
    and refresh = refresh in
    refresh game_id
  in
  let%sub () = Bonsai.Edge.lifecycle ~on_activate:refresh () in
  match%sub game_info with
  | None -> Bonsai.const (N.text "downloading...")
  | Some game_info ->
    (match%sub game_info with
     | Error err ->
       let%arr err = err in
       N.text (Error.to_string_hum err)
     | Ok game_info -> view_game_info ~game_id ~game_info)
;;

let component ~game_id =
  match%sub game_id with
  | None -> Bonsai.const (N.text "invalid game id")
  | Some game_id -> view ~game_id
;;
