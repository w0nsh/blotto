open! Core

type t =
  { name : string
  ; email : Email.t
  }
[@@deriving sexp, compare, equal, fields ~getters, bin_io]

let name_regexp =
  Str.regexp
    {|^[a-zA-ZàáâäãåąčćęèéêëėįìíîïłńòóôöõøùúûüųūÿýżźñçčšžÀÁÂÄÃÅĄĆČĖĘÈÉÊËÌÍÎÏĮŁŃÒÓÔÖÕØÙÚÛÜŲŪŸÝŻŹÑßÇŒÆČŠŽ∂ð ,.'-]+$|}
;;

let create ~name ~email =
  if not (Str.string_match name_regexp name 0)
  then
    Or_error.error_s
      [%message
        "Illegal name, first letters should be capitalize, only letters and hyphens." name]
  else (
    let%map.Or_error email = Email.create email in
    { name; email })
;;

let create_exn ~name ~email = create ~name ~email |> Or_error.ok_exn

let%expect_test "create" =
  let data1 = create ~name:"Franciszek" ~email:"prawdziwy@email.com"
  and data2 = create ~name:"Franciszek truskawka" ~email:"prawdziwy@email.com"
  and data3 = create ~name:"Franc Iszek Ma-Linka" ~email:"prawdziwy@email.com"
  and data4 = create ~name:"Franciszek" ~email:"prawdziwyemail.com" in
  print_s [%sexp (data1 : t Or_error.t)];
  print_s [%sexp (data2 : t Or_error.t)];
  print_s [%sexp (data3 : t Or_error.t)];
  print_s [%sexp (data4 : t Or_error.t)];
  [%expect
    {|
    (Ok ((name Franciszek) (email prawdziwy@email.com)))
    (Ok ((name "Franciszek truskawka") (email prawdziwy@email.com)))
    (Ok ((name "Franc Iszek Ma-Linka") (email prawdziwy@email.com)))
    (Error ("This is not a valid email address." prawdziwyemail.com)) |}]
;;
