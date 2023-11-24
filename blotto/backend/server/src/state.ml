open! Core
open Async
open Import

module Data = struct
  type t =
    { games : Game.t Game_id.Table.t
    ; users : User_info.t User_token.Table.t
    ; mutable emails : Email.Set.t
    ; scoreboards : Scoreboard.t Game_id.Table.t
    }
  [@@deriving sexp, equal]
end

type t =
  { mutable data : Data.t
  ; token_generator : User_token_generator.t
  }

let init ?seed () =
  { data =
      { games = Game_id.Table.create ()
      ; users = User_token.Table.create ()
      ; scoreboards = Game_id.Table.create ()
      ; emails = Email.Set.empty
      }
  ; token_generator = User_token_generator.init ?seed ()
  }
;;

let load_data t filename =
  let%map.Deferred.Or_error data = Reader.load_sexp filename Data.t_of_sexp in
  t.data <- data
;;

let save_data t filename =
  Deferred.Or_error.try_with (fun () ->
    Writer.save_sexp ~fsync:true ~hum:true filename (Data.sexp_of_t t.data))
;;

let get_game { data; _ } game_id =
  match Hashtbl.find data.games game_id with
  | None -> Or_error.error_s [%message "No game with id" (game_id : Game_id.t)]
  | Some game -> Ok game
;;

let get_games { data = { games; _ }; _ } = games

let get_game_info t game_id =
  let%map.Or_error game = get_game t game_id in
  game.info
;;

let get_game_infos { data = { games; _ }; _ } = Hashtbl.map games ~f:Game.info

let remove_game t game_id =
  let%map.Or_error _ = get_game t game_id in
  Hashtbl.remove t.data.games game_id
;;

let list_users { data; _ } = data.users

let get_user_info { data; _ } token =
  match Hashtbl.find data.users token with
  | None -> Or_error.error_s [%message "No user with given token" (token : User_token.t)]
  | Some user_info -> Ok user_info
;;

let get_unique_token { data; token_generator } =
  let rec get_unique_token_aux () =
    let token = User_token_generator.get_token token_generator ~num_words:3 in
    match Hashtbl.find data.users token with
    | None -> token
    | Some _ -> get_unique_token_aux ()
  in
  get_unique_token_aux ()
;;

let create_user t (user_data : User_data.t) =
  let email = User_data.email user_data in
  if Set.mem t.data.emails email
  then
    Or_error.error_s
      [%message "Already created user with this email address." (email : Email.t)]
  else (
    let token = get_unique_token t in
    Hashtbl.set
      t.data.users
      ~key:token
      ~data:{ User_info.data = user_data; creation_time = Time_ns.now () };
    t.data.emails <- Set.add t.data.emails email;
    Ok token)
;;

let create_game { data; _ } id game =
  match Hashtbl.add data.games ~key:id ~data:game with
  | `Ok -> Ok ()
  | `Duplicate ->
    Or_error.error_s
      [%message "This game id already exists, use something else." (id : Game_id.t)]
;;

let update_game ?name ?description ?start_date ?end_date ?allowed_users ?rule t game_id =
  let%map.Or_error game = get_game t game_id in
  let name = Option.value name ~default:game.info.name
  and description = Option.value description ~default:game.info.description
  and start_date = Option.value start_date ~default:game.info.start_date
  and end_date = Option.value end_date ~default:game.info.end_date
  and allowed_users = Option.value allowed_users ~default:game.allowed_users
  and rule = Option.value rule ~default:game.info.rule in
  let info = { Game_info.name; description; start_date; end_date; rule } in
  Hashtbl.set t.data.games ~key:game_id ~data:{ game with info; allowed_users }
;;

let user_exists (data : Data.t) token = Hashtbl.find data.users token |> Option.is_some

let can_participate allowed_users token =
  match allowed_users with
  | Game.Allowed_users.Any -> true
  | Users allowed_tokens -> Set.mem allowed_tokens token
;;

let recalculate_scoreboard { data; _ } ~game_id ~(game : Game.t) =
  let scoreboard =
    Scoreboard.create
      ~entries:(Hashtbl.to_alist game.entries)
      ~eval:(Rule.eval game.info.rule)
  in
  Hashtbl.set data.scoreboards ~key:game_id ~data:scoreboard
;;

let add_entry t ~token ~army ~game_id =
  let%bind.Or_error game = get_game t game_id in
  if not (user_exists t.data token && can_participate game.allowed_users token)
  then
    Or_error.error_s
      [%message
        "This token cannot participate in this game."
          (token : User_token.t)
          (game_id : Game_id.t)]
  else if Time_ns.(now () > game.info.end_date)
  then
    Or_error.error_s
      [%message
        "Game has already finished, cannot submit."
          (game_id : Game_id.t)
          (game.info.end_date : Time_ns.Alternate_sexp.t)]
  else (
    Game.update_entry game ~token ~army;
    recalculate_scoreboard t ~game_id ~game;
    Ok ())
;;

let get_scoreboard t game_id =
  let%bind.Or_error _ = get_game t game_id in
  match Hashtbl.find t.data.scoreboards game_id with
  | None ->
    Or_error.error_s [%message "No entries yet for the game" (game_id : Game_id.t)]
  | Some scoreboard -> Ok scoreboard
;;

let%expect_test "state" =
  let t = init ~seed:1337 () in
  let game =
    Game.create
      ~name:"Test game"
      ~description:"This is a game"
      ~start_date:Time_ns.min_value_representable
      ~end_date:Time_ns.max_value_representable
      ~allowed_users:Any
      ~rule:Rule.basic
    |> Or_error.ok_exn
  in
  let game_id = Game_id.of_string "game-1" in
  create_game t game_id game |> Or_error.ok_exn;
  let army = Army.create_exn [| 10; 10; 10; 10; 10; 10; 10; 10; 10; 10 |] in
  let user_token = User_token.create_exn "test-token" in
  print_s [%sexp (add_entry t ~token:user_token ~army ~game_id : unit Or_error.t)];
  [%expect
    {|
    (Error
     ("This token cannot participate in this game." (token test-token)
      (game_id game-1))) |}];
  let user_token =
    create_user
      t
      (User_data.create_exn ~name:"Franciszek" ~surname:"Malinka" ~email:"a@b.c")
    |> Or_error.ok_exn
  in
  add_entry t ~token:user_token ~army ~game_id |> Or_error.ok_exn;
  update_game ~allowed_users:(Users (User_token.Set.of_list [ user_token ])) t game_id
  |> Or_error.ok_exn;
  add_entry t ~token:user_token ~army ~game_id |> Or_error.ok_exn;
  print_s
    [%sexp
      (add_entry t ~token:(User_token.create_exn "invalid") ~army ~game_id
       : unit Or_error.t)];
  [%expect
    {|
    (Error
     ("This token cannot participate in this game." (token invalid)
      (game_id game-1))) |}];
  return ()
;;
