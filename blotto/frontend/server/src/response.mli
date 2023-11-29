open! Core
open! Import

type t =
  { content : string
  ; content_type : string
  ; status : Cohttp.Code.status_code
  }
[@@deriving sexp_of]

val digest : t -> string
