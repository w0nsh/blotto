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
      [%expect {| a9158c45d369efd378ead5c7344c2571 |}]
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
      [%expect {| f460ea942c39e36ca77fe487f66596c5 |}]
    ;;
  end

  let rpc_name = "update_game"
end

include T
include Rpc_intf.Make (T)
