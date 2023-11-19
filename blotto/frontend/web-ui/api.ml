open! Core
open! Import
include Api_intf

type t = { connection : Persistent_connection.Rpc.t }

let create connection = { connection }

module Make (Arg : Rpc_intf.S) = struct
  include Arg

  let dispatch_effect { connection } =
    Effect.of_deferred_fun (fun query ->
      let%bind conn = Persistent_connection.Rpc.connected connection in
      (* TODO: move to other module and add timeout *)
      dispatch conn query)
  ;;

  let dispatcher t =
    let open Bonsai.Let_syntax in
    let%sub response, set_response =
      Bonsai.state_opt ~sexp_of_model:(Or_error.sexp_of_t Response.sexp_of_t) ()
    in
    let%sub fetch =
      let%arr set_response = set_response in
      fun query ->
        (* TODO: add flag "should clear response on refetch?" *)
        let%bind.Effect () = set_response None in
        let%bind.Effect response = dispatch_effect t query in
        set_response (Some response)
    in
    return (Value.both response fetch)
  ;;
end

module Create_game = Make (Create_game)
module Get_games = Make (Get_games)
module Get_scoreboard = Make (Get_scoreboard)
module List_users = Make (List_users)
module Register_user = Make (Register_user)
module Remove_game = Make (Remove_game)
module Submit_entry = Make (Submit_entry)
module Update_game = Make (Update_game)
