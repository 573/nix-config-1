{ config, lib, pkgs, inputs, ... }:

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

  config = mkIf cfg.enable {
    # use root's .ssh here as nix-daemon runs with root permissions
    programs.ssh.extraConfig = ''
      Host eu.nixbuild.net
        PubkeyAcceptedKeyTypes ssh-ed25519
        ServerAliveInterval 60
        IPQoS throughput
        IdentityFile /root/.ssh/my-nixbuild-key
    '';

    programs.ssh.knownHosts = {
      nixbuild = {
        hostNames = [ "eu.nixbuild.net" ];
        publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
      };
    };

    nix = {
      distributedBuilds = true;
      buildMachines = [
        {
          hostName = "eu.nixbuild.net";
          system = "aarch64-linux";
          maxJobs = 100;
          supportedFeatures = [ "benchmark" "big-parallel" ];
        }
      ];
    };
  };
}
