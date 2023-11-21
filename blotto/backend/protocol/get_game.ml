open! Core
open Blotto_kernel_lib

module T = struct
  module Query = struct
    type t = Game_id.t [@@deriving sexp, bin_io]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 86ba5df747eec837f0b391dd49f33f9e |}]
    ;;
  end

  module Response = struct
    type t = Game_info.t [@@deriving sexp, bin_io]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 79afd45ecf3e1c6f01bd432832fbd528 |}]
    ;;
  end

  let rpc_name = "get_game"
end

include T
include Rpc_intf.Make (T)
