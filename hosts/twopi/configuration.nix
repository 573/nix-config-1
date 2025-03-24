{ pkgs, config, lib, inputs, rootPath, modulesPath, /* image, */ ... }:
# https://github.com/Gerschtli/nix-config/tree/master/hosts/xenon
{
  
  imports = [
    inputs.nixos-hardware.nixosModules.raspberry-pi-4 
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
    # FIXME custom.base.general.hostName
    hostName = config.custom.base.general.hostname;
    #wireless.enable = true;
    useDHCP = false;
    #interfaces.wlan0.useDHCP = true;
    #wireless.networks = {
    #  my_ssid.pskRaw = "...";
    #};
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
}
