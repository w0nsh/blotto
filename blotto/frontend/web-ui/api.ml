open! Core
open! Import
include Api_intf

let reconnect_delay = Time_ns.Span.of_sec 2.0

let attempt_to_connect () =
  log_s [%message "Attempting to connect to the frontend server"];
  let%map result = Rpc.Connection.client () in
  let print_result () =
    match result with
    | Ok _ -> log_s [%message "Connected"]
    | Error err -> log_s [%message "Connection failed " (err : Error.t)]
  in
  print_result ();
  result
;;

let get_connection () =
  Persistent_connection.Rpc.create
    ~server_name:"server connection"
    ~retry_delay:(fun () -> reconnect_delay)
    ~connect:attempt_to_connect
    ~address:(module Unit)
    (fun () -> Deferred.Or_error.return ())
;;

let connection_var = Var.create (get_connection ())
let connection () = Var.get connection_var

module Make (Arg : Rpc_intf.S) = struct
  include Arg

  let dispatch_effect =
    Effect.of_deferred_fun (fun query ->
      let%bind conn = Persistent_connection.Rpc.connected (connection ()) in
      (* TODO: move to other module and add timeout *)
      dispatch conn query)
  ;;

  let dispatcher =
    let open Bonsai.Let_syntax in
    let%sub response, set_response =
      Bonsai.state_opt ~sexp_of_model:(Or_error.sexp_of_t Response.sexp_of_t) ()
    in
    let%sub fetch =
      let%arr set_response = set_response in
      fun query ->
        (* TODO: add flag "should clear response on refetch?" *)
        let%bind.Effect () = set_response None in
        let%bind.Effect response = dispatch_effect query in
        set_response (Some response)
    in
    return (Value.both response fetch)
  ;;
end

module Get_game = Make (Get_game)
module Get_games = Make (Get_games)
module Get_ui_scoreboard = Make (Get_ui_scoreboard)
module Register_user = Make (Register_user)
module Submit_entry = Make (Submit_entry)
