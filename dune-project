(lang dune 3.17)

(name spi)

(generate_opam_files true)

(source
 (github smuenzel/spi))

(authors "Author Name <author@example.com>")

(maintainers "Maintainer Name <maintainer@example.com>")

(license MPL-2.0)

(package
 (name spi)
 (synopsis "A short synopsis")
 (description "A longer description")
 (depends ocaml core core_kernel core_unix ppx_jane)
 (tags
  (spi)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
