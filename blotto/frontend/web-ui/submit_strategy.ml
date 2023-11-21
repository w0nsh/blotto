open! Core
open Import
open Bonsai.Let_syntax

module T = struct
  type t =
    { token : User_token.t
    ; army : Army.t
    }
  [@@deriving typed_fields]

  let label_for_field =
    `Computed
      (let label : type a. a Typed_field.t -> string = function
         | Token -> "User token"
         | Army -> "Strategy"
       in
       label)
  ;;

  let form_for_field : type a. a Typed_field.t -> a Form.t Computation.t = function
    | Token ->
      let%sub form = Form.Elements.Textbox.string () in
      let%arr form = form in
      Form.project'
        form
        ~parse:(fun s -> User_token.create s)
        ~unparse:User_token.to_string
    | Army ->
      let%sub form =
        let%sub subforms =
          Computation.all
            (List.init 10 ~f:(fun i ->
               let%sub textbox = Form.Elements.Textbox.int () in
               let%arr textbox = textbox in
               Form.label (Int.to_string (i + 1)) textbox))
        in
        let%arr subforms = subforms in
        Form.all subforms
      in
      let%arr form = form in
      Form.project'
        ~parse:(fun ls -> Army.create (Array.of_list ls))
        ~unparse:(fun army -> List.of_array (Army.to_array army))
        form
  ;;
end

type t = T.t =
  { token : User_token.t
  ; army : Army.t
  }

let form = Form.Typed.Record.make (module T)

let component ~game_id =
  let%sub theme = View.Theme.current in
  let%sub form = form in
  let%arr form = form
  and theme = theme
  and game_id = game_id in
  let on_submit { token; army } =
    let%bind.Effect result = Api.Submit_entry.dispatch_effect { game_id; token; army } in
    let%map.Effect () =
      match result with
      | Error err -> Alert.effect (Error.to_string_hum err)
      | Ok _ -> Effect.return ()
    in
    ()
  in
  let on_submit = Form.Submit.create ~f:on_submit () in
  Form.view_as_vdom ~theme form ~on_submit
;;
