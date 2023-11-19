open! Core
open! Import

type t = { connection : Persistent_connection.Rpc.t }

let create connection = { connection }

let get_games { connection } =
  Effect.of_deferred_fun (fun query ->
    let%bind conn = Persistent_connection.Rpc.connected connection in
    (* TODO: move to other module and add timeout *)
    Get_games.dispatch conn query >>| Or_error.join)
;;
