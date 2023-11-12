(lang dune 3.11)

(name blotto)

(generate_opam_files true)

(source
 (github username/reponame))

(authors "Adam Zyzik")

(maintainers "Maintainer Name")

(license LICENSE)

(documentation https://url/to/documentation)

(package
 (name blotto)
 (synopsis "Colonel Blotto game")
 (description "A longer description")
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
   (= v0.17~preview.128.42+83))
  dune)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
