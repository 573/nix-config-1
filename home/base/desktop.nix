{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    optionals
    ;

  cfg = config.custom.base.desktop;

  # to fix scaling issues on 1440p monitors
  chrome = config.lib.custom.wrapProgram {
    name = "google-chrome-stable";
    desktopFileName = "google-chrome";
    source = pkgs.google-chrome;
    path = "/bin/google-chrome-stable";
    flags = [
      "--force-device-scale-factor=1"
      "--high-dpi-support=1"
    ];
    fixGL = true;
  };
in

{

  ###### interface

  options = {

    custom.base.desktop = {
      enable = mkEnableOption "desktop setup";

      laptop = mkEnableOption "laptop config";

      private = mkEnableOption "private desktop config";
    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom = {
      development.direnv.enable = true;

      programs = { };
    };

    home.packages = with pkgs; [
      chrome
      gimp
      libreoffice
      pdftk
      qpdfview
      spotify
      sshfs
    ] ++ (optionals cfg.private [
    ]);

  };

}
