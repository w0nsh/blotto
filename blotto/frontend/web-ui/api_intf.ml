open! Core
open Import

module type S = sig
  module Query : sig
    type t [@@deriving sexp, bin_io]
  end

  module Response : sig
    type t [@@deriving sexp, bin_io]
  end

  val dispatch_effect : Query.t -> Response.t Or_error.t Ui_effect.t

  val dispatcher
    : (Response.t Or_error.t option * (Query.t -> unit Ui_effect.t)) Computation.t
end

module type Api = sig
  (* TODO: better way to do this? also include query and response in the module *)

  module Get_game :
    S with module Query := Get_game.Query and module Response := Get_game.Response

  module Get_games :
    S with module Query := Get_games.Query and module Response := Get_games.Response

  module Get_ui_scoreboard :
    S
    with module Query := Get_ui_scoreboard.Query
     and module Response := Get_ui_scoreboard.Response

  module Register_user :
    S
    with module Query := Register_user.Query
     and module Response := Register_user.Response

  module Submit_entry :
    S with module Query := Submit_entry.Query and module Response := Submit_entry.Response
end
