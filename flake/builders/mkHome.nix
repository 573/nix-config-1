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
    inherit inputs rootPath system;
    libreoffice-postscript = inputs.libreoffice-postscript.legacyPackages.${system};

    inherit (inputs.nixvim.legacyPackages.${system}) makeNixvim makeNixvimWithModule;
    haskellPackages = inputs.ghc-nixpkgs-unstable.legacyPackages.${system}.haskellPackages;
    ghc-nixpkgs-unstable = inputs.ghc-nixpkgs-unstable.legacyPackages.${system};
    unstable = inputs.unstable.legacyPackages.${system};
    zellij =
      if isLinux && isAarch64 then
        inputs.nixos-2405.legacyPackages.${system}.zellij
      else
        inputs.nixpkgs.legacyPackages.${system}.zellij;
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
      # should not break with raspberry as it concerns only non-nixos
      if isLinux && isAarch64 then "/data/data/com.termux.nix/files/home" else "/home/${username}";
    inherit username;
  };

  modules = [
    /**
      as in ./../../lib/common-config.nix `homeManager.userConfig`
    */
    "${rootPath}/hosts/${hostname}/home-${username}.nix"
  ]
  ++ homeModulesFor.${system};
}
