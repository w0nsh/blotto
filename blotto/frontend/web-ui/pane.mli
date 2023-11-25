open! Core
open Import

val component
  :  ?attrs:A.t list
  -> ?add_margin:bool
  -> ?add_padding:bool
  -> N.t list
  -> N.t
