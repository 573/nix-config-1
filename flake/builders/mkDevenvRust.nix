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
    ({ pkgs, ... }:
      {
        languages.rust.enable = true;
        env.CC = "clang";
        env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath [ pkgs.openssl pkgs.sqlite ];
        packages = [
          pkgs.rustup
          pkgs.wasm-bindgen-cli
          pkgs.wasm-pack
          pkgs.binaryen
          pkgs.protobuf
        ];
      })
  ];
}


