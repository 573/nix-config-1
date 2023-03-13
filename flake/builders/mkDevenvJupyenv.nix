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
        #languages.ocaml.enable = true;

        packages =
          let
            inherit (inputs.jupyenv.lib.${system}) mkJupyterlabNew;
            jupyterlab = mkJupyterlabNew ({ ... }: {
              nixpkgs = inputs.nixpkgs;
              imports = [
                ({ pkgs, ... }: {
                  kernel.go.science.enable = true;
                  kernel.r.science = {
                    enable = true;
                    extraRPackages = ps: [ ps.foreign ps.ggplot2 ps.easystats ];
                  };
                  kernel.python.science = {
                    enable = true;
                  };
                  #kernel.ocaml.minimal-example = {
                  #  enable = true;
                  #};
                  #kernel.julia.minimal-example = {
                  #    enable = true;
                  #    julia = pkgs.julia-bin;
                  #};
                  #kernel.scala.minimal-example = {
                  #  enable = true;
                  #};
                  kernel.rust.minimal-example = {
                    enable = true;
                  };
                  kernel.elm.minimal-example = {
                    enable = true;
                  };
                })
              ];
            });
          in
          [
            (jupyterlab.overrideAttrs
              (_: {
                runtimePackages = [
                  # Used to setup the OCAMLPATH for libs
                  #pkgs.ocamlPackages.findlib

                  # Libs
                  #pkgs.ocamlPackages.base
                  #pkgs.ocamlPackages.core_kernel
                  #pkgs.ocamlPackages.ounit
                  #pkgs.ocamlPackages.qcheck

                  # REPL
                  #pkgs.ocamlPackages.utop
                ];
              }))

          ];

        enterShell = ''
          echo "jupyter lab --core-mode"
        '';
      }
    )
  ];
}
