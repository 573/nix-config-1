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
  
  boot.loader.grub.useOSProber = true;

  boot.initrd.luks.devices."luks-7c125b64-c9f3-43dd-818e-1d5e9453b934".device = "/dev/disk/by-uuid/7c125b64-c9f3-43dd-818e-1d5e9453b934";
  # Setup keyfile
  boot.initrd.secrets = {
    "/boot/crypto_keyfile.bin" = null;
  };

  boot.loader.grub.enableCryptodisk = true;

  boot.initrd.luks.devices."luks-35babb35-1c2d-49df-bf46-6c9efd7d44b6".keyFile = "/boot/crypto_keyfile.bin";
  boot.initrd.luks.devices."luks-7c125b64-c9f3-43dd-818e-1d5e9453b934".keyFile = "/boot/crypto_keyfile.bin";

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
