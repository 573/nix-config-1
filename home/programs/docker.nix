
{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.docker;
in

{

  ###### interface

  options = {

    custom.programs.docker.enable = mkEnableOption "docker config";

  };


  ###### implementation

  config = mkIf cfg.enable {
  };

}
