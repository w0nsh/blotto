open! Core

type t [@@deriving sexp, compare, equal, bin_io]

val create : name:string -> surname:string -> email:string -> t Or_error.t
val create_exn : name:string -> surname:string -> email:string -> t
val name : t -> string
val surname : t -> string
val email : t -> Email.t
