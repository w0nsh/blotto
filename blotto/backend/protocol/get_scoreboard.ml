open! Core
open Blotto_kernel_lib

module T = struct
  module Query = struct
    type t = Game_id.t [@@deriving sexp, bin_io, equal]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| d9a8da25d5656b016fb4dbdc2e4197fb |}]
    ;;
  end

  module Response = struct
    type t = Scoreboard.t [@@deriving sexp, bin_io, equal]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 42eabc9c69a45bcc932353b7e80aacee |}]
    ;;
  end

  let rpc_name = "get_scoreboard"
end

include T
include Rpc_intf.Make (T)
