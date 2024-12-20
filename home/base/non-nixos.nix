/**
  `@configArgs` as below provided to `commonConfig`, latter defined in ./../../lib/common-config.nix and bound in ./../../lib/default.nix as well as in ./../../flake/default.nix under the attribute name `customLibFor` where also a module with a mere attribute `lib.custom`is included with the `homeModulesFor` function
*/
{
  config,
  lib,
  pkgs,
  ...
}@configArgs:

let
  inherit (lib)
    concatStringsSep
    mkEnableOption
    mkIf
    mkOption
    optionals
    types
    ;

  cfg = config.custom.base.non-nixos;

  commonConfig = config.lib.custom.commonConfig configArgs;
in

{

  ###### interface

  options = {

    custom.base.non-nixos = {
      enable = mkEnableOption "config for non NixOS systems";

      installNix = mkEnableOption "nix installation" // {
        default = true;
      };

      builders = mkOption {
        type = types.listOf types.str;
        default = [
	  "ssh://eu.nixbuild.net aarch64-linux,armv7l-linux - 100 1 benchmark,big-parallel - -"
        ];
        description = "Nix remote builders.";
      };
    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    home = {
      packages = optionals cfg.installNix [ config.nix.package ];
      sessionVariables.NIX_PATH = concatStringsSep ":" commonConfig.nix.nixPath;
      sessionVariables.TERMINFO = "${pkgs.ncurses}/share/terminfo";
    };

    nix = {
      settings = {
        inherit (commonConfig.nix.settings)
          experimental-features
          flake-registry
          log-lines
          substituters
          trusted-public-keys
          ;

        builders = concatStringsSep ";" cfg.builders;
        builders-use-substitutes = mkIf (cfg.builders != [ ]) true;
        trusted-users = [ config.home.username ];
      };

      inherit (commonConfig.nix)
        package
        registry
        ;
    };

    targets.genericLinux.enable = true;
  };
}
