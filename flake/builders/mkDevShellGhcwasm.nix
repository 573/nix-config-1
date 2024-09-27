{ system, pkgsFor, name, args, ... }:
# https://github.com/tweag/ormolu/blob/74887f00137d6cd91811440325c3ac330a371b2c/ormolu-live/default.nix
let
  pkgs = pkgsFor.${system};
in
pkgs.mkShell {
  inherit name;
  packages = [ args.ghc-wasm-meta ];
}
