open! Core

module Allowed_users : sig
  type t =
    | Any
    | Users of User_token.Set.t
  [@@deriving sexp, bin_io, equal]
end

type t =
  { name : string
  ; description : string
  ; start_date : Time_ns.Alternate_sexp.t
  ; end_date : Time_ns.Alternate_sexp.t
  ; allowed_users : Allowed_users.t
  ; rule : Rule.t
  ; entries : Army.t User_token.Table.t
  }
[@@deriving sexp, bin_io, equal]

val create
  :  name:string
  -> description:string
  -> start_date:Time_ns.Alternate_sexp.t
  -> end_date:Time_ns.Alternate_sexp.t
  -> allowed_users:Allowed_users.t
  -> rule:Rule.t
  -> t Or_error.t

val update_entry : t -> token:User_token.t -> army:Army.t -> unit
