open! Core
open! Import

type t = { connection : Persistent_connection.Rpc.t }

let create connection = { connection }

let run_rpc
  (type response_type query_type)
  (module M : Rpc_intf.S
    with type Response.t = response_type
     and type Query.t = query_type)
  { connection }
  =
  Effect.of_deferred_fun (fun query ->
    let%bind conn = Persistent_connection.Rpc.connected connection in
    (* TODO: move to other module and add timeout *)
    M.dispatch conn query)
;;

let get_games t = run_rpc (module Get_games) t
