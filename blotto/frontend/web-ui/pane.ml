open! Core
open Import

let component ?(attrs = []) ?(add_margin = false) ?(add_padding = true) contents =
  let own_attrs =
    [ A.class_ "pane" ]
    @ (if add_margin then [ A.class_ "pane-margin" ] else [])
    @ if add_padding then [ A.class_ "pane-padding" ] else []
  in
  N.div ~attrs:(own_attrs @ attrs) contents
;;
