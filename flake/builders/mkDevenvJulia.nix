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
      { ... }:
      {
        languages.julia.enable = true;
      }
    )
  ];
}
