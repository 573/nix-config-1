{ config, pkgs, ... }:

{
  imports = [ ./modules ];

  custom = {
    applications.golden-river-jazztett.enable = true;

    boot.mode = "grub";

    server = {
      enable = true;
      ipv6Address = "2a01:4f8:1c0c:7168::2";
    };
  };

  networking.hostName = "neon";
}
