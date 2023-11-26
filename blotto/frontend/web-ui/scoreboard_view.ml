open! Core
open Import
open Bonsai.Let_syntax

let view_scoreboard scoreboard =
  let%sub theme = View.Theme.current in
  let%arr scoreboard = scoreboard
  and theme = theme in
  let columns =
    let render_army _ army =
      View.text
        ~attrs:
          [ A.style (Css_gen.font_family [ "monospace" ])
          ; A.style (Css_gen.font_size (`Px 16))
          ]
        (Army.to_array army
         |> Array.to_list
         |> List.map ~f:Int.to_string
         |> List.map ~f:(String.pad_left ~len:3)
         |> String.concat ~sep:" ")
    in
    let render_user_data _ user_data = View.text (User_data.name user_data) in
    let render_score _ = N.textf "%.3f" in
    [ View.Table.Col.make "Użytkownik" ~get:Ui_entry.user_data ~render:render_user_data
    ; View.Table.Col.make "Strategia" ~get:Ui_entry.army ~render:render_army
    ; View.Table.Col.make "Wynik" ~get:Ui_entry.score ~render:render_score
    ]
  in
  View.Table.render theme columns scoreboard
;;

let view ~game_id =
  let%sub scoreboard, fetch = Api.Get_ui_scoreboard.dispatcher in
  let%sub () = Bonsai.Edge.on_change (module Game_id) game_id ~callback:fetch in
  match%sub scoreboard with
  | None -> Bonsai.const (N.text "downloading...")
  | Some scoreboard ->
    (match%sub scoreboard with
     | Error err ->
       let%arr err = err in
       N.text (Error.to_string_hum err)
     | Ok scoreboard ->
       let%sub scoreboard = view_scoreboard scoreboard in
       let%arr scoreboard = scoreboard in
       Pane.component ~attrs:[ A.class_ "scoreboard-view" ] [ scoreboard ])
;;

let component ~game_id =
  match%sub game_id with
  | None -> Bonsai.const (N.text "invalid game id")
  | Some game_id -> view ~game_id
;;
