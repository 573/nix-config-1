{ system, pkgsFor, name, args, ... }:
# based on this https://github.com/cachix/devenv/pull/667#issuecomment-1656811711
let
  inherit (args) inputs mkShell;
  # FIXME https://discourse.nixos.org/t/unexpected-11h-build-after-auto-update/39907/9
  pkgs = import inputs.unstable {
    inherit system;
    overlays =
      (map (x: x.overlays.default) [
        inputs.rust-overlay
        # see https://github.com/nix-community/fenix#usage (as a flake)
        inputs.fenix
      ])
    ;
  };
  rustVersion = pkgs.rust-bin.selectLatestNightlyWith (toolchain: toolchain.default);
  #aarch64-binutils = pkgs.pkgsCross.aarch64-multiplatform.stdenv.cc;
  #x86_64-binutils = pkgs.pkgsCross.gnu64.stdenv.cc;
in
mkShell {
  inherit inputs pkgs;

  modules = [
    ({ pkgs, ... }: {
      languages.rust = {
        enable = true;
        toolchain.rustc = (rustVersion.override {
          extensions = [ "rust-src" "rust-analyzer" ];
          targets = [ /*"x86_64-unknown-linux-gnu" "aarch64-unknown-linux-gnu"*/ "wasm32-unknown-unknown" ];
        });
      };

      /*packages = [
                  pkgs.libunwind
                  aarch64-binutils
                ] ++ pkgs.lib.optionals pkgs.stdenv.isDarwin (with pkgs.darwin.apple_sdk; [
                  frameworks.Security
                  frameworks.CoreFoundation
                  x86_64-binutils
                ]);*/
    })
  ];
}
