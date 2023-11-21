open Core

type t =
  { name : string
  ; description : string
  ; start_date : Time_ns.Alternate_sexp.t
  ; end_date : Time_ns.Alternate_sexp.t
  ; rule : Rule.t
  }
[@@deriving sexp, bin_io, equal]
