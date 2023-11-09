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
 (depends ocaml dune)
 (tags
  (topics "to describe" your project)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/dune-files.html#dune-project
