{ inputs, rootPath, system, pkgsFor, homeModulesFor, name, ... }:

let
  # splits "username@hostname"
  splittedName = inputs.nixpkgs.lib.splitString "@" name;

  username = builtins.elemAt splittedName 0;
  hostname = builtins.elemAt splittedName 1;

  inherit (pkgsFor.${system}.stdenv) isLinux isAarch64;
in

/**
see also ./../../lib/common-config.nix `homeManager.baseConfig.extraSpecialArgs` there and `homeManager.userConfig`
*/
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = pkgsFor.${system};
  /**
    as in ./../../lib/common-config.nix `homeManager.baseConfig.extraSpecialArgs`
  */
  extraSpecialArgs = { 
    inherit inputs rootPath;
    libreoffice-postscript = inputs.libreoffice-postscript.legacyPackages.${system};

    emacs = if isLinux && isAarch64
      then inputs.emacs-overlay-cached.packages.${system}.emacs-unstable-nox
      else inputs.emacs-overlay.packages.${system}.emacs-unstable;

    emacsWithPackagesFromUsePackage = if isLinux && isAarch64 
      then inputs.emacs-overlay-cached.lib.${system}.emacsWithPackagesFromUsePackage
      else inputs.emacs-overlay.lib.${system}.emacsWithPackagesFromUsePackage;
  };

  modules = [
    /**
    as in ./../../lib/common-config.nix `homeManager.userConfig`
    */
    "${rootPath}/hosts/${hostname}/home-${username}.nix"
  ]
  ++ homeModulesFor.${system};
}
