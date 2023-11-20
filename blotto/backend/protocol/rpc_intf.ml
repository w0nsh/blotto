open! Core
open Async_kernel
open Async_rpc_kernel
include Rpc_intf_intf

module Make (Arg : Arg) :
  S with module Query := Arg.Query and module Response := Arg.Response = struct
  include Arg

  module Response_or_error = struct
    type t = Response.t Or_error.t [@@deriving bin_io, sexp]
  end

  let rpc =
    Rpc.Rpc.create
      ~name:Arg.rpc_name
      ~version:1
      ~bin_query:Arg.Query.bin_t
      ~bin_response:Response_or_error.bin_t
  ;;

  let dispatch conn query = Rpc.Rpc.dispatch rpc conn query >>| Or_error.join
  let implement f = Rpc.Rpc.implement rpc (f ~rpc_tag:Arg.rpc_name)
end
