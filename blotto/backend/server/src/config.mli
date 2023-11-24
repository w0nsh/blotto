open! Core

(** Server configuration.
    * [port] - port to listen on
    * [state_file] - if [Some filename], then load the state from the file.
    * [persist_state] - if [true] then periodically dump state to [state_file].
    [state_file] cannot be [None] if [persist_state] is true. *)
type t =
  { port : int
  ; state_file : Filename.t option
  ; persist_state : bool
  }
[@@deriving sexp]
