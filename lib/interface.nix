{ config, pkgs, ... }:

{
  imports = [
    ../hardware-configuration.nix
    ./boot.nix
    ./desktop.nix
    ./dev.nix
    ./general.nix
    ./xserver.nix
  ];
}
