{ config
, lib
, pkgs
, ...
}:
with lib; let
  /* https://github.com/NixOS/nixpkgs/issues/191128#issuecomment-1514224101
    nix hash to-sri --type sha256 $(nix-prefetch-url https://raw.githubusercontent.com/dorssel/usbipd-win/v3.2.0
    /Usbipd/wsl-scripts/auto-attach.sh)
  */
  #usbipd-win-auto-attach = pkgs.fetchurl {
  #  url = "https://raw.githubusercontent.com/dorssel/usbipd-win/v3.2.0/Usbipd/wsl-scripts/auto-attach.sh";
  #  hash = "sha256-KJ0tEuY+hDJbBQtJj8nSNk17FHqdpDWTpy9/DLqUFaM=";
  #};

  cfg = config.custom.wsl.usbip;
  # Source: https://lgug2z.com/articles/yubikey-passthrough-on-wsl2-with-full-fido2-support/
in
{
  options.custom.wsl.usbip = with types; {
    enable = mkEnableOption "Customisation of USB/IP integration to support Scanner and Yubikey";
  };

  # TODO Plan, enable these customisations when upstream is enabled, as in https://github.com/nix-community/NixOS-WSL/pull/203
  config = mkIf (config.wsl.enable && config.wsl.usbip.enable && cfg.enable) {

    #users.groups.scanner.members = [ "dkahlenberg" ]; # see https://nixos.wiki/wiki/Scanners and https://github.com/nix-community/NixOS-WSL/commit/7f6189c658963fce68ab38fa9200729a6328f280 usbip
    users.users.nixos.extraGroups = [ "scanner" "lp" ];

    environment.systemPackages = [
      #pkgs.gscan2pdf
      pkgs.simple-scan
      pkgs.sane-backends.out
      pkgs.usbutils.out
      pkgs.yubikey-manager
      pkgs.libfido2
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

    # See https://sourcegraph.com/github.com/michalrus/dotfiles/-/blob/machines/_shared_/features/canoscan-lide-20/default.nix?L34:11 and nixos/base/general.nix

    services.pcscd.enable = true;

    services.udev = {
      enable = true;
      packages = [ pkgs.yubikey-personalization ];
      # TODO Here it is different though (scanner): https://unix.stackexchange.com/questions/184367/scanimage-does-not-find-scanner-unless-sudoed-but-shows-up-with-sane-find-scan
      extraRules = optionalString config.custom.wsl.usbip.enable ''
                SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0010|0110|0111|0114|0116|0401|0403|0405|0407|0410", MODE="0666"
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
