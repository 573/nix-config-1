{ system, pkgsFor, name, args, ... }:
# https://github.com/NixOS/nixpkgs/blob/9e860e4/pkgs/development/lisp-modules/shell.nix
let
  pkgs = unstable;
in
pkgs.mkShell {
  nativeBuildInputs = [
    (pkgs.sbcl.withPackages
      (sbclPackageSet: builtins.attrValues {
        inherit
          (sbclPackageSet)
          alexandria
          str
          dexador
          cl-ppcre
          sqlite
          arrow-macros
          jzon
          ;
      }))
  ];
};
