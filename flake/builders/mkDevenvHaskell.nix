{ system, pkgsFor, inputs, name, args, ... }:

let
  pkgs = pkgsFor.${system};
in

inputs.devenv.lib.mkShell {
  inherit inputs pkgs;
  modules = [
    ({ pkgs, ... }:
      {
        languages.haskell = {
          enable = true;
          package = (pkgs.haskell.packages.ghc902.ghcWithPackages (pset: with pset; [ zlib hledger ]));
        };

        #packages = [ pkgs.haskellPackages.mtl ];
      })
  ];
}
