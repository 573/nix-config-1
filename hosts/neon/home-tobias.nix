{ config, lib, pkgs, ... }:

{
  custom = {
    base.desktop = {
      enable = true;
      laptop = true;
      private = true;
    };

    misc = {
      backup = {
        enable = true;
        directories = [
          "~/Documents/finance"
          "~/Documents/general"
          "~/Documents/lajazzo-media"
          "~/Documents/lajazzo-noten"
        ];
      };

      sdks = {
        enable = true;
        links = {
          inherit (pkgs) python310;
        };
      };
    };

    programs = {
      go.enable = true;

      vscode.enable = true;
    };

    services.dwm-status.backlightDevice = "amdgpu_bl*";

    wm.dwm.enable = true;
  };

  home.packages = with pkgs; [
    openshot-qt
    portfolio
    skypeforlinux
    vlc
    zoom-us
  ];

  services.blueman-applet.enable = true;

  xsession.initExtra = ''
    xinput set-prop "UNIW0001:00 093A:0255 Touchpad" "Coordinate Transformation Matrix" 5 0 0 0 5 0 0 0 1
  '';
}
