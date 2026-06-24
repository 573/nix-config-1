{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkForce
    mkIf
    mkMerge
    ;

  cfg = config.custom.base.desktop;
in

{

  ###### interface

  options = {

    custom.base.desktop = {
      enable = mkEnableOption "basic desktop config";

      enableXserver = mkEnableOption "xserver config" // {
        default = true;
      };

      laptop = mkEnableOption "services and config for battery, network, backlight";
    };

  };

  ###### implementation

  config = mkIf cfg.enable (mkMerge [
    {
      boot = {
        # The default max inotify watches is 8192.
        # Nowadays most apps require a good number of inotify watches,
        # the value below is used by default on several other distros.
        kernel.sysctl."fs.inotify.max_user_watches" = 524288;

        tmp.useTmpfs = true;
      };

      custom.system.boot.mode = "efi";

      fonts = {
        enableDefaultPackages = true;
        enableGhostscriptFonts = true;
        fontDir.enable = true;
        fontconfig.enable = true;
        fontconfig.defaultFonts.monospace = [ "UbuntuMono Nerd Font" ];

        # fc-list for font names
        packages = with pkgs; [
          nerd-fonts.ubuntu-mono
        ];
      };

      hardware.graphics.enable = true;

      programs.ssh.askPassword = "";

      services = {
        #25.05 pipewire.enable = false;

        #25.05 pulseaudio.enable = true;

        xserver = mkIf cfg.enableXserver {
          enable = true;
          desktopManager = {
            xterm.enable = false;
            xfce = {
              enable = true;
              noDesktop = true;
              enableXfwm = false;
            };
          };
          windowManager.i3 = {
            enable = true;
            extraPackages = with pkgs; [
              dmenu
              i3status
              i3lock
            ];
          };

          # Enable the XFCE Desktop Environment.
          #          displayManager.lightdm.enable = true;
          #          desktopManager.xfce.enable = true;

          # Configure keymap in X11
          xkb = {
            layout = "us";
            variant = "intl";
          };
        };
      };

      services.displayManager.defaultSession = "xfce";

      programs.thunar.enable = lib.mkForce false;

      environment = {
        xfce.excludePackages = with pkgs.xfce; [
          parole
          ristretto
          xfce4-terminal
          xfce4-dict
        ];
        systemPackages = with pkgs; [
          exfat
          ntfs3g

          jmtpfs # use like jmtpfs /mnt
          #drawing
          #font-manager
          #gimp-with-plugins
          #inkscape-with-extensions
          #libqalculate
          orca
          pavucontrol
          #qalculate-gtk
          wmctrl
          xclip
          #xcolor
          xdo
          xdotool
          xfce.catfish
          xfce.gigolo
          #xfce.orage
          #xfce.xfburn
          xfce.xfce4-appfinder
          xfce.xfce4-clipman-plugin
          xfce.xfce4-cpugraph-plugin
          xfce.xfce4-dict
          xfce.xfce4-fsguard-plugin
          xfce.xfce4-genmon-plugin
          xfce.xfce4-netload-plugin
          xfce.xfce4-panel
          xfce.xfce4-pulseaudio-plugin
          xfce.xfce4-systemload-plugin
          xfce.xfce4-weather-plugin
          xfce.xfce4-whiskermenu-plugin
          xfce.xfce4-xkb-plugin
          xfce.xfdashboard
          xorg.xev
          xsel
          xtitle
        ];
      };

      # Configure console keymap
      console.keyMap = "us-acentos";

      # Enable CUPS to print documents.
      services.printing.enable = true;

      xdg = {
        autostart.enable = true;
        icons.enable = true;
        menus.enable = true;
        mime.enable = true;
        sounds.enable = true;
      };
    }

    (mkIf cfg.laptop {
      hardware.bluetooth = {
        enable = true;
        disabledPlugins = [ "sap" ];
        # fix error logs on boot
        settings.General.Experimental = true;
      };

      networking.networkmanager = {
        enable = true;
        plugins = mkForce [ ]; # FIXME: disabled because openconnect is not substitutable currently
      };

      programs.light.enable = true;

      services = {
        blueman.enable = true;

        libinput = mkIf cfg.enableXserver {
          enable = true;
          touchpad = {
            accelProfile = "flat";
            additionalOptions = ''
              Option "TappingButtonMap" "lmr"
            '';
          };
        };

        logind.settings.Login = {
          HandlePowerKey = "ignore";
        };

        # for bluetooth support
        #25.05 pulseaudio.package = pkgs.pulseaudioFull;

        tlp.enable = true;

        upower.enable = true;
      };

      users.users.dani.extraGroups = [
        "networkmanager"
        "video"
      ];
    })

  ]);

}
