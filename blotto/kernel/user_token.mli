open! Core

(** Only lowercase letters with hyphens. *)
type t [@@deriving sexp, compare, equal, bin_io]

val create_exn : string -> t
val create : string -> t Or_error.t
val to_string : t -> string

include Hashable.S_binable with type t := t
include Comparable.S_binable with type t := t
