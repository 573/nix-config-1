{ system, pkgsFor, inputs, name, args, ... }:

let
  pkgs = pkgsFor.${system};
in

inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    ({ pkgs, ... }: {
      languages.ruby.enable = true;
      languages.ruby.package = inputs.nixpkgs-ruby.packages.${pkgs.system}."ruby-2.7";
    })
  ];
}
