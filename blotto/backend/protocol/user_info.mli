open! Core
open Blotto_kernel_lib

type t =
  { data : User_data.t
  ; creation_time : Time_ns.Alternate_sexp.t
  }
[@@deriving sexp, bin_io, equal]
