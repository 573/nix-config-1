{
  system,
  pkgsFor,
  name,
  ...
}:
let
  pkgs = pkgsFor.${system};
  # see https://discourse.nixos.org/t/help-using-poetry-in-a-flake-devshell/36874/3
  mypython = pkgs.python311.withPackages (
    pythonPackageSet:
    builtins.attrValues {
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
	# FIXME i. e. https://discourse.nixos.org/t/anyone-has-a-working-jupyterhub-jupyter-lab-setup/7659/2 or https://github.com/stuzenz/nix-sample-jupyterlab-nix-shell or https://discourse.nixos.org/t/how-to-work-with-broken-jupyterhub-package-service/29663/4 https://www.reddit.com/r/NixOS/comments/1b95pv4/comment/ktvwruz/
jupyterlab
jupyterlab-git
        ;
    }
  );
in
pkgs.mkShell {
  inherit name;
  packages = [ mypython ];
}
