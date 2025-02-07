{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.agenix;
in

{

  ###### interface

  options = {

    custom.programs.agenix.enable = mkEnableOption "agenix config";

  };

  ###### implementation

  config = mkIf cfg.enable {

  };
}
