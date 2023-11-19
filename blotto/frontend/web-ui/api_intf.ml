open! Core
open Import

module type S = sig
  type api_t

  module Query : sig
    type t [@@deriving sexp, bin_io]
  end

  module Response : sig
    type t [@@deriving sexp, bin_io]
  end

  val dispatch_effect : api_t -> Query.t -> Response.t Or_error.t Ui_effect.t

  val dispatcher
    :  api_t
    -> (Response.t Or_error.t option * (Query.t -> unit Ui_effect.t)) Computation.t
end

module type Api = sig
  type t

  val create : Persistent_connection.Rpc.t -> t

  (* TODO: better way to do this? also include query and response in the module *)
  module Create_game :
    S
    with module Query := Create_game.Query
     and module Response := Create_game.Response
     and type api_t := t

  module Get_games :
    S
    with module Query := Get_games.Query
     and module Response := Get_games.Response
     and type api_t := t

  module Get_scoreboard :
    S
    with module Query := Get_scoreboard.Query
     and module Response := Get_scoreboard.Response
     and type api_t := t

  module List_users :
    S
    with module Query := List_users.Query
     and module Response := List_users.Response
     and type api_t := t

  module Register_user :
    S
    with module Query := Register_user.Query
     and module Response := Register_user.Response
     and type api_t := t

  module Remove_game :
    S
    with module Query := Remove_game.Query
     and module Response := Remove_game.Response
     and type api_t := t

  module Submit_entry :
    S
    with module Query := Submit_entry.Query
     and module Response := Submit_entry.Response
     and type api_t := t

  module Update_game :
    S
    with module Query := Update_game.Query
     and module Response := Update_game.Response
     and type api_t := t
end
