open! Core
open Import

type t =
  { content : string
  ; content_type : string
  ; status : Cohttp.Code.status_code
  }
[@@deriving sexp_of]

let digest = sexp_of_t >> Sexp.to_string_mach >> Md5.digest_string >> Md5.to_hex
