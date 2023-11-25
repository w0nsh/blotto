open! Core
open Import
open Bonsai.Let_syntax

let print_time = Time_ns.to_sec_string ~zone:(Time_float.Zone.of_utc_offset ~hours:1)

let view_game_info ~game_id ~game_info =
  let%sub submit_strategy = Submit_strategy.component ~game_id in
  let%arr { Game_info.name; description; start_date; end_date; rule } = game_info
  and submit_strategy = submit_strategy in
  Pane.component
    ~attrs:[ A.class_ "game-view" ]
    [ Pane.component
        ~attrs:[ A.class_ "content" ]
        [ N.h2 [ N.text name ]
        ; N.p ~attrs:[ A.class_ "description" ] [ N.text description ]
        ; N.h4 [ N.text "Czas rozpoczęcia i końca" ]
        ; N.p [ N.text (print_time start_date ^ " - " ^ print_time end_date) ]
        ; N.h4 [ N.text "Zasady" ]
        ; N.p [ N.text (Rule.description rule) ]
        ; N.h2 ~attrs:[ A.class_ "submit-header" ] [ N.text "Zgłoszenie" ]
        ; Pane.component ~add_padding:false [ submit_strategy ]
        ]
    ]
;;

let view ~game_id =
  let%sub game_info, refresh = Api.Get_game.dispatcher in
  let%sub () = Bonsai.Edge.on_change ~equal:Game_id.equal game_id ~callback:refresh in
  match%sub game_info with
  | None -> Bonsai.const (N.text "downloading...")
  | Some game_info ->
    (match%sub game_info with
     | Error err ->
       let%arr err = err in
       N.text (Error.to_string_hum err)
     | Ok game_info -> view_game_info ~game_id ~game_info)
;;

let component ~game_id =
  match%sub game_id with
  | None -> Bonsai.const (N.text "invalid game id")
  | Some game_id -> view ~game_id
;;
