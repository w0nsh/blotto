open! Core

type t =
  { name : string
  ; surname : string
  ; email : Email.t
  }
[@@deriving sexp, compare, equal, fields ~getters]

let name_regexp = Str.regexp {|^[A-Z][a-z,ą,ę,ć,ź,ś,ł,ó,ń,ż]*$|}

let create ~name ~surname ~email =
  if not (Str.string_match name_regexp name 0)
  then
    Or_error.error_s
      [%message "Illegal name, first letter should be capitalize, only one word." name]
  else if not (Str.string_match name_regexp surname 0)
  then
    Or_error.error_s
      [%message
        "Illegal surname, first letter should be capitalize, only one word." surname]
  else (
    let%map.Or_error email = Email.create email in
    { name; surname; email })
;;

let%expect_test "create" =
  let data1 = create ~name:"Franciszek" ~surname:"Truskawka" ~email:"prawdziwy@email.com"
  and data2 = create ~name:"Franciszek" ~surname:"truskawka" ~email:"prawdziwy@email.com"
  and data3 = create ~name:"Franc iszek" ~surname:"Truskawka" ~email:"prawdziwy@email.com"
  and data4 =
    create ~name:"Franciszek" ~surname:"Truskawka" ~email:"prawdziwyemail.com"
  in
  print_s [%sexp (data1 : t Or_error.t)];
  print_s [%sexp (data2 : t Or_error.t)];
  print_s [%sexp (data3 : t Or_error.t)];
  print_s [%sexp (data4 : t Or_error.t)];
  [%expect
    {|
    (Ok ((name Franciszek) (surname Truskawka) (email prawdziwy@email.com)))
    (Error
     ("Illegal surname, first letter should be capitalize, only one word."
      truskawka))
    (Error
     ("Illegal name, first letter should be capitalize, only one word."
      "Franc iszek"))
    (Error ("This is not a valid email address." prawdziwyemail.com)) |}]
;;
