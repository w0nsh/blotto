open! Core
open Import
open Bonsai.Let_syntax

module T = struct
  type t =
    { name : string
    ; surname : string
    ; email : string
    }
  [@@deriving typed_fields]

  let label_for_field =
    `Computed
      (let label : type a. a Typed_field.t -> string = function
         | Name -> "Name"
         | Surname -> "Surname"
         | Email -> "Email address"
       in
       label)
  ;;

  let form_for_field : type a. a Typed_field.t -> a Form.t Computation.t = function
    | Name -> Form.Elements.Textbox.string ()
    | Surname -> Form.Elements.Textbox.string ()
    | Email -> Form.Elements.Textbox.string ()
  ;;
end

type t = T.t =
  { name : string
  ; surname : string
  ; email : string
  }

let form =
  let%sub form = Form.Typed.Record.make (module T) in
  let%arr form = form in
  Form.project'
    form
    ~parse:(fun { name; surname; email } -> User_data.create ~name ~surname ~email)
    ~unparse:(fun user_data ->
      { name = User_data.name user_data
      ; surname = User_data.surname user_data
      ; email = User_data.email user_data |> Email.to_string
      })
;;

let user_token_view token =
  match%sub token with
  | None -> Bonsai.const N.none
  | Some token ->
    let%arr token = token in
    N.div
      [ N.label [ N.text "Token" ]
      ; N.input ~attrs:[ A.readonly; A.type_ "text"; A.value token ] ()
      ]
;;

let component =
  let%sub theme = View.Theme.current in
  let%sub token, set_token = Bonsai.state_opt ~sexp_of_model:String.sexp_of_t () in
  let%sub token_view = user_token_view token in
  let%sub form = form in
  let%arr form = form
  and set_token = set_token
  and token_view = token_view
  and theme = theme in
  let on_submit user_data =
    let%bind.Effect result = Api.Register_user.dispatch_effect user_data in
    let%map.Effect () =
      match result with
      | Error err -> Alert.effect (Error.to_string_hum err)
      | Ok token -> set_token (Some (User_token.to_string token))
    in
    ()
  in
  let on_submit = Form.Submit.create ~f:on_submit () in
  N.div [ Form.view_as_vdom ~theme form ~on_submit; token_view ]
;;
