open! Core
open Import
open Bonsai.Let_syntax

let component =
  let%sub view_component = Router.component in
  let%sub navigation_column_component = Navigation_column.component in
  let%arr view_component = view_component
  and navigation_column_component = navigation_column_component in
  let content =
    N.div
      [ N.h1 ~attrs:[ Path.link_attr Web_ui_route.Index ] [ N.text "Blotto" ]
      ; N.div
          ~attrs:[ A.class_ "content-container" ]
          [ navigation_column_component
          ; N.div ~attrs:[ A.class_ "view-container" ] [ view_component ]
          ]
      ]
  in
  N.div ~attrs:[ A.class_ "site-container" ] [ content ]
;;
