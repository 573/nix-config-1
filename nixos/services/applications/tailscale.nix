{
  config,
  lib,
  rootPath,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.services.tailscale;
in

{

  ###### interface

  options = {

    custom.services.tailscale = {
      enable = mkEnableOption "tailscale conf";
    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    services.tailscale = {
      enable = true;
    };
  };

}
