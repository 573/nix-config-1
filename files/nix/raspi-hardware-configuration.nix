# source: https://github.com/n8henrie/nixos-btrfs-pi/blob/856722b/nixos/hardware-configuration.nix
# see https://github.com/NixOS/nixpkgs/blob/master/pkgs/misc/uboot/default.nix as well
{
  lib,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    # console=ttyAMA0 seems necessary for kernel boot messages in qemu
    kernelParams = [
      "console=ttyS0,115200"
      "console=ttyAMA0,115200"
      "console=tty0"
      "root=/dev/disk/by-label/NIXOS_SD"
      "rootwait"
    ];
    loader = {
      grub.enable = false;
      generic-extlinux-compatible = {
        enable = true;
        configurationLimit = 20;
      };
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/12121234-1212-1234-1212-121212341234";
      fsType = "ext4";
    };

    "/nix/store" = {
      device = "/nix/store";
      fsType = "none";
      options = [ "bind" ];
    };

    "/boot/firmware" = {
      device = "/dev/disk/by-label/FIRMWARE";
      fsType = "vfat";
      options = ["nofail" "noauto"];
    };
  };

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eth0.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlan0.useDHCP = lib.mkDefault true;

  powerManagement.cpuFreqGovernor =
    lib.mkDefault
    "ondemand";
}

