{ system, pkgsFor, inputs, name, args, ... }:

let
  pkgs = pkgsFor.${system};
in

inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    ({ pkgs, ... }:
      #let
      #ocamlPackagesFlambda = pkgs.ocamlPackages.overrideScope' (self: super: {
      #  ocaml = super.ocaml.override { flambdaSupport = true; };
      #});
      #in
      {
        languages.ocaml.enable = true;
        #languages.ocaml.packages = ocamlPackagesFlambda;
        packages = [
          # Used to setup the OCAMLPATH for libs
          pkgs.ocamlPackages.findlib

          # Libs
          pkgs.ocamlPackages.base
          pkgs.ocamlPackages.core_kernel
          pkgs.ocamlPackages.ounit
          pkgs.ocamlPackages.qcheck

          # REPL
          pkgs.ocamlPackages.utop
        ];
      })
  ];
}
