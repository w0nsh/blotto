(lang dune 3.11)

(name blotto)

(generate_opam_files true)

(source
 (github w0nsh/blotto))

(authors "Adam Zyzik" "Franciszek Malinka")

(maintainers "Adam Zyzik")

(license MIT)

(package
 (name blotto)
 (synopsis "Colonel Blotto game")
 (description "Platform for organization of Colonel Blotto games.")
 (depends
  (ocaml
   (>= 4.14.1))
  (ocamlformat
   (>= 0.26.1))
  (cohttp
   (>= 5.3.0))
  (cohttp-async
   (>= 5.3.0))
  (bonsai
   (= v0.17~preview.128.46+112))
  dune)
 (tags
  ("blotto" "fun")))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
