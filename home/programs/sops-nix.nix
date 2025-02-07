{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.sops-nix;
in

{

  ###### interface

  options = {

    custom.programs.sops-nix.enable = mkEnableOption "sops-nix config";

  };

  ###### implementation

  config = mkIf cfg.enable {

  };
}
