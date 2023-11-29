open! Core
open Import

type t

val of_route : Route.t -> t
val to_response : t -> Response.t
val etag : t -> string
