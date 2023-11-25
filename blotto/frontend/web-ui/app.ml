open! Core
open Import
open Bonsai.Let_syntax

let top_bar =
  N.div
    ~attrs:[ A.class_ "top-bar" ]
    [ N.h1 ~attrs:[ A.class_ "top-bar-title" ] [ N.text "Blotto" ]
    ; N.a
        ~attrs:
          [ A.href "https://en.wikipedia.org/wiki/Blotto_game"; A.class_ "top-bar-wiki" ]
        [ Feather_icon.svg Feather_icon.Book_open ]
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
