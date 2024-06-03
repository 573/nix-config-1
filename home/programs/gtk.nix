
{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.gtk;
in

{

  ###### interface

  options = {

    custom.programs.gtk.enable = mkEnableOption "gtk config";

  };


  ###### implementation

  config = mkIf cfg.enable {
home.packages = with pkgs; [
  arc-theme # see archlinux wiki on gtk_theme
];
};

}
