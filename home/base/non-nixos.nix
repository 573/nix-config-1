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
    mkMerge
    mkOption
    optional
    optionals
    types
    unique
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
	# DONE Make configurable the other way around in nixbuild dependent on this builders here, explainer https://gist.github.com/573/1ff0527f8b42b0123dc3a13bc523f487
        default = [];# ++ optional config.custom.programs.nixbuild.enable "ssh://root@eu.nixbuild.net aarch64-linux,armv7l-linux /home/${config.home.username}/.ssh/my-nixbuild-key 100 2 benchmark,big-parallel - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBJUUNaYzU0cG9KOHZxYXdkOFRyYU5yeVFlSm52SDFlTHBJRGdiaXF5bU0K";
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
