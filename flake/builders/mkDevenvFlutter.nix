{ system, pkgsFor, inputs, name, args, ... }:

let
  pkgs = pkgsFor.${system};
in

inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    ({ pkgs, ... }: {
      packages = [ pkgs.flutter ];

      languages.dart.enable = true;
    })
  ];
}
