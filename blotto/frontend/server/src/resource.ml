open! Core
open Import

module T = struct
  type t =
    | Script
    | Style
    | Web_ui
    | Not_found
  [@@deriving enumerate, compare, sexp]

  let of_route = function
    | Route.Script -> Script
    | Style -> Style
    | Web_ui _ -> Web_ui
    | Not_found -> Not_found
  ;;

  let to_response = function
    | Script ->
      { Response.content = Embedded_files.blotto_frontend_web_ui_dot_bc_dot_js
      ; content_type = "application/javascript"
      ; status = `OK
      }
    | Style ->
      { Response.content = Embedded_files.style_dot_css
      ; content_type = "text/css"
      ; status = `OK
      }
    | Web_ui ->
      { Response.content = Embedded_files.index_dot_html
      ; content_type = "text/html"
      ; status = `OK
      }
    | Not_found ->
      { Response.content = Embedded_files.not_found_dot_html
      ; content_type = "text/html"
      ; status = `Not_found
      }
  ;;
end

include Comparable.Make (T)
include T

let etag_map =
  List.fold all ~init:Map.empty ~f:(fun acc t ->
    Core.Map.add_exn
      acc
      ~key:t
      ~data:(to_response t |> Response.digest |> sprintf "W/\"%s\""))
;;

let etag t = Core.Map.find_exn etag_map t

let%expect_test "etag-test" =
  printf "%s" (etag Not_found);
  [%expect {| W/"99de204f662827e29d65e1580e0f6475" |}]
;;
