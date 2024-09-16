{ system, pkgsFor, name, args, ... }:
let
  pkgs = pkgsFor.${system};
  # see https://discourse.nixos.org/t/help-using-poetry-in-a-flake-devshell/36874/3
  mypython = pkgs.python311.withPackages (pythonPackageSet: builtins.attrValues {
    #p: with p; [
    inherit
      # see https://discourse.flox.dev/t/questions-around-using-this-with-python-packages/665/6
      (pythonPackageSet)
      sqlglot
      # https://medium.com/social-impact-analytics/extract-text-from-unsearchable-pdfs-for-data-analysis-using-python-a6a2ca0866dd
      pymupdf
      pdf2image
      opencv4
      pytesseract
      ocrmypdf
      pandas
      numpy
      ;
  });
in
pkgs.mkShell {
  inherit name;
  packages = [ mypython ];
}
