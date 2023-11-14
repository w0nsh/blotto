open! Core
open Async
open Blotto_kernel_lib

type t

val get_token : t -> num_words:int -> User_token.t
val init : ?seed:int -> words_file:Filename.t -> unit -> t Deferred.Or_error.t
