open! Core
open! Import
open Bonsai.Let_syntax

let register_button =
  Pane.component
    ~attrs:[ A.class_ "button-container" ]
    [ N.button ~attrs:[ Path.link_attr Web_ui_route.Index ] [ N.text "zasady" ]
    ; N.button
        ~attrs:[ Path.link_attr Web_ui_route.Register_user ]
        [ N.text "rejestracja" ]
    ]
;;

let component =
  let%sub games_list = Games_list.component in
  let%arr games_list = games_list in
  N.div ~attrs:[ A.class_ "navigation-column" ] [ register_button; games_list ]
;;
