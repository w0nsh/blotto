open! Core
open Blotto_kernel_lib

module T = struct
  module Query = struct
    type t = Game_id.t [@@deriving sexp, bin_io]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| d9a8da25d5656b016fb4dbdc2e4197fb |}]
    ;;
  end

  module Response = struct
    type t = unit [@@deriving sexp, bin_io]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 27f76252e5181aab209cd62aa6e42268 |}]
    ;;
  end

  let rpc_name = "remove_game"
end

include T
include Rpc_intf.Make (T)
