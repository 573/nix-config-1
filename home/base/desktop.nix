{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    optionals
    ;
  inherit (pkgs.stdenv.hostPlatform) system;
  cfg = config.custom.base.desktop;

  # TODO Compare the fixGL implementation below to this approach https://github.com/nix-community/nixGL/issues/114#issuecomment-1585323281

  #    missing-gsettings-schemas-fix = builtins.readFile "${pkgs.stdenv.mkDerivation {
  #    name = "missing-gsettings-schemas-fix";
  #    dontUnpack = true; # Make it buildable without “src” attribute
  #    buildInputs = [ pkgs.gtk3 ];
  #    installPhase = '' printf %s "$GSETTINGS_SCHEMAS_PATH" > "$out" '';
  #  }}";

  # https://github.com/search?q=language%3Anix+nixgl.nixGLIntel+alacritty&type=code&ref=advsearch
  # to fix scaling issues on 1440p monitors
  chrome = config.lib.custom.wrapProgram {
    name = "google-chrome-stable";
    desktopFileName = "google-chrome";
    source = pkgs.google-chrome; # needs unfree: inputs.google-chrome.packages.${system}.google-chrome-dev; # pkgs.google-chrome;
    path = "/bin/google-chrome-stable";
    flags = [
      "--force-device-scale-factor=1"
      "--high-dpi-support=1"
    ];
    fixGL = true;
  };

  anbox = config.lib.custom.wrapProgram {
    name = "anbox-application-manager";
    desktopFileName = "anbox-application-manager";
    source = pkgs.anbox; # needs unfree: inputs.google-chrome.packages.${system}.google-chrome-dev; # pkgs.google-chrome;
    path = "/bin/anbox-application-manager";
    fixGL = true;
  };

  # different approach here: https://pmiddend.github.io/posts/nixgl-on-ubuntu
  ausweisapp = config.lib.custom.wrapProgram {
    name = "ausweisapp";
    source = pkgs.ausweisapp;
    path = "/bin/AusweisApp";
    fixGL = true;
  };

  vlc = config.lib.custom.wrapProgram {
    name = "vlc";
    source = pkgs.vlc;
    path = "/bin/vlc";
    fixGL = true;
  };

  spotify = config.lib.custom.wrapProgram {
    name = "spotify";
    source = pkgs.spotify;
    path = "/bin/spotify";
    fixGL = true;
  };

  /*
    mpv = config.lib.custom.wrapProgram {
    name = "mpv";
    desktopFileName = "mpv";
    source = pkgs.mpv;
    path = "/bin/mpv";
    fixGL = false;
  };*/

  #  simple-scan = pkgs.symlinkJoin {
  #    name = "${pkgs.lib.getName pkgs.simple-scan}-wrapper";
  #    nativeBuildInputs = [ pkgs.makeWrapper ];
  #    buildInputs = [ pkgs.gtk3 ];
  #    paths = [ pkgs.simple-scan ];
  #    postBuild = ''
  #      wrapProgram "$out"/bin/simple-scan \
  #        --prefix XDG_DATA_DIRS : "$GSETTINGS_SCHEMAS_PATH"
  #    '';
  #  };

  #xsecurelock = pkgs.xsecurelock.overrideAttrs (oldAttrs: rec {
  #  # FIXME --with-pam-service-name=authproto_pam belongs added after removing --with-pam-service-name=??
  #  configureFlags = (remove "--with-pam-service-name=login" (flatten oldAttrs.configureFlags ++ [ "--with-pam-service-name=lxdm" "--with-xscreensaver=${pkgs.xscreensaver}/libexec/xscreensaver" ])); # ++ [ "--with-pam-service-name=lxdm" "--with-xscreensaver=${pkgs.xscreensaver}/libexec/xscreensaver" ];
  # });
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

    # https://www.codingblatt.de/arch-linux-xsecurelock-screenlocker-einrichten/
    /*
      services.screen-locker = {
      enable = true;
      lockCmd = "${pkgs.xsecurelock}/bin/xsecurelock";
      inactiveInterval = 4;
      xautolock.enable = false;
      xss-lock = {
        extraOptions = [ "-n ${pkgs.xsecurelock}/libexec/xsecurelock/dimmer" "-l" ];
        screensaverCycle = 5;
      };
      };
    */
    # above not working, FIXME override differently see https://bnikolic.co.uk/nix-cheatsheet.html#orgb5bd923
    # creates the .config/systemd/user/xss-lock.service file and 
    # running just systemctl status --user xss-lock.service succeeds
    /*services.screen-locker = {
      enable = true;
      lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
      inactiveInterval = 1;
    };*/

    programs.firefox = {
      enable = true;
      profiles.dani = {
        bookmarks = { };
        extensions = with inputs.firefox-addons.packages.${system}; [
          privacy-possum
          # sourcegraph # > error: cannot download sourcegraph_for_firefox-23.10.9.2250.xpi from any mirror
          facebook-container
          private-relay
          browserpass
        ];
      };
      package = pkgs.firefox;
    };

    # https://github.com/google/xsecurelock/issues/102#issuecomment-621432204
    home.sessionVariables.XSECURELOCK_PAM_SERVICE = "lxdm";

    #    home.sessionVariables.XDG_DATA_DIRS = mkAfter [ "${missing-gsettings-schemas-fix}" ];

    home.packages = with pkgs; [
      #pw-viz
      pavucontrol
      #pwvucontrol
      chrome
      ausweisapp
      gimp
      #skanpage
      #simple-scan # for now use print instead of save as long as file picker not fixed, also: scanner not detected, was in 22.11 though, also file picker crash when saving file
      ##gscan2pdf
      #swingsane # crashes with perms denied
      #libreoffice
      pdftk
      qpdfview
      spotify
      #sshfs
      # https://wiki.archlinux.de/title/Openbox, https://unix.stackexchange.com/a/32217/102072
      obconf
      # https://gist.github.com/573/aa12e8fa8c98aeaf788c3687c3b658dc
      #xorg.xset
      xorg.xev
      lxde.lxsession
      # DONT home-manager on non-nixos can't manage system files i. e. /etc/pam.d/* see https://github.com/NixOS/nixpkgs/issues/157112
      #xss-lock # reason for slock not being on this list: https://gist.github.com/573/5ce58db3b72913648968968dbfa59d86
      # FIXME do https://github.com/google/xsecurelock/issues/102#issuecomment-621432204 see https://bnikolic.co.uk/nix-cheatsheet.html#orgb5bd923
      #xsecurelock # lxdm not shown
      xscreensaver
      droidcam # host-install v4l2loopback
      #mpv
      #libdvdread
      #libdvdcss
      #libdvdnav
      #mplayer
      vlc
      #xorg.libXpresent
      #xine-ui
      #xine-lib
      mediathekview
      xclip
      anbox
    ] ++ (optionals cfg.private [
    ]);

    home.file.".Xkbmap".text = ''
      -model pc104 -layout us -variant altgr-intl
    '';

  };

}
