open! Core

type t =
  { army : Army.t
  ; score : float
  ; user_data : User_data.t
  }
[@@deriving sexp, bin_io, fields ~getters, equal]
