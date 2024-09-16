{ system, pkgsFor, name, args, ... }:

let
  pkgs = pkgsFor.${system};
in

args.mkShell {
  inherit pkgs; inherit (args) inputs;
  modules = [
    ({ pkgs, ... }:
      {
        languages.rust.enable = true;
        env.CC = "clang";
        env.LD_LIBRARY_PATH = pkgs.lib.makeLibraryPath (builtins.attrValues { inherit (pkgs) openssl sqlite; });
        packages =
	builtins.attrValues {
          inherit (pkgs) 
	  rustup
          wasm-bindgen-cli
          wasm-pack
          binaryen
          protobuf
	  ;
        };
      })
  ];
}


