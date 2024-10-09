/**
  Original author's home'nix files are always prefixed with `{ config, lib, pkgs, ... }:` header

  For `[haskellPackages]` parameter determine a solution (./../../nixos/programs/docker.nix also has the issue yet)
*/
{
  config,
  lib,
  pkgs,
  libreoffice-postscript,
  rootPath,
  ...
}:
let
  inherit (lib)
    attrValues
    mkDefault
    ;
  inherit (pkgs)
    writeScriptBin
    runtimeShell
    ;
in
/**
  Attribute `system` here is determined that way (`inherit (pkgs.stdenv.hostPlatform) system;`) to make later use of parameter `[inputs]` here in this file (./../../home/base/desktop.nix), which is a deviation from the orinal author's intent (there an overlay is used to determine derivations from inputs, the intention of which is fine to narrow down `system` use to flake-related nix files I guess).

  If I want to rid overlays I might have to find a way with less potentially bad implications, IDK are there any ?
*/
#inherit (pkgs.stdenv.hostPlatform) system;
{
  custom = {
    base = {
      desktop = {
        enable = true;
        laptop = true;
      };

      non-nixos.enable = true;
    };

    development = {
      nix.home-manager.enable = true;
    };

    programs = {
      shell.initExtra = ''
        #. ${config.home.homeDirectory}/.aliases.sh
      '';

      hledger.enable = true;

      audio.enable = true;

      arbtt.enable = true;
    };
  };

  # https://mipmip.github.io/home-manager-option-search/?query=syncthing
  services.syncthing = {
    enable = true;
    tray.enable = true;
    # https://docs.syncthing.net/users/syncthing.html#cmdoption-home
    #extraOptions = [ "--option=value" ];
  };

  #xsession = {
  #  enable = true;
  #  # the default is fine here, then I only need to create ~/.xsession file in Archlinux 
  #  windowManager.i3 = {
  #    enable = true;
  #  };
  #};

  # slock needs group "nogroup" to work, https://www.reddit.com/r/suckless/comments/qpupu2/slock_doesnt_work_if_compiled_from_git/hk0qz3l/
  #  home.activation = {
  #    alertNoGroup = ''
  #      ${pkgs.getent}/bin/getent group nogroup || echo Please run groupadd nogroup for slock to work !
  #    '';
  #  };

  #  news = {
  #  display = "show";
  #  entries = [
  #      {
  #    gg    time = "2023-09-14T14:04:00+00:00";
  #        message = ''
  #	slock⋅needs⋅group⋅"nogroup"⋅to⋅work,⋅https://www.reddit.com/r/suckless/comments/qpupu2/slock_doesnt_work_if_compiled_from_git/hk0qz3l/
  #
  #	Run the following to test if the system is prepared:
  #	${pkgs.getent}/bin/getent⋅group⋅nogroup⋅||⋅echo⋅Please⋅run⋅groupadd⋅nogroup⋅for⋅slock⋅to⋅work⋅!
  #	'';
  #	}
  #	];
  #	};

  home = {
    enableDebugInfo = false; # Enabled that for https://github.com/NixOS/nixpkgs/issues/271991
    homeDirectory = "/home/dani";
    username = "dani";

    packages = attrValues {
      # with pkgs; [
      inherit (pkgs)
        #my-neovim
        #ranger
        #photoprism
        #alejandra
        shellharden
        shfmt
        #rnix-lsp
        #deadnix
        #statix
        #nixfmt
        #stylua
        #shellcheck
        #yt-dlp
        #micro
        #ranger
        #masterpdfeditor
        abcde
        cups-filters
        #      talon
        #scrcpy
        autorandr
        mons
        maim
        xdotool
        xclip
        keepassxc
        swappy
        arandr
        xterm
        signal-desktop
        #tailscale # and openssh to custom package, i. e. home/programs/ssh
        #my-emacs
        #openssh
        dstask
        # TODO https://wiki.hyprland.org/Nix/Hyprland-on-Home-Manager/ https://wiki.hyprland.org/Nix/Hyprland-on-other-distros/ https://discourse.nixos.org/t/opening-i3-from-home-manager-automatically/4849/8 https://wiki.archlinux.org/title/Display_manager
        pcmanfm
        chafa
        #simple-scan # memory error, potential workaround: https://github.com/NixOS/nixpkgs/issues/149812
        #tint2 # rather use at service definition themselves
        #simple-scan # DONT bc simple-scan requires sane-backends which in turn requires udev rules to be in place for the scanner to be detected, so on non-nixos installations of home-manager this simply cannot work. also a mix of non-nixos host provided sane-backends vs simple-scan will not work, rather using host's simple-scan until https://github.com/NixOS/nixpkgs/issues/271989 gets recognition
        #sane-frontends.out
        # sane-backends only "worked" due to leftover udev files from a non-nixos host provided sane installation I removed without rebooting and so tricked the system into belief it had scanner access via standalone home-manager
        # paths only seem to be there but aren't in use (version 1.0.32 of sane-backends in nixos-22.11)
        # ls $(dirname $(realpath $(which scanimage)))/../etc/udev
        # ls $(dirname $(realpath $(which scanimage)))/../sbin
        #sane-backends # DONT bc simple-scan requires sane-backends which in turn requires udev rules to be in place for the scanner to be detected, so on non-nixos installations oof home-manager this simply cannot work. also a mix of non-nixos host provided sane-backends vs simple-scan will not work
        #ocrfeeder # import pdf dialog crashes, broken on NixOS-WSL as well
        ##pdfsandwich # archlinux rather, gscan2pdf, ocrmypdf
        cuneiform
        normcap
        ##gImageReader # archlinux rather
        gdb
        #libreoffice-qt.out
        libcdio-paranoia
        #mpvScripts.chapterskip
        #mpvScripts.quality-menu
        source-code-pro
        ubuntu_font_family
        #spotify-player
        #gtt
        notepad-next
        ;

      inherit (pkgs.usbutils)
        out
        ;

      inherit (pkgs.xorg)
        libxcvt
        xrandr
        ;

      inherit (pkgs.nixgl)
        nixGLIntel
        ;

      inherit (libreoffice-postscript)
        libreoffice
        ;

      nerdfonts = pkgs.nerdfonts.override { fonts = [ "UbuntuMono" ]; };

      keyboard-de = (
        writeScriptBin "keyboard-de" ''
          #!${runtimeShell}

          setxkbmap -model pc104 -layout de
        ''
      );

      keyboard-en = (
        writeScriptBin "keyboard-en" ''
                  #!${runtimeShell}

          	setxkbmap -model pc104 -layout us -variant altgr-intl
        ''
      );
    };

    sessionPath = [
      #"${config.home.homeDirectory}/projects/sedo/devops-scripts/bin"
    ];

    sessionVariables = {
      # see: https://github.com/NixOS/nixpkgs/issues/38991#issuecomment-400657551
      LOCALE_ARCHIVE_2_11 = "/usr/bin/locale/locale-archive";
      LOCALE_ARCHIVE_2_27 = mkDefault "${pkgs.glibcLocalesUtf8}/lib/locale/locale-archive";
    };
  };

  fonts.fontconfig.enable = true;

  # not started as of release-23.05
  #programs.tint2 = {
  #  enable = true;
  #  extraConfig = ''
  #    # are we enabled ?
  #  '';
  #};

  xdg.enable = true;

  # templates (arch linux) in /etc/xdg/openbox/ (autostart and also rc.xml which is for key shortcuts)
  xdg.configFile = {
    "openbox/rc.xml".source = "${rootPath}/home/openbox/rc.xml";

    "openbox/autostart".text = ''
      ${pkgs.xorg.xrandr}/bin/xrandr --listmonitors

      # FIXME rather store path ? https://search.nixos.org/packages?query=pcmanfm or https://search.nixos.org/packages?query=pcmanfm-qt
      ${pkgs.pcmanfm}/bin/pcmanfm -d &

       ${pkgs.tint2}/bin/tint2 &

      # only archlinux' version of xsecurelock has suid bit set
      # still DONT I'll use the home-manager managed user systemd service here
      #xss-lock -n /usr/lib/xsecurelock/dimmer -l -- xsecurelock &
      systemctl start --user xss-lock
    '';
  };

  # see https://sourcegraph.com/github.com/thiagokokada/nix-configs@e9980c5b31c1aae55c5cb9465fb15137349f7680/-/blob/home-manager/desktop/i3/screen-locker.nix?L24:13
  services.screen-locker = {
    enable = true;
    xautolock.enable = false;
    lockCmd = "xsecurelock";
    xss-lock.extraOptions = [
      "-n /usr/lib/xsecurelock/dimmer"
      "-l"
    ];
  };

}
