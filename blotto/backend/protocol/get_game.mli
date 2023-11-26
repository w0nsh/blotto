open! Core
open Blotto_kernel_lib

module Query : sig
  type t = Game_id.t [@@deriving sexp, bin_io, equal]
end

module Response : sig
  type t = Game_info.t [@@deriving sexp, bin_io, equal]
end

include Rpc_intf.S with module Query := Query and module Response := Response
