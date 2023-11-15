open! Core

type t = string [@@deriving sexp, equal, compare, bin_io]

let email_regexp =
  Str.regexp
    {ext|^[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+\(\.[a-zA-Z0-9-]+\)*$|ext}
;;

let create str =
  if Str.string_match email_regexp str 0
  then Ok str
  else Or_error.error_s [%message "This is not a valid email address." str]
;;

let create_exn str = create str |> Or_error.ok_exn

let%expect_test "create" =
  let emails =
    [ "prawdziwy@email.com"
    ; "prawidzwy.email@naprawde.prawdziwy.com"
    ; "nie poprawny@email.com"
    ; "tezniepoprawny.com"
    ; "ten-chyba-tez@com"
    ]
    |> List.map ~f:create
  in
  print_s [%sexp (emails : t Or_error.t list)];
  [%expect
    {|
    ((Ok prawdziwy@email.com) (Ok prawidzwy.email@naprawde.prawdziwy.com)
     (Error ("This is not a valid email address." "nie poprawny@email.com"))
     (Error ("This is not a valid email address." tezniepoprawny.com))
     (Ok ten-chyba-tez@com)) |}]
;;

let to_string = Fn.id
