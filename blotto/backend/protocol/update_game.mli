open! Core
open Blotto_kernel_lib

module Query : sig
  type t =
    { id : Game_id.t
    ; start_date : Time_ns.Alternate_sexp.t option
    ; end_date : Time_ns.Alternate_sexp.t option
    ; allowed_tokens : Game.Allowed_users.t option
    ; rule_description : string option
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

  type t = Result.t Or_error.t [@@deriving sexp, bin_io]
end

val rpc_name : string
