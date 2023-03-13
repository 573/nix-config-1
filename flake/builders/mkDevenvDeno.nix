{ system, pkgsFor, inputs, name, args, ... }:

let
  pkgs = pkgsFor.${system};
in

inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    ({ pkgs, ... }: {
      languages.deno.enable = true;
    })
  ];
}
