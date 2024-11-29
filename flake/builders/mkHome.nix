{
  inputs,
  rootPath,
  system,
  pkgsFor,
  homeModulesFor,
  name,
  ...
}:

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
    These herein are needed for ./../../home/ modules' parameters
  */
  extraSpecialArgs = {
    inherit inputs rootPath;
    libreoffice-postscript = inputs.libreoffice-postscript.legacyPackages.${system};

    inherit (inputs.nixvim.legacyPackages.${system}) makeNixvim makeNixvimWithModule;
    haskellPackages = inputs.ghc-nixpkgs-unstable.legacyPackages.${system}.haskell.packages.ghc965;
    ghc-nixpkgs-unstable = inputs.ghc-nixpkgs-unstable.legacyPackages.${system};
    unstable = inputs.unstable.legacyPackages.${system};
    zellij =
      if isLinux && isAarch64
        then
        inputs.nixos-2405.legacyPackages.${system}.zellij
      else
        inputs.unstable.legacyPackages.${system}.zellij; 
    yazi =
      if isLinux && isAarch64 then
        inputs.nixpkgs.legacyPackages.${system}.yazi
      else
        inputs.unstable.legacyPackages.${system}.yazi;
    emacs =
      if isLinux && isAarch64 then
        inputs.emacs-overlay-cached.packages.${system}.emacs-unstable-nox
      else
        inputs.emacs-overlay.packages.${system}.emacs-unstable;

    emacsWithPackagesFromUsePackage =
      if isLinux && isAarch64 then
        inputs.emacs-overlay-cached.lib.${system}.emacsWithPackagesFromUsePackage
      else
        inputs.emacs-overlay.lib.${system}.emacsWithPackagesFromUsePackage;

    homeDir =
      if isLinux && isAarch64 then
        "/data/data/com.termux.nix/files/home"
      else
        "/home/${username}";
  };

  modules = [
    /**
      as in ./../../lib/common-config.nix `homeManager.userConfig`
    */
    "${rootPath}/hosts/${hostname}/home-${username}.nix"
  ] ++ homeModulesFor.${system};
}
