open! Core
open Blotto_kernel_lib

module T = struct
  module Query = struct
    type t = User_data.t [@@deriving sexp, bin_io, equal]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 1d92a697be5069a2867fd0d4daa96ef8 |}]
    ;;
  end

  module Response = struct
    type t = User_token.t [@@deriving sexp, bin_io, equal]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| d9a8da25d5656b016fb4dbdc2e4197fb |}]
    ;;
  end

  let rpc_name = "register_user"
end

include T
include Rpc_intf.Make (T)
