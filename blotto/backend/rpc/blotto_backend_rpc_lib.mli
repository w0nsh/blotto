(* TODO: Is this file needed? *)

open Import

module Get_games : sig
  include module type of Get_games
  include Rpc_intf.S with module Query := Query and module Response := Response
end

module Submit_entry : sig
  include module type of Submit_entry
  include Rpc_intf.S with module Query := Query and module Response := Response
end

module Get_scoreboard : sig
  include module type of Get_scoreboard
  include Rpc_intf.S with module Query := Query and module Response := Response
end

module Register_user : sig
  include module type of Register_user
  include Rpc_intf.S with module Query := Query and module Response := Response
end

module Create_game : sig
  include module type of Create_game
  include Rpc_intf.S with module Query := Query and module Response := Response
end

module Update_game : sig
  include module type of Update_game
  include Rpc_intf.S with module Query := Query and module Response := Response
end

module Remove_game : sig
  include module type of Remove_game
  include Rpc_intf.S with module Query := Query and module Response := Response
end

module List_users : sig
  include module type of List_users
  include Rpc_intf.S with module Query := Query and module Response := Response
end
