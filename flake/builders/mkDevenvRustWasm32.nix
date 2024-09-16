{ system, pkgsFor, inputs, name, args, ... }:

let
  pkgs = pkgsFor.${system};
  inherit (args) fenix mkShell;
in

mkShell {
  inherit pkgs inputs;
  modules = [
    # https://matrix.to/#/!plrRoZsBTUYBWzvzIq:matrix.org/$80LefOPCyVvyNl6Hj_VB7cSjonWGaM3TFZhETDTNQTU?via=matrix.org&via=beeper.com&via=lossy.network
    ({ pkgs, config, ... }:

      let
        toolchain = let inherit (fenix) combine latest targets; in (combine (builtins.attrValues {
          inherit
            (latest)
            rustc
            cargo
            rust-src
            clippy
            rustfmt
            rust-analyzer
            ;
          inherit
            (targets.wasm32-unknown-unknown.latest)
            rust-std
            ;
        }));
      in

      {
        # see https://github.com/cachix/devenv/pull/1092#issue-2219555575
        stdenv = pkgs.clangStdenv;

        languages.rust = {
          enable = true;
          # https://devenv.sh/reference/options/#languagesrustchannel
          channel = "nightly";

          components = [ ];

          toolchain = pkgs.lib.mkForce toolchain;
        };
        languages.javascript.enable = true;

        scripts.watch-build.exec = ''
          ls -d ./src/* | entr cargo build
        '';

        packages = builtins.attrValues {
          inherit
            (pkgs)
            wasm-pack
            entr
            ;
          inherit
            toolchain
            ;
        };
      })
  ];
}

