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
    type t = Game_info.t [@@deriving sexp, bin_io, equal]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 5f9d29c47e2b2982a9c3cca08bb8cdd7 |}]
    ;;
  end

  let rpc_name = "get_game"
end

include T
include Rpc_intf.Make (T)
