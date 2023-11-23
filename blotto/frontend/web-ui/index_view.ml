open! Core
open! Import
open Bonsai.Let_syntax

let component =
  let%sub theme = View.Theme.current in
  let%sub games_list = Games_list.component in
  let%arr games_list = games_list
  and theme = theme in
  ignore theme;
  Pane.component ~attrs:[ A.class_ "index-view" ] [ games_list ]
;;
