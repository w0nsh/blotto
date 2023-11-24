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
    type t = Ui_entry.t list [@@deriving sexp, bin_io]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| e74aafc374eebfc9c11539fbb46320b5 |}]
    ;;
  end

  let rpc_name = "get_ui_scoreboard"
end

include T
include Rpc_intf.Make (T)
