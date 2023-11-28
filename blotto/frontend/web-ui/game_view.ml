open! Core
open Import
open Bonsai.Let_syntax

let view_game_info ~game_id ~game_info =
  let%sub submit_strategy = Submit_strategy.component ~game_id in
  let%arr game_info = game_info
  and submit_strategy = submit_strategy in
  Pane.component
    ~attrs:[ A.class_ "game-view" ]
    [ Pane.component
        ~attrs:[ A.class_ "content" ]
        [ Game_info_view.component game_info
        ; Pane.component
            ~attrs:[ A.class_ "submit-form" ]
            [ N.h2 ~attrs:[ A.class_ "submit-header" ] [ N.text "Zgłoszenie" ]
            ; Pane.component ~add_padding:false [ submit_strategy ]
            ]
        ]
    ]
;;

let view ~game_id =
  let%sub game_info, refresh = Api.Get_game.dispatcher in
  let%sub () = Bonsai.Edge.on_change (module Game_id) game_id ~callback:refresh in
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
