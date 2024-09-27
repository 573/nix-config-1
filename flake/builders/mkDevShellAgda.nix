{ system, ghcpkgsFor, name, args, ... }:
let
  pkgs = ghcpkgsFor.${system};
  myagda = (pkgs.agdaPackages.override {
    Agda = args.haskellPackages.Agda.overrideAttrs { };
  }).agda.withPackages (agdaPackageSet: builtins.attrValues {
    inherit
      (agdaPackageSet)
      standard-library
      ;
  });
in
pkgs.mkShell {
  inherit name;
  packages = [ myagda ];
}
