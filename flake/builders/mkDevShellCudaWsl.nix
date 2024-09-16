{ system, pkgsCudaFor, name, args, ... }:
let
  pkgs = pkgsCudaFor.${system};
in
pkgs.mkShell {
  inherit name;
  buildInputs = let inherit (pkgs.python3Packages) torchWithCuda;
  in
    [ 
      #inherit (pkgs) python3;
      # https://github.com/NixOS/nixpkgs/issues/189372#issuecomment-1292824268
     torchWithCuda 
    ];

  shellHook = ''
    export LD_LIBRARY_PATH=/usr/lib/wsl/lib
  '';
}
