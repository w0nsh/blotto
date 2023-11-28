open! Core
open Import

let print_time = Time_ns_fix.to_sec_string ~zone:(Time_float.Zone.of_utc_offset ~hours:1)

let component ?(attrs = []) { Game_info.name; description; start_date; end_date; rule } =
  Pane.component
    ~attrs:(attrs @ [ A.class_ "game-info-view" ])
    [ N.h2 [ N.text name ]
    ; N.p ~attrs:[ A.class_ "description" ] [ N.text description ]
    ; N.h4 [ N.text "Czas rozpoczęcia i końca" ]
    ; N.p [ N.text (print_time start_date ^ " - " ^ print_time end_date) ]
    ; N.h4 [ N.text "Zasady" ]
    ; N.p [ N.text (Rule.description rule) ]
    ]
;;
