{ config, lib, pkgs, rootPath, ... }:

{
  # FIXME currently disabled due to Windows-Update 21.11.23
  # https://mynixos.com/nixpkgs/option/boot.binfmt.emulatedSystems
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ]; /* [ "armv7l-linux" ]; */ # list type misleading here as either or is only possible

  custom = {
    base.general.wsl = true;
    programs.docker.enable = true;
    # DONT the nixos-2211 hack might cause build problems finally, WIP investigating https://github.com/573/nix-config-1/actions/runs/10269489465/job/28415058034
    wsl = {
      scanner.enable = false;
      usbip.enable = false;
      yubikey.enable = false;
    };
    #wsl.usbip.autoAttach = [ "1-2" ];
    system.nvidia.enable = false;
  };

  systemd.tmpfiles.rules = [
    ''
      f /tmp/test/.nixd.json - - - - {"eval":{"depth":10,"target":{"args":["--expr","with import <nixpkgs> { }; callPackage /tmp/test/default.nix { }"],"installable":""}}}
    ''
  ];

  # if resources are accessible only with gid 1000so be it have it here (ubuntu)
  # https://github.com/NixOS/nixpkgs/blob/nixos-23.11/nixos/modules/config/users-groups.nix#L662
  users.groups = {
    nixos.gid = lib.mkForce config.custom.ids.gids.nixos;
  };
  users.users.nixos = {
    uid = lib.mkForce config.custom.ids.uids.nixos;
    extraGroups = [ "nixos" "users" ];
    #isSystemUser = lib.mkForce true;
  };
}
