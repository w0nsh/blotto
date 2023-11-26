open! Core
open Blotto_kernel_lib

module Query : sig
  type t = User_data.t [@@deriving sexp, bin_io, equal]
end

module Response : sig
  type t = User_token.t [@@deriving sexp, bin_io, equal]
end

include Rpc_intf.S with module Query := Query and module Response := Response
