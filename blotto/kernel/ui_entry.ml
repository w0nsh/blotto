open! Core

type t =
  { army : Army.t
  ; score : float
  ; user_name : string
  }
[@@deriving sexp, bin_io, fields ~getters, equal]
