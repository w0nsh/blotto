open! Core
open Async

module type Arg = sig
  module Query : sig
    type t [@@deriving sexp, bin_io]
  end

  module Response : sig
    type t [@@deriving sexp, bin_io]
  end

  val rpc_name : string
end

module type S = sig
  include Arg

  val dispatch : Rpc.Connection.t -> Query.t -> Response.t Deferred.Or_error.t

  val implement
    :  (rpc_tag:string -> 'a -> Query.t -> Response.t Deferred.t)
    -> 'a Rpc.Implementation.t
end

module Make (Arg : Arg) :
  S with module Query := Arg.Query and module Response := Arg.Response = struct
  include Arg

  let rpc =
    Rpc.Rpc.create
      ~name:Arg.rpc_name
      ~version:1
      ~bin_query:Arg.Query.bin_t
      ~bin_response:Arg.Response.bin_t
  ;;

  let dispatch = Rpc.Rpc.dispatch rpc
  let implement f = Rpc.Rpc.implement rpc (f ~rpc_tag:Arg.rpc_name)
end
