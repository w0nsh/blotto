open! Core

type t [@@deriving sexp, equal, compare, bin_io]

val create : string -> t Or_error.t
val create_exn : string -> t
val to_string : t -> string

include Comparable.S with type t := t
