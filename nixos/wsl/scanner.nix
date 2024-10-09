{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    optionalAttrs
    optionalString
    ;
  cfg = config.custom.wsl.scanner;
in
{
  # See https://sourcegraph.com/github.com/michalrus/dotfiles/-/blob/machines/_shared_/features/canoscan-lide-20/default.nix?L34:11
  # but also https://discourse.nixos.org/t/whats-the-difference-between-extraargs-and-specialargs-for-lib-eval-config-nix/5281/2

  #imports = [
  #{
  #disabledModules = [ "services/hardware/sane.nix" ];
  #}
  #  # TODO could this be elevated to use unstable home-manager modules in parallel to release-XX as well ?
  #  (args@{ config, lib, pkgs, ... }:
  #    import "${inputs.nixpkgs.outPath}/nixos/modules/services/hardware/sane.nix"
  #      (args // { pkgs = inputs.nixos-2211.legacyPackages.${pkgs.system}; })
  #    # above works, but FIXME does not work (again) in unstable yet
  #    #(args // { pkgs = inputs.unstable.legacyPackages.${pkgs.system}; })
  #  )
  #];

  options.custom.wsl.scanner = {
    enable =
      mkEnableOption "Support the Canon LiDE 30 USB-scanner"
      // optionalAttrs (config.custom.base.general.wsl) { default = true; };
  };

  config = mkIf (cfg.enable) {
    #users.groups.scanner.members = [ "dkahlenberg" ]; # see https://nixos.wiki/wiki/Scanners and https://github.com/nix-community/NixOS-WSL/commit/7f6189c658963fce68ab38fa9200729a6328f280 usbip
    users.users.nixos.extraGroups = [
      "scanner"
      "lp"
    ];

    environment.systemPackages = [
      #pkgs.gscan2pdf
      pkgs.simple-scan
      pkgs.sane-backends.out
    ];

    # https://www.google.com/search?client=firefox-b-d&q=sane-plustek+nixos
    # http://www.sane-project.org/lists/sane-mfgs-cvs.html
    # https://github.com/NixOS/nixpkgs/issues/33579
    hardware.sane = {
      enable = true;
    };

    #environment.etc."sane.d/lide_30.conf".text = "usb 0x04a9 0x220e";
    # see https://www.reddit.com/r/NixOS/comments/ijje39/difficulties_with_scangearmp2_cannon_scanner/
    # and https://sourcegraph.com/search?q=context:global+file:%5E*.nix%24+content:environment.etc.%22sane&patternType=standard&sm=1&groupBy=repo
    # and https://forum.ubuntuusers.de/post/6301022/
    environment.etc."sane.d/dll.d/plustek.conf".text = ''
      # sane-dll entry for canon Lide 30
      [usb] 0x04a9 0x220e
      device auto
    '';

    # See https://sourcegraph.com/github.com/michalrus/dotfiles/-/blob/machines/_shared_/features/canoscan-lide-20/default.nix?L34:11
    services.udev = {
      # TODO Here it is different though (scanner): https://unix.stackexchange.com/questions/184367/scanimage-does-not-find-scanner-unless-sudoed-but-shows-up-with-sane-find-scan
      extraRules = optionalString config.custom.wsl.usbip.enable ''
        ATTR{idVendor}=="04a9", ATTR{idProduct}=="220e", MODE="0664", GROUP="scanner", ENV{libsane_matched}="yes"
      '';
      # TODO Still needed ?
      # ATTR{idVendor}=="04a9", ATTR{idProduct}=="220e", MODE="0666", GROUP="scanner"
      #''
      #  SUBSYSTEM=="usb", MODE="0666"
      #  KERNEL=="hidraw*", SUBSYSTEM=="hidraw", TAG+="uaccess", MODE="0666"
      #'';
    };
  };
}
