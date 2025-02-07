{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.borgmatic;
in

{

  ###### interface

  options = {

    custom.programs.borgmatic.enable = mkEnableOption "borgmatic config";

  };

  ###### implementation

  config = mkIf cfg.enable {

  };
}
