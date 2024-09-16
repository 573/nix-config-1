{ system, pkgsFor, name, args, ... }:
# try https://github.com/cachix/devenv/issues/585
let
  inherit (args) ghciwatch haskellPackages unstable mkShell;
  pkgs = pkgsFor.${system};
  hiPrio = pkg: pkgs.lib.updateManyAttrsByPath (builtins.map (output: { path = [ output ]; update = pkgs.hiPrio; }) pkg.outputs) pkg;
in
mkShell {
  inherit pkgs name;
  modules = [
    ({ ... }:
      {
        packages = [
          ghciwatch
          (hiPrio (unstable.stack)) # still the stack from ghc-nixpkgs-unstable seemingly
          haskellPackages.hledger
        ];

        languages.haskell = {
          enable = true;
          package = haskellPackages.ghcWithHoogle (haskellPackageSet: builtins.attrValues {
            #pset: with pset; [
            # libraries
            #zlib
            #arrows
            #async
            # cgi # marked broken
            #criterion
            # tools
            #cabal-install
            inherit
              (haskellPackageSet)
              shake
              # see this also: https://nixos.wiki/wiki/Haskell#Using_Stack_.28no_nix_caching.29
              # stack # stack of ghc-nixpkgs-unstable is too old
              ;
          });
        };
      })
  ];
}
