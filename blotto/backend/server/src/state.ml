open! Core
open Async
open Import

module Data = struct
  type t =
    { games : Game.t Game_id.Table.t
    ; users : User_info.t User_token.Table.t
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

let get_unique_token { data; token_generator } =
  let rec get_unique_token_aux () =
    let token = User_token_generator.get_token token_generator ~num_words:3 in
    match Hashtbl.find data.users token with
    | None -> token
    | Some _ -> get_unique_token_aux ()
  in
  get_unique_token_aux ()
;;

let create_user t user_data =
  let token = get_unique_token t in
  Hashtbl.set
    t.data.users
    ~key:token
    ~data:{ User_info.data = user_data; creation_time = Time_ns.now () };
  Ok token
;;

let create_game { data; _ } id game =
  match Hashtbl.add data.games ~key:id ~data:game with
  | `Ok -> Ok ()
  | `Duplicate ->
    Or_error.error_s
      [%message "This game id already exists, use something else." (id : Game_id.t)]
;;

let update_game ?start_date ?end_date ?allowed_users { data; _ } game_id =
  match Hashtbl.find data.games game_id with
  | None ->
    Or_error.error_s
      [%message "No game with given id, cannot update." (game_id : Game_id.t)]
  | Some game ->
    let start_date = Option.value start_date ~default:game.start_date
    and end_date = Option.value end_date ~default:game.end_date
    and allowed_users = Option.value allowed_users ~default:game.allowed_users in
    Hashtbl.set
      data.games
      ~key:game_id
      ~data:{ game with start_date; end_date; allowed_users };
    Ok ()
;;

let user_exists (data : Data.t) token = Hashtbl.find data.users token |> Option.is_some

let can_participate allowed_users token =
  match allowed_users with
  | Game.Allowed_users.Any -> true
  | Users allowed_tokens -> Set.mem allowed_tokens token
;;

let add_entry { data; _ } ~token ~army ~game_id =
  match Hashtbl.find data.games game_id with
  | None -> Or_error.error_s [%message "No game with given id." (game_id : Game_id.t)]
  | Some game ->
    if user_exists data token && can_participate game.allowed_users token
    then (
      Game.update_entry game ~token ~army;
      Ok ())
    else
      Or_error.error_s
        [%message
          "This token cannot participate in this game."
            (token : User_token.t)
            (game_id : Game_id.t)]
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
  let%bind.Deferred () = save_data t "data.sexp" >>| Or_error.ok_exn in
  let data_copy = t.data in
  let%bind.Deferred () = load_data t "data.sexp" >>| Or_error.ok_exn in
  print_s [%sexp (Data.equal data_copy t.data : bool)];
  [%expect {| true |}];
  return ()
;;
