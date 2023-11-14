open! Core

type t [@@deriving sexp]

val create : entries:(User_token.t * Army.t) list -> eval:(Army.t -> Army.t -> int) -> t
