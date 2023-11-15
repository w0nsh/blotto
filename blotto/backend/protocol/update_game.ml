open! Core
open Blotto_kernel_lib

module T = struct
  module Query = struct
    type t =
      { id : Game_id.t
      ; start_date : Time_ns.Alternate_sexp.t option [@sexp.option]
      ; end_date : Time_ns.Alternate_sexp.t option [@sexp.option]
      ; allowed_tokens : Game.Allowed_users.t option [@sexp.option]
      ; rule_description : string option [@sexp.option]
      }
    [@@deriving sexp, bin_io]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 59da0922be056a3794b0d2a1313a8649 |}]
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

  let rpc_name = "update_game"
end

include T
include Rpc_intf.Make (T)
