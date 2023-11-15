open! Core

module Kind = struct
  type t =
    | Basic
    | First_win_tripled
  [@@deriving sexp, bin_io, equal]
end

type t =
  { kind : Kind.t
  ; description : string
  }
[@@deriving sexp, bin_io, equal]

let basic = { kind = Basic; description = "Description of the basic rule." }

let first_win_tripled =
  { kind = First_win_tripled; description = "First won castle's score is tripled. " }
;;

let eval_basic army enemy_army =
  Army.fold2i army enemy_army ~f:(fun acc ~castle ~a ~b ->
    acc + if a > b then castle else 0)
;;

let eval_first_win_tripled army enemy_army =
  Army.fold2i army enemy_army ~f:(fun acc ~castle ~a ~b ->
    let score = if a <= b then 0 else if acc = 0 then 3 * castle else castle in
    acc + score)
;;

let eval t =
  match t.kind with
  | Basic -> eval_basic
  | First_win_tripled -> eval_first_win_tripled
;;

let%expect_test "eval" =
  let army1 = Army.create_exn [| 1; 2; 3; 4; 5; 6; 7; 8; 9; 55 |]
  and army2 = Army.create_exn [| 10; 10; 10; 10; 10; 10; 10; 10; 10; 10 |] in
  print_s [%sexp (eval basic army1 army2 : int)];
  print_s [%sexp (eval basic army2 army1 : int)];
  [%expect {|
    10
    45 |}];
  print_s [%sexp (eval first_win_tripled army1 army2 : int)];
  print_s [%sexp (eval first_win_tripled army2 army1 : int)];
  [%expect {|
    30
    47 |}]
;;
