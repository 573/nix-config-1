{ pkgs, config, lib, inputs, rootPath, modulesPath, /* image, */ ... }:
# https://github.com/Gerschtli/nix-config/tree/master/hosts/xenon
{
  
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4
    # qemu-vm.nix is automatically included when config.system.build.vm and herein virtualisation.vmVariant...
    #(modulesPath + "/virtualisation/qemu-vm.nix")
    (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ] # FIXME https://discourse.nixos.org/t/infinite-recursion-with-lib-lists-optionals/49325/2
  #++ lib.optional (lib.debug.traceIf image "set" image) (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
  ;

  custom = {
    # TODO https://github.com/Gerschtli/nix-config/blob/master/nixos/misc/agenix.nix
    #agenix.secrets = [ "wireless-config" ];

  #  base.server.enable = true;

    system.boot.mode = "raspberry";

    # https://blog.yaymukund.com/posts/nixos-raspberry-pi-nixbuild-headless
    ###programs.nixbuild.enable = true;

    ###services.tailscale.enable = true;
  };

  # modules/users.nix - https://blog.yaymukund.com/posts/nixos-raspberry-pi-nixbuild-headless/
  users.users.dani = {
    isNormalUser = true;
    home = "/home/dani";
    extraGroups = [
      "wheel"
      "networkmanager"
      "audio"
      "video"
    ];
    password = "test";
  };

  security.sudo.execWheelOnly = true;

  # don't require password for sudo
  security.sudo.extraRules = [{
    users = [ "dani" ];
    commands = [{
      command = "ALL";
      options = [ "NOPASSWD" ];
    }];
  }];

  # modules/networking.nix
  # Setup wifi
  ###networking = {
    # https://github.com/NixOS/nixpkgs/blob/44a69ed688786e98a101f02b712c313f1ade37ab/nixos/modules/tasks/network-interfaces.nix#L1538C1-L1538C375
    #         The combination of `systemd.network.enable = true`, `networking.useDHCP = true` and `networking.useNetworkd = false` can cause both networkd and dhcpcd to manage the same interfaces. This can lead to loss of networking. It is recommended you choose only one of networkd (by also enabling `networking.useNetworkd`) or scripting (by disabling `systemd.network.enable`)
    ###useNetworkd = true; # v2
    ###hostName = config.custom.base.general.hostname;
    #useDHCP = false;
    #interfaces.wlan0.useDHCP = true;
    ###wireless = {
    ###  enable = true;
    ###  allowAuxiliaryImperativeNetworks = true;
    ###  userControlled.enable = true;
    ###};
  ###};

  # And expose via SSH
  ###programs.ssh.startAgent = true;
  ###services.openssh = {
  ###  enable = true;
  ###  settings = {
  ###    PasswordAuthentication = false;
  ###    KbdInteractiveAuthentication = false;
  ###  };
  ###};

  users.users."dani".openssh.authorizedKeys.keyFiles = [
    "${rootPath}/files/keys/id_ed25519.daniel.pub"
    "${rootPath}/files/keys/id_ed25519.daniel.nixondroid.pub"
  ];

  # modules/builder.nix
  # Not strictly necessary, but nice to have.
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%"; # Depends on the size of your storage.

  # DONT comes already via https://github.com/NixOS/nixpkgs/blob/8fcc33af06ae8164c8f1d211d9ca6729379886a8/nixos/modules/profiles/qemu-guest.nix#L9
  boot.initrd.kernelModules = [
    "virtio-pci"
    "virtio-blk"
    "pci-host-generic"
  ];

  # Reduces writes to hardware memory, which increases the lifespan
  # of an SSD.
  ###zramSwap.enable = true;
  ###zramSwap.memoryPercent = 150;

  # Needed for rebuilding on the Pi. You might not need this with more
  #memory, but my Pi only has 1GB.
  swapDevices = [{
    device = "/swapfile";
    size = 2048;
  }];

 # https://fzakaria.com/2024/08/13/nixos-raspberry-pi-me, when in qemu got:
 #  /dev/disk/by-label/NIXOS_SD: Can't lookup blockdev
 fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/NIXOS_SD";
      fsType = "ext4";
      options = ["noatime"];
    };
  };

  # https://github.com/NixOS/nixpkgs/commit/49c4a6d6021a29e862383bf678d34fba7def9a83
  # https://gist.github.com/JBlond/2fea43a3049b38287e5e9cefc87b2124
  services.getty.helpLine = ''
  \e[0;93mReset password now, please !\e[0m

  If not using \e[0;32mnetworking.wireless.networks\e[0m take care of not having a line 
  saying \e[0;31mdisable=1\e[0m in \e[0;32m/etc/wpa_supplicant.conf\e[0m

  Use \e[0;31mnmap -vv -n -p- -sV routeraddress/24 -open\e[0m to find other hosts

  You have two possibilities building the system flake.
  First, \e[0;32mnix build .#nixosConfigurations.twopi.config.system.build.toplevel -L --keep-going -vvv --show-trace --json\e[0m
  and then \e[0;32msudo ./result/activate\e[0m and \e[0;32msudo ./result/bin/switch-to-configuration switch\e[0m
  Second, \e[0;32mnixos-rebuild switch --use-remote-sudo --max-jobs 0 --flake .#twopi\e[0m

  Issue \e[0;32mcat /etc/issue\e[0m to show these messages again
  '';

  console = {
    useXkbConfig = true;
    packages = [pkgs.terminus_font];
  };

  # TODO Figure out how to umlauts with us-acentos only, then this and console.useXkbConfig can go
  services.xserver = {
    enable = false;
    xkb.layout = "us";
    xkb.variant = "intl";
  };

    # TODO https://sourcegraph.com/github.com/AtaraxiaSjel/nixos-config/-/blob/machines/Home-Hypervisor/networking.nix?L67 replaces https://search.nixos.org/options?show=networking.interfaces
    systemd.network.wait-online.timeout = 0;
    systemd.network.networks = {
      # https://github.com/NixOS/nixpkgs/blob/e0754b43a307c04a572d03cd797c946da3bd9b34/nixos/modules/tasks/network-interfaces-systemd.nix#L57
      "10-ethernet-twopi-dhcp" = {
        # Whether to manage network configuration using systemd-network. This also enables systemd.networkd.enable.
        enable = true;

        # https://github.com/NixOS/nixpkgs/blob/7ffe0edc685f14b8c635e3d6591b0bbb97365e6c/nixos/modules/system/boot/networkd.nix#L1623
        matchConfig.Name = "eth0";

	# https://github.com/NixOS/nixpkgs/blob/7ffe0edc685f14b8c635e3d6591b0bbb97365e6c/nixos/modules/system/boot/networkd.nix#L2010
	dhcpV4Config.RouteMetric = 20;

	networkConfig.DHCP = "yes";

        # no or routable, i. e. https://gitea.tlater.net/tlaternet/tlaternet-server/src/branch/master/configuration/services/wireguard.nix#L70 https://search.nixos.org/options?show=systemd.network.wait-online.anyInterface&from=0&size=50&sort=relevance&type=packages&query=online https://discourse.nixos.org/t/systemd-networkd-wait-online-934764-timeout-occurred-while-waiting-for-network-connectivity/33656/9
	linkConfig.RequiredForOnline = "no";

	ipv6AcceptRAConfig.RouteMetric = 20;
      };

      # TODO https://wiki.archlinux.org/title/Systemd-networkd#Bonding_a_wired_and_wireless_interface
/*      "10-wireless-twopi-dhcp" = {
        # Whether to manage network configuration using systemd-network. This also enables systemd.networkd.enable.
        enable = true;

        # uncomment next five for defaults acc. to arch wiki
	#matchConfig = {
	#  Name = "wl*\|wlan*";
	#};
	#dhcpV4Config.RouteMetric = 600;
	#networkConfig.DHCP = "yes";
	#linkConfig.RequiredForOnline = "routable";
	#ipv6AcceptRAConfig.RouteMetric = 600;

	# had it working with these and eth0 unmanaged
        matchConfig.Name = "wl*";
	dhcpV4Config.RouteMetric = 20;
	networkConfig = {
	  DHCP = "ipv4";
	  LinkLocalAddressing = "no";
	  IgnoreCarrierLoss = "3s";
        };
	# the default true for networking.useDHCP implies linkConfig.RequiredForOnline = "routable" systemd.network.wait-online.anyInterface etc.
      };
      */
    };

    sdImage.compressImage = false;

    environment.systemPackages = builtins.attrValues {
      # https://linuxconfig.org/how-to-check-wi-fi-adapter-and-driver-on-raspberry-pi
      inherit (pkgs)
        wpa_supplicant # probably only when not  networking.wireless.enable = true; 
	pciutils
	usbutils
	wirelesstools
	#hardinfo
	ethtool
	lshw
	nmap
	;
	

    check_netdevices = pkgs.writeShellApplication {
      name = "check_netdevices";
      runtimeInputs = [pkgs.pciutils];
      text = ''
        lspci -knn|grep -iA2 net
      '';
    };

    };

  # for the settings before with flake's raspi2qemu see commit 38089f9

  # implicit https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/qemu-vm.nix
  virtualisation.vmVariant = {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
    ];
    disabledModules = [
      inputs.nixos-hardware.nixosModules.raspberry-pi-4
    ];

    # See https://discourse.nixos.org/t/looking-for-help-around-tightening-the-feedback-loop/67109/3
    # cheapo password for vm
    users.users.YourUser.initialPassword = "bla";
    # auto login in the vm console
    services.getty.autologinUser = "YourUser";
    # no sudo password needed
    security.sudo.wheelNeedsPassword = false;

    # FIXME virtualisation.useBootLoader wants kvm featured builder, see https://github.com/hsjobeki/nixpkgs/blob/e26ffd35e767023d0229546d97fb796380e63ec2/pkgs/build-support/vm/default.nix#L383 (found via https://noogle.dev/f/pkgs/vmTools/runInLinuxVM#implementation), possible that this also has effect: https://github.com/NixOS/nixpkgs/blob/26d499fc9f1d567283d5d56fcf367edd815dba1d/nixos/modules/virtualisation/qemu-vm.nix#L1241
    virtualisation = {
      # https://github.com/MarcoPolo/simple-vms/blob/81ea3fc/README.md#example
      memorySize = 1024;
      graphics = false;
      # DONT expects file bios.bin, we want u-boot.bin, https://github.com/NixOS/nixpkgs/blob/c78ecbe3f39b4988816366c1632f77de19d623cb/nixos/modules/virtualisation/qemu-vm.nix#L1058
      #bios = inputs.nixpkgs.legacyPackages.x86_64-linux.pkgsCross.aarch64-multiplatform.ubootQemuAarch64;
      #useBootLoader = true;
      qemu.virtioKeyboard = false;
      # see also srcs but https://search.nixos.org/options?channel=24.11&show=virtualisation.qemu.drives&from=100&size=50&sort=relevance&type=packages&query=virtualisation.+machine
      # still unsure, might be that as well https://github.com/NixOS/nixpkgs/blob/26d499fc9f1d567283d5d56fcf367edd815dba1d/nixos/modules/virtualisation/qemu-vm.nix#L306
      # DONT has different semantics, one could use a derivation here though
      #diskImage = "${inputs.self.nixosConfigurations.twopi.config.system.build.sdImage}/sd-image/${inputs.self.nixosConfigurations.twopi.options.sdImage.imageName.value}";
      # as in https://discourse.nixos.org/t/how-to-ssh-to-qemu-emulated-aarch64-nixos/20081/27 
      # in case doesn't work overlay vmTools set as in https://discourse.nixos.org/t/override-qemu-options-in-runinlinuxvm/16470/2 either
      # vmRunCommand https://github.com/Ma27/nixpkgs/blob/97ed6b4565e76286062e6942517a71ae4c9cac72/pkgs/build-support/vm/default.nix#L242
      # or qemuCommandLinux https://github.com/Ma27/nixpkgs/blob/97ed6b4565e76286062e6942517a71ae4c9cac72/pkgs/build-support/vm/default.nix#L227
      /*diskImage = (pkgs.stdenv.mkDerivation {
        name = "aarch64-qemu.img";
	dontUnpack = true;
	installPhase = ''
	  img=./raspi-in-qemu.img
	  cp ${inputs.self.nixosConfigurations.twopi.config.system.build.sdImage}/sd-image/${inputs.self.nixosConfigurations.twopi.options.sdImage.imageName.value} "$img"
	  chmod 0640 "$img"
	  ${inputs.nixpkgs.legacyPackages.x86_64-linux.qemu}/bin/qemu-img resize -f raw "$img" 4G
          cp "$img" $out
	'';
      }).outPath + "/aarch64-qemu.img";*/
      # TODO -machine / -cpu https://github.com/NixOS/nixpkgs/blob/26d499fc9f1d567283d5d56fcf367edd815dba1d/nixos/lib/qemu-common.nix#L37
      # see https://github.com/NixOS/nixpkgs/blob/26d499fc9f1d567283d5d56fcf367edd815dba1d/nixos/modules/virtualisation/qemu-vm.nix#L269
      # as well as https://github.com/NixOS/nixpkgs/blob/26d499fc9f1d567283d5d56fcf367edd815dba1d/nixos/lib/make-disk-image.nix#L614
      # build: $ nix build --builders "ssh://eu.nixbuild.net aarch64-linux,x86_64-linux - 100 1 big-parallel,benchmark" --max-jobs 0 .#nixosConfigurations.twopi.config.system.build.vm -L -vvv --show-trace
    };
    virtualisation.host.pkgs = inputs.nixpkgs.legacyPackages.x86_64-linux;
    virtualisation.qemu.options = [
  "-machine virt -cpu cortex-a57 -bios ${inputs.nixpkgs.legacyPackages.x86_64-linux.pkgsCross.aarch64-multiplatform.ubootQemuAarch64}/u-boot.bin"
    ];


  nixpkgs.overlays = [
    (final: prev: {
      # https://discourse.nixos.org/t/override-qemu-options-in-runinlinuxvm/16470/2
      # import https://github.com/NixOS/nixpkgs/blob/master/pkgs/build-support/vm/default.nix
      # vmTools = prev.makeOverridable (import ./vmTools_patched.nix) { pkgs = final.pkgs; lib = final.lib; };
    })
  ];
  };
}
