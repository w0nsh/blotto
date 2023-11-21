include struct
  open Async_rpc_kernel
  module Persistent_connection = Persistent_connection
end

include struct
  open Blotto_frontend_protocol_lib
  module Route = Route
end

include struct
  open Blotto_backend_protocol_lib
  module Get_game = Get_game
  module Get_games = Get_games
  module Submit_entry = Submit_entry
  module Get_scoreboard = Get_scoreboard
  module Register_user = Register_user
  module Create_game = Create_game
  module Update_game = Update_game
  module Remove_game = Remove_game
  module List_users = List_users
  module User_info = User_info
  module Rpc_intf = Rpc_intf
end
