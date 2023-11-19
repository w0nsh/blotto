open! Core
open Blotto_kernel_lib

module Query : sig
  type t =
    { id : Game_id.t
    ; start_date : Time_ns.Alternate_sexp.t option
    ; end_date : Time_ns.Alternate_sexp.t option
    ; allowed_users : Game.Allowed_users.t option
    ; rule : Rule.t option
    }
  [@@deriving sexp, bin_io]
end

module Response : sig
  module Result : sig
    type t =
      { id : Game_id.t
      ; game : Game.t
      }
    [@@deriving sexp, bin_io]
  end

  type t = Result.t [@@deriving sexp, bin_io]
end

include Rpc_intf.S with module Query := Query and module Response := Response
