open! Core

module Allowed_users = struct
  type t =
    | Any
    | Users of User_token.Set.t
  [@@deriving sexp, bin_io, equal]
end

type t =
  { info : Game_info.t
  ; allowed_users : Allowed_users.t
  ; entries : Army.t User_token.Table.t
  }
[@@deriving sexp, bin_io, equal, fields ~getters]

let create ~name ~description ~start_date ~end_date ~allowed_users ~rule =
  if Time_ns_fix.( > ) start_date end_date
  then
    Or_error.error_s
      [%message
        "Start date must be before end date."
          (start_date : Time_ns_fix.t)
          (end_date : Time_ns_fix.t)]
  else
    Ok
      { info = { name; description; start_date; end_date; rule }
      ; allowed_users
      ; entries = User_token.Table.create ()
      }
;;

let update_entry t ~token ~army = Hashtbl.update t.entries token ~f:(fun _ -> army)

let%expect_test "create" =
  let game1 =
    create
      ~name:"Game 1"
      ~description:"Some description of the rules."
      ~start_date:Time_ns_fix.min_value_representable
      ~end_date:Time_ns_fix.max_value_representable
      ~allowed_users:Any
      ~rule:Rule.basic
  in
  let game2 =
    create
      ~name:"Game 2"
      ~description:"Some description of the rules."
      ~start_date:Time_ns_fix.max_value_representable
      ~end_date:Time_ns_fix.min_value_representable
      ~allowed_users:Any
      ~rule:Rule.basic
  in
  print_s [%sexp (game1 : t Or_error.t)];
  print_s [%sexp (game2 : t Or_error.t)];
  [%expect
    {|
    (Ok
     ((info
       ((name "Game 1") (description "Some description of the rules.")
        (start_date "1823-11-12 00:06:21.572612096Z")
        (end_date "2116-02-20 23:53:38.427387903Z")
        (rule
         ((kind Basic)
          (description
            "Klasyczna wersja gry. Dwa wojska walcz\196\133 o ka\197\188d\196\133 twierdz\196\153. Gracz zdobywa\
           \ndan\196\133 twierdz\196\153 tylko wtedy, kiedy atakuje j\196\133 \197\155ci\197\155le wi\196\153kszym zast\196\153pem \197\188o\197\130nierzy.\
           \nWynik pojedynczego pojedynku to suma numer\195\179w zdobytych twierdz.")))))
      (allowed_users Any) (entries ())))
    (Error
     ("Start date must be before end date."
      (start_date "2116-02-20 23:53:38.427387903Z")
      (end_date "1823-11-12 00:06:21.572612096Z"))) |}];
  let game = Or_error.ok_exn game1 in
  let token1 = User_token.create_exn "first-token"
  and token2 = User_token.create_exn "second-token" in
  let army1 = Army.create_exn [| 1; 2; 3; 4; 5; 6; 7; 8; 9; 55 |]
  and army2 = Army.create_exn [| 10; 10; 10; 10; 10; 10; 10; 10; 10; 10 |] in
  update_entry game ~token:token1 ~army:army1;
  update_entry game ~token:token2 ~army:army2;
  print_s [%sexp (game1 : t Or_error.t)];
  [%expect
    {|
    (Ok
     ((info
       ((name "Game 1") (description "Some description of the rules.")
        (start_date "1823-11-12 00:06:21.572612096Z")
        (end_date "2116-02-20 23:53:38.427387903Z")
        (rule
         ((kind Basic)
          (description
            "Klasyczna wersja gry. Dwa wojska walcz\196\133 o ka\197\188d\196\133 twierdz\196\153. Gracz zdobywa\
           \ndan\196\133 twierdz\196\153 tylko wtedy, kiedy atakuje j\196\133 \197\155ci\197\155le wi\196\153kszym zast\196\153pem \197\188o\197\130nierzy.\
           \nWynik pojedynczego pojedynku to suma numer\195\179w zdobytych twierdz.")))))
      (allowed_users Any)
      (entries
       ((first-token (1 2 3 4 5 6 7 8 9 55))
        (second-token (10 10 10 10 10 10 10 10 10 10)))))) |}]
;;
