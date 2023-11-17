open! Core
open Blotto_kernel_lib

module T = struct
  module Query = struct
    type t = unit [@@deriving sexp, bin_io]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 86ba5df747eec837f0b391dd49f33f9e |}]
    ;;
  end

  module Response = struct
    type t = Game_info.t Game_id.Table.t [@@deriving sexp, bin_io]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| b68a6354b7f54348c472d91b4f551324 |}]
    ;;
  end

  let rpc_name = "get_games"
end

include T
include Rpc_intf.Make (T)
