{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.ui.gtk;
in

{
  #  disabledModules = [ "${inputs.home-manager.outPath}/modules/misc/gtk.nix" ];

  #  imports = [ 
  #    (args@{ config, lib, pkgs, ... }:
  #      import "${inputs.home-manager-2211.outPath}/modules/misc/gtk.nix"
  #        (args // { pkgs = inputs.nixos-2211.legacyPackages.${pkgs.system}; })
  #    )
  #  ];

  imports = [
    inputs.catppuccin.homeManagerModules.catppuccin
  ];

  ###### interface

  options = {

    custom.ui.gtk.enable = mkEnableOption "gtk config";

  };

  ###### implementation

  config = mkIf cfg.enable {
    xdg.portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = [
        pkgs.xdg-desktop-portal-gtk
        pkgs.xdg-desktop-portal-gnome
      ];
      xdgOpenUsePortal = true;
    };

    # https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
    # https://github.com/Hoverbear-Consulting/flake/blob/89cbf802a0be072108a57421e329f6f013e335a6/users/ana/home.nix
    gtk = {
      enable = true;
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      theme = {
        name = "palenight";
        package = pkgs.palenight-theme;
      };
      cursorTheme = {
        name = "Numix-Cursor";
        package = pkgs.numix-cursor-theme;
      };
      gtk3.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };
      gtk4.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };
    };

    #programs.dconf.enable = true;

    # Use `dconf watch /` to track stateful changes you are doing and store them here.
    dconf.settings = {
      "org/gnome/shell" = {
        disable-user-extensions = false;
        # `gnome-extensions list` for a list
        enabled-extensions = [
          "user-theme@gnome-shell-extensions.gcampax.github.com"
          "trayIconsReloaded@selfmade.pl"
          "Vitals@CoreCoding.com"
          "dash-to-panel@jderose9.github.com"
          "sound-output-device-chooser@kgshank.net"
          "space-bar@luchrioh"
        ];
        favorite-apps = [
          "firefox.desktop"
          "code.desktop"
          "org.gnome.Terminal.desktop"
          "spotify.desktop"
          "virt-manager.desktop"
          "org.gnome.Nautilus.desktop"
        ];
      };
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
        enable-hot-corners = false;
      };
      # `gsettings get org.gnome.shell.extensions.user-theme name`
      "org/gnome/shell/extensions/user-theme" = {
        name = "palenight";
      };
      "org/gnome/desktop/wm/preferences" = {
        workspace-names = [ "Main" ];
      };
      "org/gnome/shell/extensions/vitals" = {
        show-storage = false;
        show-voltage = true;
        show-memory = true;
        show-fan = true;
        show-temperature = true;
        show-processor = true;
        show-network = true;
      };
      "org/gnome/desktop/background" = {
        picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/vnc-l.png";
        picture-uri-dark = "file:///run/current-system/sw/share/backgrounds/gnome/vnc-d.png";
      };
      "org/gnome/desktop/screensaver" = {
        picture-uri = "file:///run/current-system/sw/share/backgrounds/gnome/vnc-d.png";
        primary-color = "#3465a4";
        secondary-color = "#000000";
      };
    };

    home.packages = builtins.attrValues {
      inherit (pkgs.gnomeExtensions)
        user-themes
        tray-icons-reloaded
        vitals
        dash-to-panel
        sound-output-device-chooser
        space-bar
        ;
    };
    home.sessionVariables.GTK_THEME = "palenight";

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      name = "Numix-Cursor";
      package = pkgs.numix-cursor-theme;
      size = 20;
    };

  };

}
