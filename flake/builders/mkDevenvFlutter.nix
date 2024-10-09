{
  system,
  pkgsFor,
  inputs,
  args,
  ...
}:

let
  pkgs = pkgsFor.${system};
in

args.mkShell {
  inherit inputs pkgs;
  modules = [
    (
      { pkgs, ... }:
      {
        packages = [ pkgs.flutter ];

        languages.dart.enable = true;
      }
    )
  ];
}
