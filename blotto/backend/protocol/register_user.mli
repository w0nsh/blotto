open! Core
open Blotto_kernel_lib

module Query : sig
  type t = User_data.t [@@deriving sexp, bin_io]
end

module Response : sig
  type t = User_token.t Or_error.t [@@deriving sexp, bin_io]
end

val rpc_name : string
