open! Core
open Blotto_kernel_lib

module Query : sig
  type t = unit [@@deriving sexp, bin_io]
end

module Response : sig
  module Result : sig
    type t =
      { id : Game_id.t
      ; game : Game.t
      }
    [@@deriving sexp, bin_io]
  end

  type t = Result.t Or_error.t [@@deriving sexp, bin_io]
end

val rpc_name : string
