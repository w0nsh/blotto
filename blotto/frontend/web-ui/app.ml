open! Core
open Import
open Bonsai.Let_syntax

let component ~component =
  let%sub component = component in
  let%arr component = component in
  let main_view =
    N.div
      [ N.h1
          ~attrs:[ Path.link_attr { Path.And_query.path = ""; query = [] } ]
          [ N.text "Blotto" ]
      ; N.div ~attrs:[ A.class_ "view-container" ] [ component ]
      ]
  in
  N.div ~attrs:[ A.class_ "site-container" ] [ main_view ]
;;
