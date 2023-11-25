open! Core
open Import
open Bonsai.Let_syntax

let top_bar =
  N.div
    ~attrs:[ A.class_ "top-bar" ]
    [ N.h1 ~attrs:[ A.class_ "top-bar-title" ] [ N.text "Blotto" ]
    ; Feather_icon.svg
        ~size:(`Px 30)
        ~extra_attrs:[ A.class_ "top-bar-wiki"; Path.link_attr Web_ui_route.Index ]
        Feather_icon.Book_open
    ]
;;

let component =
  let%sub view_component = Router.component in
  let%sub navigation_column_component = Navigation_column.component in
  let%arr view_component = view_component
  and navigation_column_component = navigation_column_component in
  let content =
    [ top_bar
    ; N.div
        ~attrs:[ A.class_ "content-container" ]
        [ navigation_column_component
        ; N.div ~attrs:[ A.class_ "view-container" ] [ view_component ]
        ]
    ]
  in
  N.div ~attrs:[ A.class_ "site-container" ] content
;;
