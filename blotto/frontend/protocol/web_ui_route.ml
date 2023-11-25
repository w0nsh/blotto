open! Core
open Import

type t =
  | Game of Game_id.t option
  | Index
  | Register_user
  | Scoreboard of Game_id.t option
  | Not_found

let game_id_param uri =
  let%bind.Option param = Uri.get_query_param uri "game_id" in
  Option.try_with (fun () -> Game_id.of_string param)
;;

let of_uri uri =
  let path = Uri.path uri |> Utils.normalize_path in
  match path with
  | "" -> Index
  | "/game" -> Game (game_id_param uri)
  | "/register" -> Register_user
  | "/scoreboard" -> Scoreboard (game_id_param uri)
  | _ -> Not_found
;;

let set_path_and_query ~uri t =
  let set ?(query = []) ~path () =
    let uri = Uri.with_path uri path in
    Uri.with_query' uri query
  in
  let game_id_to_query game_id =
    match game_id with
    | None -> []
    | Some game_id -> [ "game_id", Game_id.to_string game_id ]
  in
  match t with
  | Game game_id -> set ~path:"/game" ~query:(game_id_to_query game_id) ()
  | Index -> set ~path:"" ()
  | Register_user -> set ~path:"/register" ()
  | Scoreboard game_id -> set ~path:"/scoreboard" ~query:(game_id_to_query game_id) ()
  | Not_found -> set ~path:"" () (* TODO: is raise better? *)
;;
