open Core

type t =
  { port : int
  ; backend_address : Host_and_port.t
  }
[@@deriving sexp]
