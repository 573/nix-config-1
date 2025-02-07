{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.restic;
in

{

  ###### interface

  options = {

    custom.programs.restic.enable = mkEnableOption "restic config";

  };

  ###### implementation

  config = mkIf cfg.enable {

  };
}
