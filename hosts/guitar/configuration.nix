{
  config,
  pkgs,
  lib,
  rootPath,
  inputs,
  ...
}:

{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  custom = {

    base.desktop = {
      enable = true;
      laptop = true;
    };

    programs.nixbuild.enable = true;

    #services.tailscale.enable = true;

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

  services.getty.helpLine = ''
    \e[0;93mReset password now, please !\e[0m

    If not using \e[0;32mnetworking.wireless.networks\e[0m take care of not having a line 
    saying \e[0;31mdisable=1\e[0m in \e[0;32m/etc/wpa_supplicant.conf\e[0m

    Use \e[0;31mnmap -vv -n -p- -sV routeraddress/24 -open\e[0m to find other hosts

    You have two possibilities building the system flake.
    First, \e[0;32mnix build .#nixosConfigurations.guitar.config.system.build.toplevel -L --keep-going -vvv --show-trace --json\e[0m
    and then \e[0;32msudo ./result/activate\e[0m and \e[0;32msudo ./result/bin/switch-to-configuration switch\e[0m
    Second, \e[0;32mnixos-rebuild switch --use-remote-sudo --max-jobs 0 --flake .#guitar\e[0m
    You may also look inside ./files/apps/setup.sh to see.

    Copy to ~/.ssh/my-nixbuild-key the my-nixbuild-key (chmod 0600) to have eu.nixbuild.net access

    Issue \e[0;32mcat /etc/issue\e[0m to show these messages again
  '';

  nix.settings.auto-optimise-store = true;

  services.xserver.xkb = {
    layout = lib.mkForce "de";
    variant = lib.mkForce "";
  };

  system.stateVersion = lib.mkForce "25.05"; # Did you read the comment?

  # to have i3 use qutebrowser as default browser
  # manually add `bindsym $mod+b exec $BROWSER` to ~/.config/i3/config as well
  environment.sessionVariables.BROWSER = "${lib.getExe pkgs.qutebrowser}";
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

  sops.validateSopsFiles = false;
  # You can avoid adding to store by adding a string to the full path instead, i.e.
  sops.defaultSopsFile = "/home/dani/.sops/secrets/secrets.yaml";
  # This will automatically import SSH keys as age keys
  #sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
  # This is using an age key that is expected to already be in the filesystem
  sops.age.keyFile = "/home/dani/.config/sops/age/keys.txt";
  # This will generate a new key if the key specified above does not exist
  #sops.age.generateKey = true;
  # This is the actual specification of the secrets.
  sops.secrets = {
    "hetzner/console/id" = { };
    "hetzner/console/password" = { };
    "hetzner/vm/password" = { };
    "nixbuild/secret_env" = {
      owner = config.users.users."root".name;
      mode = "0600";
    };
    "nixbuild/my_nixbuild_key" = {
      owner = config.users.users."root".name;
      mode = "0600";
      # makes a symlink to the secret itself
      #path = "/root/.ssh/id_ed25519";
    };
    "nixbuild/my_nixbuild_shell_key" = {
      # TODO needs the specific owner for now hardcoded but should rather
      #  home.username or such, i.e., via config
      owner = config.users.users."dani".name;
      mode = "0600";
      # makes a symlink to the secret itself
      #path = "/home/nixos/.ssh/id_ed25519";
    };
  };
}
