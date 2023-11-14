open! Core

type t [@@deriving sexp, equal, compare, bin_io]

val create : string -> t Or_error.t
val to_string : t -> string
