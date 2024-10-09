{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.dvdplayback;
in

{

  ###### interface

  options = {

    custom.programs.dvdplayback.enable = mkEnableOption "dvdplayback config";

  };

  ###### implementation

  config = mkIf cfg.enable { };

}
