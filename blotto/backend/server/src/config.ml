open! Core

type t =
  { port : int
  ; state_file : Filename.t option [@sexp.option]
  ; persist_state : bool [@sexp.bool]
  }
[@@deriving sexp]
