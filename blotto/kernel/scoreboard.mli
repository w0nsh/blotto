open! Core

type t [@@deriving sexp, bin_io, equal]

val create : entries:(User_token.t * Army.t) list -> eval:(Army.t -> Army.t -> int) -> t
