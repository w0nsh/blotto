include struct
  open Blotto_backend_protocol_lib
  module Get_game = Get_game
  module Get_games = Get_games
  module Submit_entry = Submit_entry
  module Get_scoreboard = Get_scoreboard
  module Get_ui_scoreboard = Get_ui_scoreboard
  module Register_user = Register_user
  module Create_game = Create_game
  module Update_game = Update_game
  module Remove_game = Remove_game
  module List_users = List_users
  module User_info = User_info
end

include struct
  open Blotto_kernel_lib
  module User_token = User_token
  module User_data = User_data
  module Game = Game
  module Game_info = Game_info
  module Game_id = Game_id
  module Scoreboard = Scoreboard
  module Army = Army
  module Rule = Rule
  module Email = Email
  module Entry = Entry
end
