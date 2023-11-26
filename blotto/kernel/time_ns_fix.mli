open Core

type t [@@deriving sexp, bin_io, equal, compare]

val of_time_ns : Time_ns.t -> t
val to_time_ns : t -> Time_ns.t
val ( > ) : t -> t -> bool
val ( < ) : t -> t -> bool
val ( >= ) : t -> t -> bool
val ( <= ) : t -> t -> bool
val now : unit -> t
val to_sec_string : t -> zone:Time_float.Zone.t -> string
val min_value_representable : t
val max_value_representable : t
