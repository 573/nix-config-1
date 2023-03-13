{ system, pkgsFor, inputs, name, args, ... }:

let
  pkgs = pkgsFor.${system};
  inherit (inputs.devenv.lib) mkShell;
  #  mkShellClang = mkShell.override { stdenv = pkgs.clangStdenv; };
in

# pkgs.mkShell.override { stdenv = pkgs.clangStdenv; }
  # env.CC=clang

mkShell {
  inherit inputs pkgs;
  modules = [
    # https://matrix.to/#/!plrRoZsBTUYBWzvzIq:matrix.org/$80LefOPCyVvyNl6Hj_VB7cSjonWGaM3TFZhETDTNQTU?via=matrix.org&via=beeper.com&via=lossy.network
    ({ pkgs, lib, stdenv, ... }@inputs:

      let
        toolchain = (with inputs.fenix.packages.${pkgs.stdenv.system};
          combine [ latest.rustc latest.cargo latest.rust-src latest.clippy latest.rustfmt latest.rust-analyzer targets.wasm32-unknown-unknown.latest.rust-std ]
        );
      in

      {
        stdenv = pkgs.clangStdenv;

        languages.rust = {
          enable = true;
          # https://devenv.sh/reference/options/#languagesrustchannel
          channel = "nightly";

          components = [ ];

          toolchain = pkgs.lib.mkForce toolchain;
        };
        languages.javascript.enable = true;

        #pre-commit.hooks = {
        #  rustfmt.enable = true;
        #  clippy.enable = true;
        #};

        scripts.watch-build.exec = ''
          ls -d ./src/* | entr cargo build
        '';

        packages = [
          pkgs.wasm-pack
          pkgs.entr
          toolchain
        ] ++ lib.optionals pkgs.stdenv.isDarwin (with pkgs.darwin.apple_sdk; [
          frameworks.Security
        ]);
      })
  ];
}

