{
  config,
  lib,
  zellij,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.programs.zellij;
in

{

  ###### interface

  options = {

    custom.programs.zellij = {
      enable = mkEnableOption "zellij config";

      finalPackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package of final zellij.
        '';
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.zellij.finalPackage = config.programs.zellij.package;

    programs.zellij = {
      enable = true;

      package = zellij;

      enableBashIntegration = true;
    };
  };
}
