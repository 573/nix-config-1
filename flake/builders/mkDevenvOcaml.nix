{
  system,
  pkgsFor,
  inputs,
  args,
  ...
}:

let
  pkgs = pkgsFor.${system};
  inherit (args) mkShell;
in

mkShell {
  inherit inputs pkgs;
  modules = [
    (
      { pkgs, config, ... }:
      {
        languages.ocaml.enable = true;
        #        languages.ocaml.packages = ocamlPackagesNew;
        packages = builtins.attrValues {
          inherit (config.languages.ocaml.packages)
            findlib
            ;

          inherit (pkgs)
            opam
            ;
          # see https://github.com/NixOS/nixpkgs/issues/16085, utop sufficient, no need for #use "topfind";; in ocaml
        };
      }
    )
  ];
}
