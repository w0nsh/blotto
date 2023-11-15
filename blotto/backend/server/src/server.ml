open! Core
open Async
open Blotto_backend_protocol_lib
open Blotto_kernel_lib

module Rpc_state = struct
  type t = Socket.Address.Inet.t * Rpc.Connection.t [@@deriving sexp_of]
end

let log_rpc rpc_state rpc_tag =
  Log.Global.debug_s [%message "New Rpc" (rpc_state : Rpc_state.t) rpc_tag]
;;

let unkown_rpc rpc_state ~rpc_tag ~version =
  Log.Global.error_s
    [%message "Unkown rpc" (rpc_state : Rpc_state.t) rpc_tag (version : int)];
  `Close_connection
;;

let get_games_implementation ~state ~rpc_tag rpc_state (() : Get_games.Query.t) =
  log_rpc rpc_state rpc_tag;
  ignore state;
  Deferred.Or_error.return (Game_id.Table.create ())
;;

let implementations state =
  let implementations = [ Get_games.implement (get_games_implementation ~state) ] in
  Rpc.Implementations.create_exn ~implementations ~on_unknown_rpc:(`Call unkown_rpc)
;;

let run (config : Config.t) =
  let where_to_listen = Tcp.Where_to_listen.of_port config.port in
  let state = State.init () in
  Log.Global.info_s
    [%message "Spinning up server" (where_to_listen : Tcp.Where_to_listen.inet)];
  let%bind server =
    Rpc.Connection.serve
      ~implementations:(implementations state)
      ~initial_connection_state:(fun address connection -> address, connection)
      ~where_to_listen
      ()
  in
  ignore server;
  Deferred.never ()
;;
