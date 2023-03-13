{ config, lib, pkgs, rootPath, ... }:

{
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  custom.base.general.wsl = true;

  services.syncthing.enable = true;

  systemd.tmpfiles.rules = [
    ''
      f /tmp/test/.nixd.json - - - - {"eval":{"depth":10,"target":{"args":["--expr","with import <nixpkgs> { }; callPackage /tmp/test/default.nix { }"],"installable":""}}}
    ''
  ];

}
