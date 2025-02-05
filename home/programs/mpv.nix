{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.mpv;
in

{

  ###### interface

  options = {

    custom.programs.mpv.enable = mkEnableOption "mpv config";

  };

  ###### implementation

  config = mkIf cfg.enable {

    programs.mpv = {
      enable = true;

      scripts = builtins.attrValues {
        inherit (pkgs.mpvScripts)
          mpv-playlistmanager
          mpv-cheatsheet
        ;
      };

      bindings = {
        "Ctrl+p" = "script-binding playlistmanager/sortplaylist";
      };
      
    };

  };

}
