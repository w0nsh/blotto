open! Core
open Import

module And_query : sig
  type t =
    { path : string
    ; query : (string * string list) list
    }
end

val path : string Value.t
val query : string -> string option Value.t
val set_route : And_query.t -> unit Ui_effect.t
val link_attr : And_query.t -> A.t
