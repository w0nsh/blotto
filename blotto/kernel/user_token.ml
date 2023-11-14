open! Core

module T = struct
  type t = string [@@deriving sexp, compare, equal, hash, bin_io]

  let create str =
    if String.for_all str ~f:(fun c -> Char.is_lowercase c || Char.equal c '-')
    then Ok str
    else
      Or_error.error_s
        [%message "Invliad token, only lowercase letters and hyphens allowed." str]
  ;;

  let create_exn str = Or_error.ok_exn (create str)

  let%expect_test "create" =
    let token1 = create "siema-witam"
    and token2 = create "To-sie-powinno-wywalic"
    and token3 = create "to-tez0" in
    print_s [%sexp (token1 : t Or_error.t)];
    print_s [%sexp (token2 : t Or_error.t)];
    print_s [%sexp (token3 : t Or_error.t)];
    [%expect
      {|
    (Ok siema-witam)
    (Error
     ("Invliad token, only lowercase letters and hyphens allowed."
      To-sie-powinno-wywalic))
    (Error
     ("Invliad token, only lowercase letters and hyphens allowed." to-tez0)) |}]
  ;;
end

include T
include Hashable.Make_binable (T)
include Comparable.Make_binable (T)
