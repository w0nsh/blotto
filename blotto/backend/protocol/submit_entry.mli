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
  module Result : sig
    type t =
      | Accepted
      | Rejected
    [@@deriving sexp, bin_io]
  end

  type t = Result.t Or_error.t [@@deriving sexp, bin_io]
end
