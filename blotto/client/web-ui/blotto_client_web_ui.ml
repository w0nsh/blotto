open! Core
open! Async_kernel
open! Bonsai_web
open! Async_js
open Bonsai.Let_syntax

let get_google_com =
  Effect.of_deferred_thunk (fun () ->
      let%bind.Deferred () = Clock_ns.after (Time_ns.Span.of_sec 5.0) in
      Http.get "https://google.com")

let component =
  let%sub response, set_response =
    Bonsai.state_opt ~sexp_of_model:String.sexp_of_t ()
  in
  let%sub on_activate =
    let%arr set_response = set_response in
    let%bind.Effect response = get_google_com in
    match response with
    | Ok response -> set_response (Some response)
    | Error err ->
        let response = sprintf "Error: %s" (Error.to_string_hum err) in
        set_response (Some response)
  in
  let%sub () = Bonsai.Edge.lifecycle ~on_activate () in
  let%arr response = response in
  let text =
    match response with
    | Some response -> response
    | None -> "waiting for response"
  in
  Vdom.Node.text text

let () = Bonsai_web.Start.start component
