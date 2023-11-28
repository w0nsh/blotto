open! Core
open Blotto_kernel_lib

module T = struct
  module Query = struct
    type t =
      { game_id : Game_id.t
      ; game : Game.t
      }
    [@@deriving sexp, bin_io, equal]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 06cb57b82703214f943557d9ee99e948 |}]
    ;;
  end

  module Response = struct
    type t = unit [@@deriving sexp, bin_io, equal]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 86ba5df747eec837f0b391dd49f33f9e |}]
    ;;
  end

  let rpc_name = "create_game"
end

include T
include Rpc_intf.Make (T)
