open! Core
open Blotto_kernel_lib

module T = struct
  module Query = struct
    type t =
      { game_id : Game_id.t
      ; token : User_token.t
      ; army : Army.t
      }
    [@@deriving sexp, bin_io, equal]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 165c25f7083a2094d0ef15429c1c5d6a |}]
    ;;
  end

  module Response = struct
    type t = unit [@@deriving sexp, bin_io, equal]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 86ba5df747eec837f0b391dd49f33f9e |}]
    ;;
  end

  let rpc_name = "submit_entry"
end

include T
include Rpc_intf.Make (T)
