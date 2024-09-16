{ system, pkgsFor, name, args, ... }:
# https://github.com/tweag/ormolu/blob/74887f00137d6cd91811440325c3ac330a371b2c/ormolu-live/default.nix
let
  inherit (args) unstable ghc-wasm-meta;
  pkgs = unstable;
in
pkgs.mkShell {
  packages = [ ghc-wasm-meta ];
}
