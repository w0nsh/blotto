open! Core
open! Import
(* open Bonsai.Let_syntax *)

let component =
  Bonsai.const (Pane.component ~attrs:[ A.class_ "index-view" ] [ N.text "zasady tutaj" ])
;;
