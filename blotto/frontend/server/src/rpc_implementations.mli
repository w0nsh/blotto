open! Core
open! Async
open Import

val implementations
  :  backend_connection:Persistent_connection.Rpc.t
  -> Connection_state.t Rpc.Implementations.t
