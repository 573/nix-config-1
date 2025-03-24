{ config, lib, pkgs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.nixbuild;
in

{

  ###### interface

  options = {

    custom.programs.nixbuild.enable = mkEnableOption "nixbuild";

  };

  ###### implementation

  config = let
      nixosUser = pkgs.coqPackages.lib.switch-if [
        {cond = config.custom.base.general.wsl; out = "nixos"; }
      ] "dani";  
      homedir = config.home-manager.users."${nixosUser}".home.homeDirectory;
  in mkIf cfg.enable {
    # use root's .ssh here as nix-daemon runs with root permissions
    programs.ssh.extraConfig = ''
    Host nixbuild
        HostName eu.nixbuild.net
        User root
        PubKeyAcceptedKeyTypes ssh-ed25519
        ServerAliveInterval 60
        IPQoS throughput
        IdentitiesOnly yes
        IdentityFile ${homedir}/.ssh/my-nixbuild-key
    '';

#    programs.ssh.knownHosts = {
#      nixbuild = {
#        hostNames = [ "eu.nixbuild.net" ];
#        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
#      };
#    };

    nix = {
      distributedBuilds = true;
      settings = {
	      trusted-users = ["${nixosUser}"];
	      builders-use-substitutes = true;
      };
      buildMachines = [
        {
          hostName = "eu.nixbuild.net";
          systems = [ "aarch64-linux" "armv7l-linux" ];
          maxJobs = 100;
          supportedFeatures = [
            "benchmark"
            "big-parallel"
          ];
	  sshUser = "root";
	  sshKey = "${homedir}/.ssh/my-nixbuild-key";
	  publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBJUUNaYzU0cG9KOHZxYXdkOFRyYU5yeVFlSm52SDFlTHBJRGdiaXF5bU0K";
	  speedFactor = 2;
	}
      ];
    };
  };
}
