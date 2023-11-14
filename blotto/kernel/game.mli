open! Core

module Allowed_users : sig
  type t =
    | Any
    | Users of User_token.Set.t
  [@@deriving sexp, bin_io]
end

type t [@@deriving sexp, bin_io]

val create
  :  name:string
  -> description:string
  -> start_date:Time_ns.Alternate_sexp.t
  -> end_date:Time_ns.Alternate_sexp.t
  -> allowed_users:Allowed_users.t
  -> rule_description:string
  -> t Or_error.t

val name : t -> string
val description : t -> string
val start_date : t -> Time_ns.Alternate_sexp.t
val end_date : t -> Time_ns.Alternate_sexp.t
val allowed_users : t -> Allowed_users.t
val entries : t -> Army.t User_token.Table.t
val rule_description : t -> string
val update_entry : t -> token:User_token.t -> army:Army.t -> unit
