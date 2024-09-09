/**
Original author's home'nix files are always prefixed with `{ config, lib, pkgs, ... }:` header

For `[latest]` and `[unstable]` parameters determine a solution (./../../nixos/programs/docker.nix also has the issue yet)
*/
{ config, lib, pkgs, /*unstable,*/ ... }:

let
  inherit (lib)
    attrValues
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
    home.packages = attrValues {
      # with pkgs; [
      inherit
        (pkgs)
        qpwgraph
        helio-workstation
        ;

      inherit
        (pkgs)
        pwvucontrol
        ;
    };
  };

}
