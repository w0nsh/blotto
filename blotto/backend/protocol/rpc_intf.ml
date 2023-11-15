open! Core
open Async_kernel
open Async_rpc_kernel

module type Arg = sig
  module Query : sig
    type t [@@deriving sexp, bin_io]
  end

  module Response : sig
    type t [@@deriving sexp, bin_io]
  end
end

module type S = sig
  include Arg

  val dispatch : Rpc.Connection.t -> Query.t -> Response.t Deferred.Or_error.t

  val implement
    :  (rpc_tag:string -> 'a -> Query.t -> Response.t Deferred.t)
    -> 'a Rpc.Implementation.t
end

module Make (M : sig
    include Arg

    val rpc_name : string
  end) : S with module Query := M.Query and module Response := M.Response = struct
  let rpc =
    Rpc.Rpc.create
      ~name:M.rpc_name
      ~version:1
      ~bin_query:M.Query.bin_t
      ~bin_response:M.Response.bin_t
  ;;

  let dispatch = Rpc.Rpc.dispatch rpc
  let implement f = Rpc.Rpc.implement rpc (f ~rpc_tag:M.rpc_name)
end
