{ system, pkgsFor, inputs, name, args, ... }:

let
  pkgs = pkgsFor.${system};
in

args.mkShell {
  inherit inputs pkgs;
  modules = [
    ({ pkgs, ... }: {
      languages.deno.enable = true;
    })
  ];
}
