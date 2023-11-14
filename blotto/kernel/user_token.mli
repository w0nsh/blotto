open! Core

(** Only lowercase letters with hyphens. *)
type t [@@deriving sexp, compare, equal]

val create_exn : string -> t
val create : string -> t Or_error.t

include Hashable.S with type t := t
include Comparable.S with type t := t
