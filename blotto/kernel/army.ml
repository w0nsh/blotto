open! Core

type t = int array [@@deriving sexp, bin_io, equal]

let length = 10
let soliders_cnt = 100

let create army =
  if Array.length army <> length
  then
    Or_error.error_s
      [%message "Army must have 10 elements" (Array.length army : int) (length : int)]
  else if not (Array.for_all army ~f:(fun x -> x >= 0 && x <= soliders_cnt))
  then
    Or_error.error_s
      [%message
        "Soliders count for every castle must be a non-negative integer smaller than the \
         maximal army size"
          (soliders_cnt : int)]
  else (
    let sum = Array.fold army ~init:0 ~f:Int.( + ) in
    if sum <> soliders_cnt
    then
      Or_error.error_s
        [%message "Invalid soliders number" (sum : int) (soliders_cnt : int)]
    else Ok army)
;;

let create_exn army = Or_error.ok_exn (create army)
let to_array = Fn.id

let fold2i army enemy_army ~f =
  let armies_zipped = Array.zip_exn army enemy_army in
  Array.foldi armies_zipped ~init:0 ~f:(fun i acc (a, b) -> f acc ~castle:(i + 1) ~a ~b)
;;

let%expect_test "create" =
  let army1 = create [| 1; 2; 3; 4; 5; 6; 7; 8; 9; 55 |]
  and army2 = create [| 1; 2; 3; 4; 5; 6; 7; 8; 9; 10 |]
  and army3 = create [| 101; 2; 3; 4; 5; 6; 7; 8; 9; 10 |]
  and army4 = create [| 1; 2; 3; 4; 5; 6; 7; 8; 9; 10; 11 |] in
  print_s [%sexp (army1 : t Or_error.t)];
  print_s [%sexp (army2 : t Or_error.t)];
  print_s [%sexp (army3 : t Or_error.t)];
  print_s [%sexp (army4 : t Or_error.t)];
  [%expect
    {|
    (Ok (1 2 3 4 5 6 7 8 9 55))
    (Error ("Invalid soliders number" (sum 55) (soliders_cnt 100)))
    (Error
     ("Soliders count for every castle must be a non-negative integer smaller than the maximal army size"
      (soliders_cnt 100)))
    (Error ("Army must have 10 elements" ("Array.length army" 11) (length 10))) |}]
;;

let%expect_test "fold2i" =
  let army1 = create_exn [| 1; 2; 3; 4; 5; 6; 7; 8; 9; 55 |]
  and army2 = create_exn [| 10; 10; 10; 10; 10; 10; 10; 10; 10; 10 |] in
  let f acc ~castle ~a ~b = acc + if a > b then castle else 0 in
  print_s [%sexp (fold2i army1 army2 ~f : int)];
  print_s [%sexp (fold2i army2 army1 ~f : int)];
  [%expect {|
    10
    45 |}]
;;
