open! Core

module Kind = struct
  type t =
    | Basic
    | First_win_tripled
    | Half_survivors_proceed_to_next_castle
    | Funky_grid
    | Crush_or_lose
    | Binary_tree
    | Binary_balls_of_power
  [@@deriving sexp, bin_io, equal]

  let of_string str = Sexp.of_string str |> t_of_sexp
end

type t =
  { kind : Kind.t
  ; description : string
  }
[@@deriving sexp, bin_io, equal, fields ~getters]

let basic =
  { kind = Basic
  ; description =
      "Klasyczna wersja gry. Dwa wojska walczą o każdą twierdzę. Gracz zdobywa daną \
       twierdzę tylko wtedy, kiedy atakuje ją ściśle większym zastępem żołnierzy. Wynik \
       pojedynczego pojedynku to suma numerów zdobytych twierdz."
  }
;;

let first_win_tripled =
  { kind = First_win_tripled
  ; description =
      "W tej wersji gry wynik pojedynku liczymy dokładnie tak samo, jak w klasycznej \
       wersji, ale do tego wartość twierdzy o najmniejszym numerze zdobytej przez \
       zawodnika liczy się trzykrotnie! Dla przykładu, jeśli zawodnik nie zdobędzie \
       pierwszej oraz drugiej twierdzy, ale zdobędzie trzecią, to do jego wyniku \
       zostanie dodane 9 zamiast 3."
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
       jeżeli Alicja wyśle następujące zastępy:\n\
      \     15,  8,  3,  4,  5,  6,  7,  8, 37,  7,\n\
       a Robert wyśle zastępy\n\
      \     10, 10, 10, 10, 10, 10, 10, 10, 10, 10,\n\
       to Alicja wygrywa twierdzę pierwszą, spośród 5 żołnierzy, którzy przeżyli, 3 \
       pomaga pozostałym 8 w drugiej twierdzy i razem odpierają 10 żołnierzy Roberta, \
       zatem Alicja również wygrywa twierdzę 2. Ostateczny wynik Alicji w tym wypadku to \
       22, a Roberta to 33."
  }
;;

let funky_grid =
  { kind = Funky_grid
  ; description =
      "W tej wersji gry znaczenie ma położenie geograficzne zamków, które wygląda \
       następująco:\n\n\
      \     2  10   3\n\
      \     8   1   9\n\
      \     4   7   5\n\
      \         6  \n\n\
       Kiedy żołnierze zdobędą zamek, jego wynik jest pomnożony przez liczbę zdobytych \
       sąsiednich zamków (na wschód, zachód, północ, południe). Dla przykładu, jeżeli \
       Alicja obierze strategię\n\
      \      0, 20, 20, 20, 20, 20,  0,  0,  0,  0,\n\
       a Robert\n\
      \     20,  0,  0,  0,  0,  0, 20, 20, 20, 20,\n\
       to Alicja nie zdobędzie żadnych punktów, a Robert zdobędzie 4 punkty za zamek 1 \
       oraz 7 + 8 + 9 + 10 = 34 punktów za zamki 7, 8, 9, 10."
  }
;;

let crush_or_lose =
  { kind = Crush_or_lose
  ; description =
      "Podczas ostatecznego starcia los sprzyja słabszym. Jeżeli żadna z armii \
       przydzielonych do zamku nie jest dwa razy większa od armii przeciwnej, zamek \
       zdobywa armia mniejsza (w przypadku remisu wciąż nie wygrywa nikt). Wygrana co \
       najmniej dwa razy większą armią podnosi morale, więc zamek zdobyty w ten sposób \
       jest warty dwa razy więcej niż zwykle. Dla przykładu, jeżeli Alicja obierze \
       strategię\n\
      \      0,  0,  0,  0,  0,  0,  1,  6, 80,  9,\n\
       a Robert\n\
      \      0,  0,  0,  0,  0,  0,  0,  6, 40,  5,\n\
       to Alicja zdobędzie 14 + 18 = 32 punkty, a Robert 10 punktów."
  }
;;

let binary_tree =
  { kind = Binary_tree
  ; description =
      {|W tej wersji gry zamki ustawione są w węzłach 10-elementowego drzewa binarnego:

                              10
                            /    \
                           8      9
                          / \    / \
                         6   7  4   5
                        / \   \
                       1   2   3

Walki odbywają się po kolei, w zamkach od 1 do 10. Jednakże, jak wiadomo, morale żołnierzy są kluczowe w wygrywaniu walki. Żołnierze uciekną z danego zamku, jeżeli sojusznicza armia nie wygrała w żadnym z dzieci węzła, w którym znajduje ten zamek. Przykładowo, jeżli armia Alicji przegra w zamkach 1 i 2 (tj. będzie tam miała odpowiednio mniej żołnierzy, niż armia Roberta), to żołenierze z zamku 6 uciekną i Alicja na pewno nie zdobędzie tego zamku (Robert wtedy ma gwarantowaną wygraną w tym zamku, o ile ustawił w nim niezerową liczbę żołnierzy).

Dla przykładu, jeżeli Alicja obierze strategię
      15,  8,  3,  4, 15,  6,  7,  8, 27,  7,
a Robert
       1, 23, 10, 10, 10,  6, 10, 10, 10, 10,
to Alicja zdobędzie 15 punktów, a Robert 34.
|}
  }
;;

let binary_balls_of_power =
  { kind = Binary_balls_of_power
  ; description =
      {|W tej wersji gry żołnierze zastąpieni są przez potężnych binarnych magów, a walka odbywa się n!-wymiarowej kwantowej przestrzeni międzystrunowej. Zastępy magów obu armi ścierają się jak zwykle w 10 zamkach, jednakże walka toczy się w świecie poza pojęciem zwykłych śmiertelników. Celem obu armi jest zdobycie ośmiu magicznych gwiezdnych kuli mocy. Kule występują w parach zero-jedynkowych, na jednej z czterech spektralnych superpozycji: zerowej, pierwszej, drugiej lub trzeciej.

Magowie ustawieni w zamku o numerze i mają dostęp do kul, których pozycja odpowiada zapisowi binarnemu liczby i. Przykładowo, magowie z twierdzy 5 są w stanie walczyć o kulę zerową w pozycji trzeciej, kulę jedynkową w pozycji drugiej, kulę zerową w pozycji pierwszej oraz kulę jedynkową w pozycji zerowej. Magowie są wstanie rozdystrybuować swoje siły jedenakowo między wszystkie z dostępnych im kul.

Siła, z jaką Twoja armia walczy o daną kulę, można opisać jako **iloczyn** liczby magów w twierdzach, z których istnieje dostęp do tej kuli. Przykładowo, do walki o kulę jedynkową w pozycji pierwszej będą walczyć magowie z twierdz 2, 3, 6, 7 oraz 10, a o kulę zerową na pozycji trzeciej magowie z twierdz 1, 2, 3, 4, 5, 6 oraz 7.

Wartości kul opisane są w poniższej tabeli, gdzie wiersz wyznacza czy kula jest zerowa czy jedynkowa, a kolumna oznacza jej pozycję:

                 +----+----+----+----+
                 | 0  | 1  | 2  | 3  |
            +----+----+----+----+----+
            | 0  | 10 | 15 | 18 | 31 |
            +----+----+----+----+----+
            | 1  | 12 | 19 | 25 | 43 |
            +----+----+----+----+----+

Kulę zdobywa armia magów, których siła jest ściśle większa od siły armii przeciwnika (w przypaku remisów kula nie wytrzymuje równomiernego przeciążenia z obu stron i następuje jej doszczętna międzywymiarowa dezintegracja).

Przykładowo, jeżeli Alicja rozstawi magów w następujący sposób:
      15,  8,  3,  4, 15,  6,  7,  8, 27,  7,
a Robert
       1, 23, 10, 10, 10,  6, 10, 10, 10, 10,
to Alicja zdobędzie 88 punktów, a Robert 85.

W tym przykładzie w walce o zerową kulę pierwszej pozycji, siła armii Alicji wynosi 194400, a Roberta 10000.


       Powodzenia, niech kule mocy będą z Tobą.
|}
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

let eval_funky_grid army enemy_army =
  let army = Army.to_array army in
  let enemy_army = Army.to_array enemy_army in
  let is_taken castle = army.(castle - 1) > enemy_army.(castle - 1) in
  let count_taken castles = List.count castles ~f:is_taken in
  let adjacent =
    [ 1, [ 7; 8; 9; 10 ]
    ; 2, [ 8; 10 ]
    ; 3, [ 9; 10 ]
    ; 4, [ 7; 8 ]
    ; 5, [ 7; 9 ]
    ; 6, [ 7 ]
    ; 7, [ 1; 4; 5; 6 ]
    ; 8, [ 1; 2; 4 ]
    ; 9, [ 1; 3; 5 ]
    ; 10, [ 1; 2; 3 ]
    ]
  in
  List.fold adjacent ~init:0 ~f:(fun acc (castle, adj) ->
    let cur_score = if is_taken castle then castle * count_taken adj else 0 in
    cur_score + acc)
;;

let eval_crush_or_lose army enemy_army =
  Army.fold2i army enemy_army ~init:0 ~f:(fun acc ~castle ~a ~b ->
    acc
    + if a > b && a >= 2 * b then 2 * castle else if a < b && b < 2 * a then castle else 0)
;;

let eval_binary_tree army enemy_army =
  let can_fight castle won =
    let exists x = List.exists ~f:(Int.equal x) won in
    match castle with
    | _ when castle <= 5 -> true
    | 6 -> exists 1 || exists 2
    | 7 -> exists 3
    | 8 -> exists 6 || exists 7
    | 9 -> exists 4 || exists 5
    | 10 -> exists 8 || exists 9
    | _ -> failwith "Won't happen"
  in
  Army.fold2i army enemy_army ~init:([], []) ~f:(fun (won_a, won_b) ~castle ~a ~b ->
    let a = if can_fight castle won_a then a else 0 in
    let b = if can_fight castle won_b then b else 0 in
    match Int.compare a b with
    | 1 -> castle :: won_a, won_b
    | 0 -> won_a, won_b
    | -1 -> won_a, castle :: won_b
    | _ -> failwith "wont happen")
  |> Tuple2.get1
  |> List.fold ~init:0 ~f:( + )
;;

let eval_binary_balls_of_power army enemy_army =
  let balls =
    [ 10, [ 2; 4; 6; 8; 10 ]
    ; 12, [ 1; 3; 5; 7; 9 ]
    ; 15, [ 1; 4; 5; 8; 9 ]
    ; 19, [ 2; 3; 6; 7; 10 ]
    ; 18, [ 1; 2; 3; 8; 9; 10 ]
    ; 25, [ 4; 5; 6; 7 ]
    ; 31, [ 1; 2; 3; 4; 5; 6; 7 ]
    ; 43, [ 8; 9; 10 ]
    ]
  in
  let strength castles army =
    Army.to_array army
    |> Array.to_list
    |> List.filteri ~f:(fun i _ -> List.exists castles ~f:(Int.equal (i + 1)))
    |> List.fold ~init:1 ~f:( * )
  in
  List.map balls ~f:(fun (ball, castles) ->
    let a = strength castles army in
    let b = strength castles enemy_army in
    if a > b then ball else 0)
  |> List.fold ~init:0 ~f:( + )
;;

let eval t =
  match t.kind with
  | Basic -> eval_basic
  | First_win_tripled -> eval_first_win_tripled
  | Half_survivors_proceed_to_next_castle -> eval_survivors_proceed_to_next_castle
  | Funky_grid -> eval_funky_grid
  | Crush_or_lose -> eval_crush_or_lose
  | Binary_tree -> eval_binary_tree
  | Binary_balls_of_power -> eval_binary_balls_of_power
;;

let arg_type =
  Command.Arg_type.create (fun str ->
    match Kind.of_string str with
    | Basic -> basic
    | First_win_tripled -> first_win_tripled
    | Half_survivors_proceed_to_next_castle -> half_survivors_proceed_to_next_castle
    | Funky_grid -> funky_grid
    | Binary_tree -> binary_tree
    | Crush_or_lose -> crush_or_lose
    | Binary_balls_of_power -> binary_balls_of_power)
;;

let%expect_test "eval" =
  let army1 = Army.create_exn [| 15; 8; 3; 4; 15; 6; 7; 8; 27; 7 |]
  and army2 = Army.create_exn [| 1; 23; 10; 10; 10; 6; 10; 10; 10; 10 |] in
  print_s [%sexp (eval basic army1 army2 : int)];
  print_s [%sexp (eval basic army2 army1 : int)];
  [%expect {|
    15
    34 |}];
  print_s [%sexp (eval first_win_tripled army1 army2 : int)];
  print_s [%sexp (eval first_win_tripled army2 army1 : int)];
  [%expect {|
    17
    38 |}];
  print_s [%sexp (eval half_survivors_proceed_to_next_castle army1 army2 : int)];
  print_s [%sexp (eval half_survivors_proceed_to_next_castle army2 army1 : int)];
  [%expect {|
    20
    35 |}];
  print_s [%sexp (eval funky_grid army1 army2 : int)];
  print_s [%sexp (eval funky_grid army2 army1 : int)];
  [%expect {|
    24
    58 |}];
  print_s [%sexp (eval crush_or_lose army1 army2 : int)];
  print_s [%sexp (eval crush_or_lose army2 army1 : int)];
  [%expect {|
      45
      23 |}];
  print_s [%sexp (eval binary_tree army1 army2 : int)];
  print_s [%sexp (eval binary_tree army2 army1 : int)];
  [%expect {|
    15
    34 |}];
  print_s [%sexp (eval binary_balls_of_power army1 army2 : int)];
  print_s [%sexp (eval binary_balls_of_power army2 army1 : int)];
  [%expect {|
    88
    85 |}]
;;
