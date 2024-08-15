{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    attrValues
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

      ui.gtk.enable = true;
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
        #bookmarks = { };
        extensions = with inputs.firefox-addons.packages.${system}; [
          privacy-possum
          # sourcegraph # > error: cannot download sourcegraph_for_firefox-23.10.9.2250.xpi from any mirror
          facebook-container
          private-relay
          browserpass
	  keepassxc-browser
        ];

  # as in https://github.com/gvolpe/nix-config/blob/6feb7e4f47e74a8e3befd2efb423d9232f522ccd/home/programs/browsers/firefox.nix (https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/21)
  # ~/.mozilla/firefox/PROFILE_NAME/prefs.js | user.js
  settings = {
    "app.normandy.first_run" = false;
    "app.shield.optoutstudies.enabled" = false;

    # disable updates (pretty pointless with nix)
    "app.update.channel" = "default";

    "browser.contentblocking.category" = "standard"; # "strict"
    "browser.ctrlTab.recentlyUsedOrder" = false;

    "browser.download.useDownloadDir" = false;
    "browser.download.viewableInternally.typeWasRegistered.svg" = true;
    "browser.download.viewableInternally.typeWasRegistered.webp" = true;
    "browser.download.viewableInternally.typeWasRegistered.xml" = true;

    "browser.link.open_newwindow" = true;

    #"browser.search.region" = "PL";
    "browser.search.widget.inNavBar" = true;

    "browser.shell.checkDefaultBrowser" = false;
    "browser.startup.homepage" = "https://nixos.org";
    "browser.tabs.loadInBackground" = true;
    "browser.urlbar.placeholderName" = "DuckDuckGo";
    #"browser.urlbar.showSearchSuggestionsFirst" = false;

    # disable all the annoying quick actions
    #"browser.urlbar.quickactions.enabled" = false;
    #"browser.urlbar.quickactions.showPrefs" = false;
    #"browser.urlbar.shortcuts.quickactions" = false;
    #"browser.urlbar.suggest.quickactions" = false;

    "distribution.searchplugins.defaultLocale" = "en-US";

    "doh-rollout.balrog-migration-done" = true;
    "doh-rollout.doneFirstRun" = true;

    "dom.forms.autocomplete.formautofill" = false;

    "general.autoScroll" = true;
    "general.useragent.locale" = "en-US";

    "extensions.activeThemeID" = "firefox-alpenglow@mozilla.org";

    "extensions.extensions.activeThemeID" = "firefox-alpenglow@mozilla.org";
    "extensions.update.enabled" = false;
    "extensions.webcompat.enable_picture_in_picture_overrides" = true;
    "extensions.webcompat.enable_shims" = true;
    "extensions.webcompat.perform_injections" = true;
    "extensions.webcompat.perform_ua_overrides" = true;

    "print.print_footerleft" = "";
    "print.print_footerright" = "";
    "print.print_headerleft" = "";
    "print.print_headerright" = "";

    "privacy.donottrackheader.enabled" = true;

    # Yubikey
    "security.webauth.u2f" = true;
    "security.webauth.webauthn" = true;
    "security.webauth.webauthn_enable_softtoken" = true;
    "security.webauth.webauthn_enable_usbtoken" = true;

    "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
  } // { "layout.css.devPixelsPerPx" = "-1.0"; };

	userChrome = lib.readFile "${inputs.penguin-fox}/files/chrome/userChrome.css";
        userContent = lib.readFile "${inputs.penguin-fox}/files/chrome/userContent.css";
      };
      package = pkgs.wrapFirefox pkgs.firefox-unwrapped {
     # as in https://discourse.nixos.org/t/combining-best-of-system-firefox-and-home-manager-firefox-settings/37721
	extraPolicies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DontCheckDefaultBrowser = true;
      #DisablePocket = true;
      SearchBar = "unified";

      Preferences = let
  lock-false = {
    Value = false;
    Status = "locked";
  };
  lock-true = {
    Value = true;
    Status = "locked";
  };
  lock-empty-string = {
    Value = "";
    Status = "locked";
  };
in {
        # Privacy settings
        #"extensions.pocket.enabled" = lock-false;
        #"browser.newtabpage.pinned" = lock-empty-string;
        "browser.topsites.contile.enabled" = lock-false;
        "browser.newtabpage.activity-stream.showSponsored" = lock-false;
        "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
      };

      ExtensionSettings = {
        "uBlock0@raymondhill.net" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/ublock-origin/latest.xpi";
          installation_mode = "force_installed";
        };
        "jid1-MnnxcxisBPnSXQ@jetpack" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/latest/privacy-badger17/latest.xpi";
          installation_mode = "force_installed";
        };
        "extension@tabliss.io" = {
          install_url = "https://addons.mozilla.org/firefox/downloads/file/3940751/tabliss-2.6.0.xpi";
          installation_mode = "force_installed";
        };
      };
      };
      };
    };

    # https://github.com/google/xsecurelock/issues/102#issuecomment-621432204
    home.sessionVariables.XSECURELOCK_PAM_SERVICE = "lxdm";

    #    home.sessionVariables.XDG_DATA_DIRS = mkAfter [ "${missing-gsettings-schemas-fix}" ];

    home.packages = [chrome
      ausweisapp] ++ (attrValues {
      
      inherit
        (pkgs)
      pavucontrol
      pdftk
      qpdfview
      # https://wiki.archlinux.de/title/Openbox, https://unix.stackexchange.com/a/32217/102072
      obconf
      # DONT home-manager on non-nixos can't manage system files i. e. /etc/pam.d/* see https://github.com/NixOS/nixpkgs/issues/157112
      #xss-lock # reason for slock not being on this list: https://gist.github.com/573/5ce58db3b72913648968968dbfa59d86
      # FIXME do https://github.com/google/xsecurelock/issues/102#issuecomment-621432204 see https://bnikolic.co.uk/nix-cheatsheet.html#orgb5bd923
      #xsecurelock # lxdm not shown
      xscreensaver
      droidcam # host-install v4l2loopback
      vlc
      mediathekview
      xclip
      ;
      inherit
      (pkgs.xorg)
      # https://gist.github.com/573/aa12e8fa8c98aeaf788c3687c3b658dc
      #xorg.xset
      xev
      ;
      inherit
      (pkgs.lxde)
      lxsession
      ;
    });

    home.file.".Xkbmap".text = ''
      -model pc104 -layout us -variant altgr-intl
    '';

  };

}
