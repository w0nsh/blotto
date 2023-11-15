open! Core

type t [@@deriving sexp, bin_io, equal]

val length : int
val soliders_cnt : int
val create : int array -> t Or_error.t
val create_exn : int array -> t
val fold2i : t -> t -> f:(int -> castle:int -> a:int -> b:int -> int) -> int
