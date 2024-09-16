{ system, pkgsFor, inputs, name, args, ... }:

let
  pkgs = pkgsFor.${system};
in

args.mkShell {
  inherit inputs pkgs;
  modules = [
    {
      # https://devenv.sh/reference/options/
      packages = [ pkgs.hello ];

      languages = {
        java = {
          enable = true;
          gradle.enable = true;
          maven.enable = true;
        };
        kotlin.enable = true;
      };

      enterShell = ''
        hello
      '';
    }
  ];
}
