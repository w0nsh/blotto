open! Core
open Blotto_kernel_lib

module T = struct
  module Query = struct
    type t = Game_id.t [@@deriving sexp, bin_io]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| d9a8da25d5656b016fb4dbdc2e4197fb |}]
    ;;
  end

  module Response = struct
    module Result = struct
      type t =
        { id : Game_id.t
        ; game : Game.t
        }
      [@@deriving sexp, bin_io]
    end

    type t = Result.t Or_error.t [@@deriving sexp, bin_io]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 89b87d429d685ec6ecfe3008150c676c |}]
    ;;
  end

  let rpc_name = "create_game"
end

include T
include Rpc_intf.Make (T)
