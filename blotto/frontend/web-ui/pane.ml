open! Core
open Import

let component ?(attrs = []) contents = N.div ~attrs:(A.class_ "pane" :: attrs) contents
