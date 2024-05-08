{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.audio;
in

{

  ###### interface

  options = {

    custom.programs.audio.enable = mkEnableOption "audio config";

  };


  ###### implementation

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      qpwgraph
      pwvucontrol
      helio-workstation
    ];
  };

}
