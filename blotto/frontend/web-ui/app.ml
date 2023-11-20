open! Core
open! Import
open Bonsai.Let_syntax

let component ~api =
  let%sub games_list_component = Games_list.component ~api in
  let%arr games_list_component = games_list_component in
  let main_view = View.vbox [ N.h1 [ N.text "Blotto" ]; games_list_component ] in
  N.div ~attrs:[ A.class_ "main-view" ] [ main_view ]
;;
