include Composition_infix

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
  module Get_ui_scoreboard = Get_ui_scoreboard
  module Register_user = Register_user
  module User_info = User_info
  module Rpc_intf = Rpc_intf
end
