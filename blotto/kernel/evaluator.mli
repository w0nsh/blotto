open! Core

type t [@@deriving sexp]

val basic : t
val first_win_tripled : t
val eval : t -> Army.t -> Army.t -> int
