open! Core

module Allowed_users = struct
  type t =
    | Any
    | Users of User_token.Set.t
  [@@deriving sexp, bin_io, equal]
end

type t =
  { name : string
  ; description : string
  ; start_date : Time_ns.Alternate_sexp.t
  ; end_date : Time_ns.Alternate_sexp.t
  ; allowed_users : Allowed_users.t
  ; rule : Rule.t
  ; entries : Army.t User_token.Table.t
  }
[@@deriving sexp, bin_io, equal]

let create ~name ~description ~start_date ~end_date ~allowed_users ~rule =
  if Time_ns.( > ) start_date end_date
  then
    Or_error.error_s
      [%message
        "Start date must be before end date."
          (start_date : Time_ns.Alternate_sexp.t)
          (end_date : Time_ns.Alternate_sexp.t)]
  else
    Ok
      { name
      ; description
      ; start_date
      ; end_date
      ; allowed_users
      ; rule
      ; entries = User_token.Table.create ()
      }
;;

let update_entry t ~token ~army = Hashtbl.update t.entries token ~f:(fun _ -> army)

let%expect_test "create" =
  let game1 =
    create
      ~name:"Game 1"
      ~description:"Some description of the rules."
      ~start_date:Time_ns.min_value_representable
      ~end_date:Time_ns.max_value_representable
      ~allowed_users:Any
      ~rule:Rule.basic
  in
  let game2 =
    create
      ~name:"Game 2"
      ~description:"Some description of the rules."
      ~start_date:Time_ns.max_value_representable
      ~end_date:Time_ns.min_value_representable
      ~allowed_users:Any
      ~rule:Rule.basic
  in
  print_s [%sexp (game1 : t Or_error.t)];
  print_s [%sexp (game2 : t Or_error.t)];
  [%expect
    {|
    (Ok
     ((name "Game 1") (description "Some description of the rules.")
      (start_date "1823-11-12 00:06:21.572612096Z")
      (end_date "2116-02-20 23:53:38.427387903Z") (allowed_users Any)
      (rule ((kind Basic) (description "Description of the basic rule.")))
      (entries ())))
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
     ((name "Game 1") (description "Some description of the rules.")
      (start_date "1823-11-12 00:06:21.572612096Z")
      (end_date "2116-02-20 23:53:38.427387903Z") (allowed_users Any)
      (rule ((kind Basic) (description "Description of the basic rule.")))
      (entries
       ((first-token (1 2 3 4 5 6 7 8 9 55))
        (second-token (10 10 10 10 10 10 10 10 10 10)))))) |}]
;;
