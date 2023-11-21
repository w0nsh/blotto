open! Core
open! Import

let run () =
  Async_js.init ();
  let app = App.component ~component:Router.component in
  let theme =
    Kado.theme
      ~style:Kado.Style.Light
      ~set_min_height_to_100vh:()
      ~version:Kado.Version.Bleeding
      ()
  in
  let themed_app = View.Theme.set_for_app (Value.return theme) app in
  let () = Bonsai_web.Start.start themed_app in
  (* don't_wait_for (some_rpc ~conn); *)
  return ()
;;

let () = don't_wait_for (run ())
