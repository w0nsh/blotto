open! Core

module Kind = struct
  type t =
    | Basic
    | First_win_tripled
  [@@deriving sexp, bin_io, equal]

  let of_string str = Sexp.of_string str |> t_of_sexp
end

type t =
  { kind : Kind.t
  ; description : string
  }
[@@deriving sexp, bin_io, equal]

let description { description; _ } = description

let basic =
  { kind = Basic
  ; description =
      "Klasyczna wersja gry. Dwa wojska walczą o każdą twierdzę. Gracz zdobywa\n\
       daną twierdzę tylko wtedy, kiedy atakuje ją ściśle większym zastępem żołnierzy.\n\
       Wynik pojedynczego pojedynku to suma numerów zdobytych twierdz."
  }
;;

let first_win_tripled =
  { kind = First_win_tripled
  ; description =
      "W tej wersji gry wynik pojedynku liczymy dokładnie tak samo, jak w klasycznej\n\
      \  wersji, ale do tego wartość twierdzy o najmniejszym numerze zdobytej przez \
       zawodnika\n\
      \  liczy się trzykrotnie! Dla przykładu, jeśli zawodnik nie zdobędzie pierwszej \
       oraz drugiej\n\
      \  twierdzy, ale zdobędzie trzecią, to do jego wyniku zostanie dodane 9 zamiast 3."
  }
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

let arg_type =
  Command.Arg_type.create (fun str ->
    match Kind.of_string str with
    | Basic -> basic
    | First_win_tripled -> first_win_tripled)
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
