open! Core
open Blotto_kernel_lib

module T = struct
  module Query = struct
    type t =
      { game_id : Game_id.t
      ; game : Game.t
      }
    [@@deriving sexp, bin_io]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| ef2522b189908ea8a8df7fbcf7f45c12 |}]
    ;;
  end

  module Response = struct
    type t = unit Or_error.t [@@deriving sexp, bin_io]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 27f76252e5181aab209cd62aa6e42268 |}]
    ;;
  end

  let rpc_name = "create_game"
end

include T
include Rpc_intf.Make (T)
