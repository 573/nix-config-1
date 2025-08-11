/**
  Parameter `[inputs]` here is a deviation from the orinal author's intent (doing that via overlay) and should maybe be fixed
*/
{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    attrValues
    ;
  /**
    Attribute `system` here is determined that way (`inherit (pkgs.stdenv.hostPlatform) system;`) to make later use of parameter `[inputs]` here in this file (./../../home/base/desktop.nix), which is a deviation from the orinal author's intent (there an overlay is used to determine derivations from inputs, the intention of which is fine to narrow down `system` use to flake-related nix files I guess).

    If I want to rid overlays I might have to find a way with less potentially bad implications, IDK are there any ?
  */
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
    #   fixGL = true;
  };

  # different approach here: https://pmiddend.github.io/posts/nixgl-on-ubuntu
  ausweisapp = config.lib.custom.wrapProgram {
    name = "ausweisapp";
    source = pkgs.ausweisapp;
    path = "/bin/AusweisApp";
    #   fixGL = true;
  };

  emacs = config.lib.custom.wrapProgram {
    name = "emacs";
    source = config.custom.programs.emacs-configured.finalPackage;
    path = "/bin/emacs";
  };

  vlc = config.lib.custom.wrapProgram {
    name = "vlc";
    source = pkgs.vlc;
    path = "/bin/vlc";
    # TODO proof of https://github.com/nix-community/home-manager/pull/5355#issuecomment-2426908650 more here https://nix-community.github.io/home-manager/#sec-usage-gpu-non-nixos
    #    fixGL = true;
  };

  wezterm = config.lib.custom.wrapProgram {
    name = "wezterm";
    source = pkgs.wezterm;
    path = "/bin/wezterm";
  };

  kitty = config.lib.custom.wrapProgram {
    name = "kitty";
    source = pkgs.kitty;
    path = "/bin/kitty";
  };

  /*
      mpv = config.lib.custom.wrapProgram {
      name = "mpv";
      desktopFileName = "mpv";
      source = pkgs.mpv;
      path = "/bin/mpv";
      fixGL = false;
    };
  */

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

in
# see also: https://github.com/Gerschtli/nix-config/commit/6ddf3aac08b1d21cda997542b0aef0ad41b4f723#diff-b49215b74a3855b7a44e508b5459197be8c4a1636f55d7bb593d3890fc295dd8R29
#xsecurelock = pkgs.xsecurelock.overrideAttrs (oldAttrs: rec {
#  # FIXME --with-pam-service-name=authproto_pam belongs added after removing --with-pam-service-name=??
#  configureFlags = (remove "--with-pam-service-name=login" (flatten oldAttrs.configureFlags ++ [ "--with-pam-service-name=lxdm" "--with-xscreensaver=${pkgs.xscreensaver}/libexec/xscreensaver" ])); # ++ [ "--with-pam-service-name=lxdm" "--with-xscreensaver=${pkgs.xscreensaver}/libexec/xscreensaver" ];
# });

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
    /*
      services.screen-locker = {
        enable = true;
        lockCmd = "${pkgs.i3lock}/bin/i3lock -n -c 000000";
        inactiveInterval = 1;
      };
    */

  # FIXME careful changing that, Workaround: nix run --impure github:nix-community/nixGL -- AusweisApp
  nixGL = {
    packages = inputs.nixGL.packages;#import inputs.nixGL { inherit pkgs; }; # 
    defaultWrapper = "mesa";
  };

    programs.firefox = lib.optionalAttrs (!config.custom.base.general.wsl) {
      enable = true;

      # https://discourse.nixos.org/t/declare-firefox-extensions-and-settings/36265/17
      policies = {
        ExtensionSettings =
          with builtins;
          let
            extension = shortId: uuid: {
              name = uuid;
              value = {
                install_url = "https://addons.mozilla.org/en-US/firefox/downloads/latest/${shortId}/latest.xpi";
                installation_mode = "normal_installed";
              };
            };
          in
          listToAttrs [
            (extension "tree-style-tab" "treestyletab@piro.sakura.ne.jp")
            (extension "ublock-origin" "uBlock0@raymondhill.net")
            (extension "bitwarden-password-manager" "{446900e4-71c2-419f-a6a7-df9c091e268b}")
            (extension "tabliss" "extension@tabliss.io")
            (extension "umatrix" "uMatrix@raymondhill.net")
            #(extension "libredirect" "7esoorv3@alefvanoon.anonaddy.me")
            (extension "clearurls" "{74145f27-f039-47ce-a470-a662b129930a}")
            (extension "privacy-badger17" "jid1-MnnxcxisBPnSXQ@jetpack")
            (extension "qwantcom-for-firefox" "qwantcomforfirefox@jetpack")
            (extension "sourcegraph-for-firefox" "sourcegraph-for-firefox@sourcegraph.com")
            (extension "linkding-extension" "{61a05c39-ad45-4086-946f-32adb0a40a9d}")
            (extension "hackertab-dev" "{f8793186-e9da-4332-aa1e-dc3d9f7bb04c}")
          ];
        # To add additional extensions, https://github.com/tupakkatapa/mozid
      };

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
        # FIXME https://github.com/toonn/nix-config/blob/master/home/ff-webgl-userjs.nixos
        # FIXME https://github.com/toonn/nix-config/blob/a3877b34ec7d8ce3fda6cd33cf5cad3617103272/home/home.nix#L150
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
        }
        // {
          "layout.css.devPixelsPerPx" = "-1.0";
        };

        #userChrome = lib.readFile "${inputs.penguin-fox}/files/chrome/userChrome.css";
        #userContent = lib.readFile "${inputs.penguin-fox}/files/chrome/userContent.css";
      };
      # https://home-manager-options.extranix.com/?query=firefox
      # https://github.com/NixOS/nixpkgs/blob/master/pkgs/applications/networking/browsers/firefox/wrapper.nix
      package = pkgs.wrapFirefox inputs.firefox.packages.${system}.firefox-nightly-bin.unwrapped {
        # as in https://discourse.nixos.org/t/combining-best-of-system-firefox-and-home-manager-firefox-settings/37721
        extraPolicies = {
          DisableTelemetry = true;
          DisableFirefoxStudies = true;
          DontCheckDefaultBrowser = true;
          #DisablePocket = true;
          SearchBar = "unified";

          Preferences =
            let
              lock-false = {
                Value = false;
                Status = "locked";
              };
            in
            {
              # Privacy settings
              #"extensions.pocket.enabled" = lock-false;
              #"browser.newtabpage.pinned" = lock-empty-string;
              "browser.topsites.contile.enabled" = lock-false;
              "browser.newtabpage.activity-stream.showSponsored" = lock-false;
              "browser.newtabpage.activity-stream.system.showSponsored" = lock-false;
              "browser.newtabpage.activity-stream.showSponsoredTopSites" = lock-false;
            };
        };
      };
    };

    # https://github.com/google/xsecurelock/issues/102#issuecomment-621432204
    home.sessionVariables.XSECURELOCK_PAM_SERVICE = "lxdm";

    #    home.sessionVariables.XDG_DATA_DIRS = mkAfter [ "${missing-gsettings-schemas-fix}" ];

    home.packages = attrValues (
      {
        keyboard-de = pkgs.writeShellApplication {
          name = "keyboard-de";
          runtimeInputs = [
            pkgs.xorg.setxkbmap
            pkgs.runtimeShell
          ];

          text = ''
            #!${pkgs.runtimeShell}

            setxkbmap -model pc104 -layout de
          '';
        };

        keyboard-en = pkgs.writeShellApplication {
          name = "keyboard-en";
          runtimeInputs = [
            pkgs.xorg.setxkbmap
            pkgs.runtimeShell
          ];

          text = ''
            #!${pkgs.runtimeShell}

            setxkbmap -model pc104 -layout us -variant altgr-intl
          '';
        };
      }
      // lib.optionalAttrs (!config.custom.base.general.wsl) {
        # only install these if not on nixos-wsl
        chrome = config.lib.nixGL.wrap chrome;
        ausweisapp = config.lib.nixGL.wrap ausweisapp;
        vlc = config.lib.nixGL.wrap vlc;
        wezterm = config.lib.nixGL.wrap wezterm;
        kitty = config.lib.nixGL.wrap kitty;
        emacs = config.lib.nixGL.wrap emacs;

        inherit (pkgs)
          pavucontrol
          pdftk
          csvkit
          qpdfview
          # https://wiki.archlinux.de/title/Openbox, https://unix.stackexchange.com/a/32217/102072
          obconf
          # DONT home-manager on non-nixos can't manage system files i. e. /etc/pam.d/* see https://github.com/NixOS/nixpkgs/issues/157112
          #xss-lock # reason for slock not being on this list: https://gist.github.com/573/5ce58db3b72913648968968dbfa59d86
          # FIXME do https://github.com/google/xsecurelock/issues/102#issuecomment-621432204 see https://bnikolic.co.uk/nix-cheatsheet.html#orgb5bd923
          #xsecurelock # lxdm not shown
          xscreensaver
          droidcam # host-install v4l2loopback
          mediathekview
          xclip
          age-plugin-yubikey # arch: https://github.com/str4d/age-plugin-yubikey
          ;
        inherit (pkgs.xorg)
          # https://gist.github.com/573/aa12e8fa8c98aeaf788c3687c3b658dc
          #xorg.xset
          xev
          ;
        inherit (pkgs.lxde)
          lxsession
          ;
      }
    );

    # FIXME NixOS only: https://search.nixos.org/options?type=packages&query=services.xserver.xkb
    # https://wiki.archlinux.org/title/Xorg/Keyboard_configuration#Using_localectl
    home.file.".Xkbmap".text = ''
      -model pc104 -layout us -variant altgr-intl
    '';

  };

}
