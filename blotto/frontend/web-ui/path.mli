open! Core
open Import

val route : Web_ui_route.t Value.t
val set_route : Web_ui_route.t -> unit Ui_effect.t
val link_attr : Web_ui_route.t -> A.t
