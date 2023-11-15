open! Core
open Blotto_kernel_lib

module Query : sig
  type t = unit [@@deriving sexp, bin_io]
end

module Response : sig
  type t = Game.t Game_id.Table.t Or_error.t [@@deriving sexp, bin_io]
end

val rpc_name : string
