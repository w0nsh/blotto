open! Core
open Import

val path : string Value.t
val query : (string * string list) list Value.t
val set_route : string -> unit Ui_effect.t
val link_attr : string -> A.t
