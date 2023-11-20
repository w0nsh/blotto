open! Core
open Blotto_kernel_lib

module Query : sig
  type t =
    { game_id : Game_id.t
    ; token : User_token.t
    ; army : Army.t
    }
  [@@deriving sexp, bin_io]
end

module Response : sig
  type t = unit [@@deriving sexp, bin_io]
end

include Rpc_intf.S with module Query := Query and module Response := Response
