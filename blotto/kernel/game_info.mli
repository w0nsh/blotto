open Core

type t =
  { name : string
  ; description : string
  ; start_date : Time_ns_fix.t
  ; end_date : Time_ns_fix.t
  ; rule : Rule.t
  }
[@@deriving sexp, bin_io, equal]
