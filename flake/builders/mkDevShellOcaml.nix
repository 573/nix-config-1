{ args, ... }:
let
  pkgs = args.unstable;
in
pkgs.mkShell {
  packages = builtins.attrValues {
    inherit (pkgs)
      ocaml
      ocamlformat
      opam
      ;
    inherit (pkgs.ocamlPackages)
      findlib
      dune_3
      odoc
      ocaml-lsp
      merlin
      utop
      ocp-indent
      ;
    inherit (pkgs.ocamlPackages.janeStreet)
      #async
      base
      core_unix
      ppx_let
      ;
  };
}
