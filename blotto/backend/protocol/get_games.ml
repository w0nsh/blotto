open! Core
open Blotto_kernel_lib

module T = struct
  module Query = struct
    type t = unit [@@deriving sexp, bin_io, equal]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 86ba5df747eec837f0b391dd49f33f9e |}]
    ;;
  end

  module Response = struct
    type t = Game_info.t Game_id.Table.t [@@deriving sexp, bin_io, equal]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 537a9078bcd83c5d26cb90bb79a50a36 |}]
    ;;
  end

  let rpc_name = "get_games"
end

include T
include Rpc_intf.Make (T)
