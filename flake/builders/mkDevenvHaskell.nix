{ system, pkgsFor, inputs, name, args, ... }:

let
  pkgs = pkgsFor.${system};
  inherit (inputs.devenv.lib) mkShell;
in
mkShell rec {
  inherit inputs pkgs;
  modules = [
    ({ pkgs, ... }:
      let
        myHaskellPackages =
          inputs.ghc-nixpkgs-unstable.legacyPackages.${system}.haskell.packages.ghc946.override (old: {
            overrides = pkgs.lib.composeExtensions (old.overrides or (_: _: { }))
              (hself: hsuper: {
                ghc = hsuper.ghc // { withPackages = hsuper.ghc.withHoogle; };
                #ghcWithPackages = hself.ghc.withPackages; # would this be a function still ? leads to infinite recursion
                myGhc = hself.ghc.withPackages (p: with p; with hsuper; [
                  zlib
                  # hledger # haddock: internal error: Data.Binary.getPrim: end of file
                  arrows
                  async
                  # cgi # marked broken
                  criterion
                  # tools
                  cabal-install
                  #	  haskintex
                  # haskell-language-server # haddock: internal error: Data.Binary.getPrim: end of file
                ]);
              });
          });
      in
      {

        languages.haskell = {
          enable = true;
          package = myHaskellPackages.myGhc;
          languageServer = null;
        };

      })
  ];
}
