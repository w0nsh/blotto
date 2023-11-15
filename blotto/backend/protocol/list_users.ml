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
    type t = User_info.t User_token.Table.t Or_error.t [@@deriving sexp, bin_io]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 36084dc999b60dab962cd03b6078d285 |}]
    ;;
  end

  let rpc_name = "list_users"
end

include T
include Rpc_intf.Make (T)
