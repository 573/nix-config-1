{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.backblaze;
in

{

  ###### interface

  options = {

    custom.programs.backblaze.enable = mkEnableOption "backblaze config";

  };

  ###### implementation

  config = mkIf cfg.enable {

  };
}
