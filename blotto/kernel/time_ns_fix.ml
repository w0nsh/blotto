open! Core

type t = Sexp.t [@@deriving sexp, bin_io, equal, compare]

let of_time_ns = Time_ns.Alternate_sexp.sexp_of_t
let to_time_ns = Time_ns.Alternate_sexp.t_of_sexp
let ( > ) a b = Time_ns.( > ) (to_time_ns a) (to_time_ns b)
let ( < ) a b = Time_ns.( < ) (to_time_ns a) (to_time_ns b)
let ( >= ) a b = Time_ns.( >= ) (to_time_ns a) (to_time_ns b)
let ( <= ) a b = Time_ns.( <= ) (to_time_ns a) (to_time_ns b)
let now () = of_time_ns (Time_ns.now ())
let to_sec_string t = Time_ns.to_sec_string (to_time_ns t)
let min_value_representable = of_time_ns Time_ns.min_value_representable
let max_value_representable = of_time_ns Time_ns.max_value_representable
