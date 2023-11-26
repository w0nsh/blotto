open! Core
open Blotto_kernel_lib

module T = struct
  module Query = struct
    type t =
      { id : Game_id.t
      ; name : string option [@sexp.option]
      ; description : string option [@sexp.option]
      ; start_date : Time_ns_fix.t option [@sexp.option]
      ; end_date : Time_ns_fix.t option [@sexp.option]
      ; allowed_users : Game.Allowed_users.t option [@sexp.option]
      ; rule : Rule.t option [@sexp.option]
      }
    [@@deriving sexp, bin_io, equal]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 22287af22bf95257e3648246deb6a6b7 |}]
    ;;
  end

  module Response = struct
    type t =
      { id : Game_id.t
      ; game : Game.t
      }
    [@@deriving sexp, bin_io, equal]

    let%expect_test _ =
      print_endline [%bin_digest: t];
      [%expect {| 3368c56d0b3796831ed4206adce22541 |}]
    ;;
  end

  let rpc_name = "update_game"
end

include T
include Rpc_intf.Make (T)
