open Async
open Cohttp
open Cohttp_async

let create ~port =
  let callback ~body address req =
    let path = req |> Request.uri |> Uri.path in
    let _meth = req |> Request.meth |> Code.string_of_method in
    let _headers = req |> Request.headers |> Header.to_string in
    let _address = address |> Socket.Address.to_string in
    let%bind _body = Body.to_string body in
    let response = Printf.sprintf "%s" path in
    Server.respond_string
      ~headers:(Header.of_list [ "Access-Control-Allow-Origin", "*" ])
      ~status:`OK
      response
  in
  Server.create ~on_handler_error:`Raise (Tcp.Where_to_listen.of_port port) callback
;;
