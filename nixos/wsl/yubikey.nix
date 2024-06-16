{ config
, lib
, pkgs
, ...
}:
let
  inherit
    (lib)
    mkIf
    mkEnableOption
    optionalAttrs
    optionalString
    ;
  cfg = config.custom.wsl.yubikey;
in
{
  options.custom.wsl.yubikey = {
    enable = mkEnableOption "i" // optionalAttrs (config.custom.base.general.wsl) { default = true; };
  };

  config = mkIf (cfg.enable) {
    environment.systemPackages = [
      pkgs.yubikey-manager
      pkgs.libfido2
    ];

    services.pcscd.enable = true;

    services.udev = {
      packages = [ pkgs.yubikey-personalization ];
      extraRules = optionalString config.custom.wsl.usbip.enable ''
        SUBSYSTEM=="usb", ATTRS{idVendor}=="1050", ATTRS{idProduct}=="0010|0110|0111|0114|0116|0401|0403|0405|0407|0410", MODE="0666"
      '';
    };
  };
}
