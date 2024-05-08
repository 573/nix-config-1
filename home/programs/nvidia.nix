
{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.nvidia;
in

{

  ###### interface

  options = {

    custom.programs.nvidia.enable = mkEnableOption "nvidia config";

  };


  ###### implementation

  config = mkIf cfg.enable {
  };

}
