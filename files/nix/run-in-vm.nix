{ nixpkgs, rootPath }:
let
  evaluatedConfig = nixpkgs.lib.nixosSystem {
    system = "aarch64-linux";

    modules = [
      # = configuration
      (
        { lib, ... }:
        {
          systemd.network.enable = true;
          systemd.services.sshd.wantedBy = lib.mkForce [ "multi-user.target" ];

        }
      )
    ];
  };
in
# https://github.com/NixOS/nixpkgs/blob/5061fe0c2c7743370e1d379d6fa60eed26ff1470/pkgs/misc/uboot/default.nix#L230
# https://github.com/n8henrie/nixos-btrfs-pi/blob/master/flake.nix#L44
nixpkgs.writeScript "run-nixos-vm" ''
            #!${nixpkgs.runtimeShell}

            img=${evaluatedConfig.config.system.build.sdImage}/aarch64-qemu.img

            # https://wiki.qemu.org/Documentation/Platforms/ARM#Supported_Machines
  	  # https://www.qemu.org/docs/master/system/arm/raspi.html
            qemu-system-aarch64 \
              -M raspi2 \
              -m 1G \
              -smp 4 \
              -drive file="$img",format=raw \
  	    -kernel "${nixpkgs.ubootRaspberryPi2}/u-boot-rpi3.bin" \
              -device usb-net,netdev=net0 \
              -netdev user,id=net0,hostfwd=tcp::2222-:22 \
              -append "console=ttyAMA0 root=/dev/mmcblk0p2 rw rootwait" \
              -nographic
''
