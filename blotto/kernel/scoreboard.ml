open! Core

type t = (Army.t * float) User_token.Table.t [@@deriving sexp, bin_io, equal]

let user_score token entry eval entries =
  let sum =
    List.fold entries ~init:0 ~f:(fun sum (enemy_token, enemy_entry) ->
      if User_token.equal token enemy_token then sum else eval entry enemy_entry + sum)
  in
  Float.of_int sum /. Float.of_int (List.length entries - 1)
;;

let create ~entries ~eval =
  let scoreboard = User_token.Table.create () in
  List.iter entries ~f:(fun (token, entry) ->
    let score = user_score token entry eval entries in
    Hashtbl.set scoreboard ~key:token ~data:(entry, score));
  scoreboard
;;

let to_list t = Hashtbl.to_alist t |> List.map ~f:(fun (a, (b, c)) -> a, b, c)

let%expect_test "create" =
  let tokens = List.map [ "tok-a"; "tok-b"; "tok-c"; "tok-d" ] ~f:User_token.create_exn in
  let armies =
    List.map
      [ [| 1; 2; 3; 4; 5; 6; 7; 8; 9; 55 |]
      ; [| 10; 10; 10; 10; 10; 10; 10; 10; 10; 10 |]
      ; [| 55; 9; 8; 7; 6; 5; 4; 3; 2; 1 |]
      ; [| 0; 20; 0; 20; 0; 20; 0; 20; 0; 20 |]
      ]
      ~f:Army.create_exn
  in
  let eval army enemy_army =
    Army.fold2i army enemy_army ~init:0 ~f:(fun acc ~castle ~a ~b ->
      acc + if a > b then castle else 0)
  in
  let scoreboard = create ~entries:(List.zip_exn tokens armies) ~eval in
  print_s [%sexp (scoreboard : t)];
  [%expect
    {|
    ((tok-a ((1 2 3 4 5 6 7 8 9 55) 28.333333333333332))
     (tok-b ((10 10 10 10 10 10 10 10 10 10) 41.333333333333336))
     (tok-c ((55 9 8 7 6 5 4 3 2 1) 13.666666666666666))
     (tok-d ((0 20 0 20 0 20 0 20 0 20) 26.666666666666668))) |}]
;;
