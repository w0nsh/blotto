open! Core

type t [@@deriving sexp, bin_io, equal]

val length : int
val soliders_cnt : int
val create : int array -> t Or_error.t
val create_exn : int array -> t
val to_array : t -> int array
val fold2i : t -> t -> init:'a -> f:('a -> castle:int -> a:int -> b:int -> 'a) -> 'a
