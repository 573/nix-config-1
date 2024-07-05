{ config, lib, pkgs, inputs, ... }:

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
      extraPortals = [ pkgs.xdg-desktop-portal-gtk pkgs.xdg-desktop-portal-gnome ];
      xdgOpenUsePortal = true;
    };
    home.sessionVariables.GTK_THEME = "Catppuccin-Macchiato-Compact-Pink-Dark";
    gtk = {
      enable = true;
      theme = {
        # If you have tweaks, then the name should be catppuccin-<flavor>-<accent>-<size>+tweak1,tweak2,... where tweaks = [ "tweak1" "tweak2" ... ]
        name = "catppuccin-macchiato-pink-compact+rimless,black";
        package = pkgs.catppuccin-gtk.override {
          accents = [ "pink" ];
          size = "compact";
          tweaks = [ "rimless" "black" ];
          variant = "macchiato";
        };
      };
      iconTheme = {
        name = "Colloid";
        package = pkgs.colloid-icon-theme;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };


      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = 1;
      };
    };

    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      name = "Bibata-Modern-Ice";
      package = pkgs.bibata-cursors;
      size = 20;
    };

    home.packages = with pkgs; [
      # qpwgraph
      #pwvucontrol
      #helio-workstation
    ];
  };

}
