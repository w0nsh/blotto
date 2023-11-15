open! Core
open Import

type t = { random_state : Random.State.t }

let words = String.split ~on:'\n' Embedded_files.words_dot_txt

let init ?seed () =
  let random_state =
    match seed with
    | None -> Random.State.make_self_init ()
    | Some seed -> Random.State.make [| seed |]
  in
  { random_state }
;;

let get_token t ~num_words =
  let words_length = List.length words in
  List.init num_words ~f:(fun _ -> Random.State.int t.random_state words_length)
  |> List.map ~f:(fun i -> List.nth_exn words i |> String.lowercase)
  |> String.concat ~sep:"-"
  |> User_token.create_exn
;;

let%expect_test "generate-token-test" =
  let generator = init ~seed:2137 () in
  let tokens = List.init 10 ~f:(fun _ -> get_token generator ~num_words:3) in
  print_s [%sexp (tokens : User_token.t list)];
  [%expect
    {|
    (senate-yes-jewish goal-flame-language medium-every-marketing
     involved-photograph-repeatedly description-characteristic-remarkable
     still-handle-grandfather modern-achieve-of think-store-complicated
     legal-advertising-business responsibility-reflection-marketing) |}]
;;
