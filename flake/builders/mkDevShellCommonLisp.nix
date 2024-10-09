{
  system,
  pkgsFor,
  name,
  ...
}:
# https://github.com/NixOS/nixpkgs/blob/9e860e4/pkgs/development/lisp-modules/shell.nix
let
  pkgs = pkgsFor.${system};
in
pkgs.mkShell {
  inherit name;
  nativeBuildInputs = [
    (pkgs.sbcl.withPackages (
      sbclPackageSet:
      builtins.attrValues {
        inherit (sbclPackageSet)
          alexandria
          str
          dexador
          cl-ppcre
          sqlite
          arrow-macros
          jzon
          ;
      }
    ))
  ];
}
