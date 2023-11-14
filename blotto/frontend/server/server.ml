open Async
open Cohttp
open Cohttp_async

let create ~port =
  let callback ~body address req =
    let uri = req |> Request.uri |> Uri.to_string in
    let meth = req |> Request.meth |> Code.string_of_method in
    let headers = req |> Request.headers |> Header.to_string in
    let address = address |> Socket.Address.to_string in
    let%bind body = Body.to_string body in
    let response =
      Printf.sprintf
        "Address: %s\nUri: %s\nMethod: %s\nHeaders\nHeaders: %s\nBody: %s"
        address uri meth headers body
    in
    Server.respond_string ~status:`OK response
  in
  Server.create ~on_handler_error:`Raise
    (Tcp.Where_to_listen.of_port port)
    callback
