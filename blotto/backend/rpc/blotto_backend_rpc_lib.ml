open Import

module Get_games = struct
  include Get_games
  include Rpc_intf.Make (Get_games)
end

module Submit_entry = struct
  include Submit_entry
  include Rpc_intf.Make (Submit_entry)
end

module Get_scoreboard = struct
  include Get_scoreboard
  include Rpc_intf.Make (Get_scoreboard)
end

module Register_user = struct
  include Register_user
  include Rpc_intf.Make (Register_user)
end

module Create_game = struct
  include Create_game
  include Rpc_intf.Make (Create_game)
end

module Update_game = struct
  include Update_game
  include Rpc_intf.Make (Update_game)
end

module Remove_game = struct
  include Remove_game
  include Rpc_intf.Make (Remove_game)
end

module List_users = struct
  include List_users
  include Rpc_intf.Make (List_users)
end
