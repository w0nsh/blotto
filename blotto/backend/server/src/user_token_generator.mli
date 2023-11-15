open! Core
open Blotto_kernel_lib

type t

val get_token : t -> num_words:int -> User_token.t
val init : ?seed:int -> unit -> t
