open! Core

module T = struct
  include
    String_id.Make
      (struct
        let module_name = "Game_id"
      end)
      ()
end

include T
include Hashable.Make_binable (T)

let arg_type = Command.Arg_type.create of_string
