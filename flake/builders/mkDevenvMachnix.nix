{ system, pkgsFor, inputs, name, args, ... }:

let
  pkgs = pkgsFor.${system};
  inherit (inputs.devenv.lib) mkShell;
in

mkShell {
  inherit inputs pkgs;
  modules = [
    ({ pkgs, ... }:
      {
        packages =
          let
            mach-nix = import (inputs.mach-nix) {
              python = "python310"; # python37
              inherit system;
            };

            machNix = mach-nix.mkPython rec {
              requirements = ''
                	        jupyterlab
                		notebook
                		agentpy
                		seaborn
                	      '';

              providers.jupyterlab = "nixpkgs";
            };
          in
          [ machNix ];
        enterShell = ''
          echo "jupyter lab --core-mode"
        '';
      }
    )
  ];
}
