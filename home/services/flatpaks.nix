{ config, lib, inputs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.services.flatpaks;
in

{
  imports = [ inputs.flatpaks.homeManagerModules.nix-flatpak ];

  ###### interface

  options = {

    custom.services.flatpaks.enable = mkEnableOption "flatpaks config";

  };


  ###### implementation

  config = mkIf cfg.enable {

    services.flatpak.packages = [
      #      "im.riot.Riot"
      #      "com.github.KRTirtho.Spotube"
    ];

  };

}
