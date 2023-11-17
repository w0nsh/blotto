open! Core

type t = private string [@@deriving sexp, compare, bin_io]

include String_id.S with type t := t
include Hashable.S_binable with type t := t

val arg_type : t Command.Arg_type.t
