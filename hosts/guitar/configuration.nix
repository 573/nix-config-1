{ config, pkgs, lib, rootPath, ... }:

{
  custom = {

    base.desktop = {
      enable = true;
      laptop = true;
    };

    programs.nixbuild.enable = true;

    services.tailscale.enable = true;

    services.openssh.enable = true;

    system.boot = {
      mode = lib.mkForce "grub";
      device = "/dev/sda";
    };
  };

  systemd.tmpfiles.rules = [
    ''
      f /tmp/test/.nixd.json - - - - {"eval":{"depth":10,"target":{"args":["--expr","with import <nixpkgs> { }; callPackage /tmp/test/default.nix { }"],"installable":""}}}
    ''
  ];

  services.getty.helpLine = ''
  \e[0;93mReset password now, please !\e[0m

  If not using \e[0;32mnetworking.wireless.networks\e[0m take care of not having a line 
  saying \e[0;31mdisable=1\e[0m in \e[0;32m/etc/wpa_supplicant.conf\e[0m

  Use \e[0;31mnmap -vv -n -p- -sV routeraddress/24 -open\e[0m to find other hosts

  You have two possibilities building the system flake.
  First, \e[0;32mnix build .#nixosConfigurations.guitar.config.system.build.toplevel -L --keep-going -vvv --show-trace --json\e[0m
  and then \e[0;32msudo ./result/activate\e[0m and \e[0;32msudo ./result/bin/switch-to-configuration switch\e[0m
  Second, \e[0;32mnixos-rebuild switch --use-remote-sudo --max-jobs 0 --flake .#guitar\e[0m
  You may also look inside ./files/apps/setup.sh to see.

  Copy to ~/.ssh/my-nixbuild-key the my-nixbuild-key (chmod 0600) to have eu.nixbuild.net access

  Issue \e[0;32mcat /etc/issue\e[0m to show these messages again
  '';

environment = {
    systemPackages = with pkgs; [
      drawing
      font-manager
      gimp-with-plugins
      inkscape-with-extensions
      libqalculate
      orca
      pavucontrol
      qalculate-gtk
      wmctrl
      xclip
      xcolor
      xdo
      xdotool
      xfce.catfish
      xfce.gigolo
      xfce.orage
      xfce.xfburn
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

  system.stateVersion = lib.mkForce "25.05"; # Did you read the comment?


  /*
    error:
       Failed assertions:
       - Your system configures nixpkgs with an externally created instance.
       `nixpkgs.config` options should be passed when creating the instance instead.

       Current value:
       {
         allowUnfree = true;
       }
  */
  # Allow unfree packages
  #nixpkgs.config.allowUnfree = true;
}
