open! Core
open Import
open Bonsai.Let_syntax

module Ui_entry_and_place = struct
  type t =
    { entry : Ui_entry.t
    ; place : int
    }
  [@@deriving fields ~getters]
end

let sort_scoreboard scoreboard =
  List.sort
    ~compare:(fun (a : Ui_entry.t) (b : Ui_entry.t) -> Float.compare a.score b.score)
    scoreboard
  |> List.rev
  |> List.foldi
       ~init:([], -1.0, -1)
       ~f:(fun index (ret, previous_score, previous_place) (entry : Ui_entry.t) ->
         let place =
           if Float.equal previous_score entry.score then previous_place else index + 1
         in
         { Ui_entry_and_place.entry; place } :: ret, entry.score, place)
  |> fst3
  |> List.rev
;;

let view_scoreboard scoreboard =
  let%sub theme = View.Theme.current in
  let%arr scoreboard = scoreboard
  and theme = theme in
  let scoreboard = sort_scoreboard scoreboard in
  let columns =
    let render_army _ army =
      View.text
        ~attrs:[ A.class_ "monospace" ]
        (Army.to_array army
         |> Array.to_list
         |> List.map ~f:Int.to_string
         |> List.map ~f:(String.pad_left ~len:3)
         |> String.concat ~sep:" ")
    in
    let render_user_name _ user_name = View.text user_name in
    let render_score _ = N.textf "%.3f" in
    let render_place _ = N.textf "%d" in
    [ View.Table.Col.make "Miejsce" ~get:Ui_entry_and_place.place ~render:render_place
    ; View.Table.Col.make
        "Użytkownik"
        ~get:(Ui_entry_and_place.entry >> Ui_entry.user_name)
        ~render:render_user_name
    ; View.Table.Col.make
        "Strategia"
        ~get:(Ui_entry_and_place.entry >> Ui_entry.army)
        ~render:render_army
    ; View.Table.Col.make
        "Wynik"
        ~get:(Ui_entry_and_place.entry >> Ui_entry.score)
        ~render:render_score
    ]
  in
  View.Table.render theme columns scoreboard
;;

let view ~game_id =
  let%sub scoreboard, fetch_score = Api.Get_ui_scoreboard.dispatcher in
  let%sub () = Bonsai.Edge.on_change (module Game_id) game_id ~callback:fetch_score in
  let%sub game_info, fetch_game_info = Api.Get_game.dispatcher in
  let%sub () = Bonsai.Edge.on_change (module Game_id) game_id ~callback:fetch_game_info in
  match%sub Value.both scoreboard game_info with
  | None, _ | _, None -> Bonsai.const (N.text "downloading...")
  | Some scoreboard, Some game_info ->
    (match%sub Value.both scoreboard game_info with
     | Error err, _ | _, Error err ->
       let%arr err = err in
       N.text (Error.to_string_hum err)
     | Ok scoreboard, Ok game_info ->
       let%sub scoreboard = view_scoreboard scoreboard in
       let%arr scoreboard = scoreboard
       and game_info = game_info in
       let game_view = Game_info_view.component game_info in
       Pane.component
         ~attrs:[ A.class_ "scoreboard-view" ]
         [ Pane.component ~attrs:[ A.class_ "game-info-wrapper" ] [ game_view ]
         ; scoreboard
         ])
;;

let component ~game_id =
  match%sub game_id with
  | None -> Bonsai.const (N.text "invalid game id")
  | Some game_id -> view ~game_id
;;
