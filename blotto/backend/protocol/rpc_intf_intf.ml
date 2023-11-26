open! Core
open Async_kernel
open Async_rpc_kernel

module type Arg = sig
  module Query : sig
    type t [@@deriving sexp, bin_io, equal]
  end

  module Response : sig
    type t [@@deriving sexp, bin_io, equal]
  end

  val rpc_name : string
end

module type S = sig
  include Arg

  val dispatch : Rpc.Connection.t -> Query.t -> Response.t Deferred.Or_error.t

  val implement
    :  (rpc_tag:string -> 'a -> Query.t -> Response.t Deferred.Or_error.t)
    -> 'a Rpc.Implementation.t
end

module type Rpc_intf = sig
  module type Arg = Arg
  module type S = S

  module Make (Arg : Arg) :
    S with module Query := Arg.Query and module Response := Arg.Response
end
