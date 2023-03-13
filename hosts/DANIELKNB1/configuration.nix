{ config, lib, pkgs, rootPath, ... }:

{
  # FIXME currently disabled due to Windows-Update 21.11.23
  # https://mynixos.com/nixpkgs/option/boot.binfmt.emulatedSystems
  boot.binfmt.emulatedSystems = /* [ "aarch64-linux"]; */ [ "armv7l-linux" ];

  custom = {
    base.general.wsl = true;
    programs.docker.enable = true;
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
