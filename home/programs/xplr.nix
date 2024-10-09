{
  pkgs,
  config,
  lib,
  inputs,
  unstable,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.programs.xplr;
in

{

  ###### interface

  options = {

    custom.programs.xplr = {
      enable = mkEnableOption "xplr config";

      finalPackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package of final emacs-nano.
        '';
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.xplr.finalPackage = config.programs.xplr.package;

    programs.xplr = {
      enable = true;

      package = unstable.xplr;

      extraConfig = ''
require("ouch").setup()
      '';

        plugins = {
	  ouch = inputs.ouch-xplr;
       };
    };

    xdg.enable = true;

# https://github.com/dtomvan/ouch.xplr
    xdg.configFile."xplr/plugins/ouch".source = inputs.ouch-xplr;
#    xdg.configFile."xplr/init.lua".text = ''
#require("ouch").setup()
#    '';
    # https://github.com/GianniBYoung/rsync.yazi https://github.com/KKV9/compress.yazi https://github.com/ndtoan96/ouch.yazi
    home.packages = [
      unstable._7zz
#      unstable.ouch
    ];
  };
}
