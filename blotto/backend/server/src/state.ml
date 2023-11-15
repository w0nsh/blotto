open! Core
open Async
open Import

type t =
  { games : Game.t Game_id.Table.t
  ; users : User_info.t User_token.Table.t
  }
[@@deriving sexp]

let init () = { games = Game_id.Table.create (); users = User_token.Table.create () }
let load filename = Reader.load_sexp filename t_of_sexp

let save t filename =
  Deferred.Or_error.try_with (fun () ->
    Writer.save_sexp ~fsync:true ~hum:true filename (sexp_of_t t))
;;
