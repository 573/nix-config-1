{ config, pkgs, ... }:

{
  imports = [
    ./lib/interface.nix
  ];

  custom = {
    applications.snippie.enable = true;

    server = {
      enable = true;
      rootLogin = true;
    };
  };

  networking.hostName = "krypton";
}
