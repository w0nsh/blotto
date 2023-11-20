open! Core
open! Import
open Bonsai.Let_syntax

let component =
  let%sub games_list_component = Games_list.component in
  let%sub submission_form_component = Submit_strategy.component in
  let%arr games_list_component = games_list_component
  and submission_form_component = submission_form_component in
  let main_view =
    N.div
      [ N.h1 [ N.text "Blotto" ]
      ; Pane.component [ submission_form_component ]
      ; Pane.component [ games_list_component ]
      ]
  in
  N.div ~attrs:[ A.class_ "main-view" ] [ main_view ]
;;
