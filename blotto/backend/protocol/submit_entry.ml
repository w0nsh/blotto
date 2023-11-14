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
    module Result = struct
      type t =
        | Accepted
        | Rejected
      [@@deriving sexp, bin_io]
    end

    type t = Result.t Or_error.t [@@deriving sexp, bin_io]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| fef4bdef158b01eb8e3427afedf31731 |}]
    ;;
  end

  let rpc_name = "submit_entry"
end

include T
include Rpc_intf.Make (T)
