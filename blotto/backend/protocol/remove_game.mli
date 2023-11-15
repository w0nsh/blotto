open! Core
open Blotto_kernel_lib

module Query : sig
  type t = Game_id.t [@@deriving sexp, bin_io]
end

module Response : sig
  type t = unit Or_error.t [@@deriving sexp, bin_io]
end
