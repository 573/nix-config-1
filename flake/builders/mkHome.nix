{ inputs, rootPath, system, pkgsFor, homeModulesFor, name, ... }:

let
  # splits "username@hostname"
  splittedName = inputs.nixpkgs.lib.splitString "@" name;

  username = builtins.elemAt splittedName 0;
  hostname = builtins.elemAt splittedName 1;
in

/**
see also ./../../lib/common-config.nix `homeManager.baseConfig.extraSpecialArgs` there and `homeManager.userConfig`
*/
inputs.home-manager.lib.homeManagerConfiguration {
  pkgs = pkgsFor.${system};
  /**
    as in ./../../lib/common-config.nix `homeManager.baseConfig.extraSpecialArgs`
  */
  extraSpecialArgs = { inherit inputs rootPath; };

  modules = [
    /**
    as in ./../../lib/common-config.nix `homeManager.userConfig`
    */
    "${rootPath}/hosts/${hostname}/home-${username}.nix"
  ]
  ++ homeModulesFor.${system};
}
