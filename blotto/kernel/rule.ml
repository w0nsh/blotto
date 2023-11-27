open! Core

module Kind = struct
  type t =
    | Basic
    | First_win_tripled
    | Half_survivors_proceed_to_next_castle
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

let half_survivors_proceed_to_next_castle =
  { kind = Half_survivors_proceed_to_next_castle
  ; description =
      "Tym razem żołnierze wykazują się szczególną odwagą i determinacją. Żołnierze, \
       którzy zdobyli daną twierdzę, w części przechodzą do następnej twierdzy pomóc \
       swoim sprzymierzeńcom. Konkretniej, jeżeli w i-tym zamku walczyło A żołnierzy \
       przeciwko B oraz A > B, to pierwszy zastęp zdobywa i-tą twierdzę, a do tego \
       spośród A - B żołnierzy pierwszego zastępu, którzy pozostali przy życiu, sufit z \
       połowy ich liczby ((A-B + 1) / 2) jest w stanie walczyć o zamek o numerze \
       i+1-wszym wraz z zastępem, który został tam początkowo wysłany. Dla przykładu, \
       jeżeli Alicja wyśle następujące zastępy: 15, 8, 3, 4, 5, 6, 7, 8, 37, 7, a Robert \
       wyśle zastępy 10, 10, 10, 10, 10, 10, 10, 10, 10, 10, to Alicja wygrywa twierdzę \
       pierwszą, spośród 5 żołnierzy, którzy przeżyli, 3 pomaga pozostałym 8 w drugiej \
       twierdzy i razem odpierają 10 żołnierzy Roberta, zatem Alicja również wygrywa \
       twierdzę 2. Ostateczny wynik Alicji w tym wypadku to 22, a Roberta to 33.\n"
  }
;;

let eval_basic army enemy_army =
  Army.fold2i army enemy_army ~init:0 ~f:(fun acc ~castle ~a ~b ->
    acc + if a > b then castle else 0)
;;

let eval_first_win_tripled army enemy_army =
  Army.fold2i army enemy_army ~init:0 ~f:(fun acc ~castle ~a ~b ->
    let score = if a <= b then 0 else if acc = 0 then 3 * castle else castle in
    acc + score)
;;

let eval_survivors_proceed_to_next_castle army enemy_army =
  let score, _, _ =
    Army.fold2i
      army
      enemy_army
      ~init:(0, 0, 0)
      ~f:(fun (score, a_survivors, b_survivors) ~castle ~a ~b ->
        let a = a_survivors + a
        and b = b + b_survivors in
        ( (score + if a > b then castle else 0)
        , max 0 (a - b + 1) / 2
        , max 0 (b - a + 1) / 2 ))
  in
  score
;;

let eval t =
  match t.kind with
  | Basic -> eval_basic
  | First_win_tripled -> eval_first_win_tripled
  | Half_survivors_proceed_to_next_castle -> eval_survivors_proceed_to_next_castle
;;

let arg_type =
  Command.Arg_type.create (fun str ->
    match Kind.of_string str with
    | Basic -> basic
    | First_win_tripled -> first_win_tripled
    | Half_survivors_proceed_to_next_castle -> half_survivors_proceed_to_next_castle)
;;

let%expect_test "eval" =
  let army1 = Army.create_exn [| 15; 8; 3; 4; 5; 6; 7; 8; 37; 7 |]
  and army2 = Army.create_exn [| 10; 10; 10; 10; 10; 10; 10; 10; 10; 10 |] in
  print_s [%sexp (eval basic army1 army2 : int)];
  print_s [%sexp (eval basic army2 army1 : int)];
  [%expect {|
    10
    45 |}];
  print_s [%sexp (eval first_win_tripled army1 army2 : int)];
  print_s [%sexp (eval first_win_tripled army2 army1 : int)];
  [%expect {|
    12
    49 |}];
  print_s [%sexp (eval half_survivors_proceed_to_next_castle army1 army2 : int)];
  print_s [%sexp (eval half_survivors_proceed_to_next_castle army2 army1 : int)];
  [%expect {|
    22
    33 |}]
;;
