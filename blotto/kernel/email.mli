open! Core

type t [@@deriving sexp, equal, compare]

val create : string -> t Or_error.t
val to_string : t -> string
