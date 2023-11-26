open! Core
open Blotto_kernel_lib

module Query : sig
  type t =
    { id : Game_id.t
    ; name : string option [@sexp.option]
    ; description : string option [@sexp.option]
    ; start_date : Time_ns_fix.t option [@sexp.option]
    ; end_date : Time_ns_fix.t option [@sexp.option]
    ; allowed_users : Game.Allowed_users.t option [@sexp.option]
    ; rule : Rule.t option [@sexp.option]
    }
  [@@deriving sexp, bin_io, equal]
end

module Response : sig
  type t =
    { id : Game_id.t
    ; game : Game.t
    }
  [@@deriving sexp, bin_io, equal]
end

include Rpc_intf.S with module Query := Query and module Response := Response
