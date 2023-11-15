open! Core
open! Import

type t = { connection : Rpc.Connection.t }

let create connection = { connection }

let get_games { connection } =
  Effect.of_deferred_fun (fun query -> Get_games.dispatch_exn connection query)
;;
