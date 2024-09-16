{ system, pkgsFor, inputs, name, args, ... }:

let
  pkgs = pkgsFor.${system};
in

args.mkShell {
  inherit inputs pkgs;
  modules = [
    ({ pkgs, ... }:
      {
        packages =
          let
            jupyterlab = args.mkJupyterlabNew ({ ... }: {
              nixpkgs = inputs.nixpkgs;
              imports = [
                ({ pkgs, ... }: {

kernel.python.native-example = {
    enable = true;
    env = pkgs.python3.withPackages (ps:
      with ps; [
        ps.ipykernel
        ps.scipy
        ps.matplotlib
      ]);
  };

                })
              ];
            });
          in
          [
            jupyterlab
          ];

        enterShell = ''
          echo "jupyter lab --core-mode"
        '';
      }
    )
  ];
}
