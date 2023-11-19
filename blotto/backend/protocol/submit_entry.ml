open! Core
open Blotto_kernel_lib

module T = struct
  module Query = struct
    type t =
      { game_id : Game_id.t
      ; token : User_token.t
      ; army : Army.t
      }
    [@@deriving sexp, bin_io]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 165c25f7083a2094d0ef15429c1c5d6a |}]
    ;;
  end

  module Response = struct
    type t = unit [@@deriving sexp, bin_io]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 27f76252e5181aab209cd62aa6e42268 |}]
    ;;
  end

  let rpc_name = "submit_entry"
end

include T
include Rpc_intf.Make (T)
