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
    programs.nixbuild.enable = true;
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
  networking = {
    # https://github.com/NixOS/nixpkgs/blob/44a69ed688786e98a101f02b712c313f1ade37ab/nixos/modules/tasks/network-interfaces.nix#L1538C1-L1538C375
    #         The combination of `systemd.network.enable = true`, `networking.useDHCP = true` and `networking.useNetworkd = false` can cause both networkd and dhcpcd to manage the same interfaces. This can lead to loss of networking. It is recommended you choose only one of networkd (by also enabling `networking.useNetworkd`) or scripting (by disabling `systemd.network.enable`)
    useNetworkd = true; # v2
    hostName = config.custom.base.general.hostname;
    #useDHCP = false;
    #interfaces.wlan0.useDHCP = true;
    wireless = {
      enable = true;
      allowAuxiliaryImperativeNetworks = true;
      userControlled.enable = true;
    };
  };

  # And expose via SSH
  programs.ssh.startAgent = true;
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users."dani".openssh.authorizedKeys.keyFiles = [
    "${rootPath}/files/keys/id_ed25519.daniel.pub"
    "${rootPath}/files/keys/id_ed25519.daniel.nixondroid.pub"
  ];

  # modules/builder.nix
  # Not strictly necessary, but nice to have.
  boot.tmp.useTmpfs = true;
  boot.tmp.tmpfsSize = "50%"; # Depends on the size of your storage.

  # Reduces writes to hardware memory, which increases the lifespan
  # of an SSD.
  zramSwap.enable = true;
  zramSwap.memoryPercent = 150;

  # Needed for rebuilding on the Pi. You might not need this with more
  #memory, but my Pi only has 1GB.
  swapDevices = [{
    device = "/swapfile";
    size = 2048;
  }];

  # https://gist.github.com/JBlond/2fea43a3049b38287e5e9cefc87b2124
  services.getty.helpLine = "\\e[0;31mReset password now\\e[0m";

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
    systemd.network.networks = {
      wired = {
        # Whether to manage network configuration using systemd-network. This also enables systemd.networkd.enable.
        enable = true;

        # https://github.com/NixOS/nixpkgs/blob/7ffe0edc685f14b8c635e3d6591b0bbb97365e6c/nixos/modules/system/boot/networkd.nix#L1623
        matchConfig.Name = "eth0";

	# https://github.com/NixOS/nixpkgs/blob/7ffe0edc685f14b8c635e3d6591b0bbb97365e6c/nixos/modules/system/boot/networkd.nix#L2010
	dhcpV4Config.RouteMetric = 600;

	networkConfig.DHCP = "yes";

	linkConfig.RequiredForOnline = "routable";

	ipv6AcceptRAConfig.RouteMetric = 600;
      };

      wireless = {
        # Whether to manage network configuration using systemd-network. This also enables systemd.networkd.enable.
        enable = true;

	matchConfig.Name = "wlan0";

	dhcpV4Config.RouteMetric = 600;

	networkConfig.DHCP = "yes";

	linkConfig.RequiredForOnline = "routable";

	ipv6AcceptRAConfig.RouteMetric = 600;
      };
    };

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
	;
	

    check_netdevices = pkgs.writeShellApplication {
      name = "check_netdevices";
      runtimeInputs = [pkgs.pciutils];
      text = ''
        lspci -knn|grep -iA2 net
      '';
    };

    };

  virtualisation.vmVariant = {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
      (modulesPath + "/installer/sd-card/sd-image.nix")
    ];
    disabledModules = [
      inputs.nixos-hardware.nixosModules.raspberry-pi-4
      (modulesPath + "/installer/sd-card/sd-image-aarch64.nix")
    ];
    services.spice-vdagentd.enable = true;
    virtualisation.qemu.options = [
      "-vga qxl -device virtio-serial-pci -spice port=5930,disable-ticketing=on -device virtserialport,chardev=spicechannel0,name=com.redhat.spice.0 -chardev spicevmc,id=spicechannel0,name=vdagent"
    ];
  };
}
