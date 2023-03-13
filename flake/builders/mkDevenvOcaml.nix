{ system, pkgsFor, inputs, name, args, ... }:

let
  pkgs = pkgsFor.${system};
in

inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    ({ pkgs, config, lib, ... }:
      {
        languages.ocaml.enable = true;
        #        languages.ocaml.packages = ocamlPackagesNew;
        packages = with config.languages.ocaml.packages; [
          pkgs.opam
          findlib
          # see https://github.com/NixOS/nixpkgs/issues/16085, utop sufficient, no need for #use "topfind";; in ocaml
        ];
      })
  ];
}
