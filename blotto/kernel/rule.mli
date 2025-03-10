open! Core

type t [@@deriving sexp, bin_io, equal]

val basic : t
val eval : t -> Army.t -> Army.t -> int
val description : t -> string
val arg_type : t Command.Arg_type.t
