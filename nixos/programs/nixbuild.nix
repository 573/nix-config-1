{
  config,
  lib,
  pkgs,
  ...
}:

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

  config =
    let
      nixosUser = pkgs.coqPackages.lib.switch-if [
        {
          cond = config.custom.base.general.wsl;
          out = "nixos";
        }
      ] "dani";
      homedir = config.home-manager.users."${nixosUser}".home.homeDirectory;
    in
    mkIf cfg.enable {
      # use root's .ssh here as nix-daemon runs with root permissions
      # The Include does add a line SetEnv SIGNING_KEY within Host block
      # Files included or referred to here need 0600 umask
      programs.ssh.extraConfig = ''
            Host nixbuild
                HostName eu.nixbuild.net
                User root
                PubKeyAcceptedKeyTypes ssh-ed25519
                ServerAliveInterval 60
                IPQoS throughput
                IdentitiesOnly yes
                IdentityFile ${config.sops.secrets."nixbuild/my_nixbuild_key".path}
                LogLevel Debug1
                Include ${config.sops.secrets."ssh/secret_env".path}
        	# see "I received a warning from ssh that directed me to this page. What should I do?"
        	# in https://www.openssh.org/pq.html
                IgnoreUnknown WarnWeakCrypto
                WarnWeakCrypto no-pq-kex
      '';

      programs.ssh.knownHosts = {
        nixbuild = {
          extraHostNames = [
            "eu.nixbuild.net"
            "88.99.66.151"
          ];
          publicKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBJUUNaYzU0cG9KOHZxYXdkOFRyYU5yeVFlSm52SDFlTHBJRGdiaXF5bU0K";
        };
      };

      nix = {
        distributedBuilds = true;
        settings = {
          trusted-users = [ "${nixosUser}" ];
          builders-use-substitutes = true;
        };
        buildMachines = [
          {
            # TODO see man nix.conf (/machines), can use ssh match block's host here instead full hostname,
            # but tests on NixOS-WSL needed
            hostName = "eu.nixbuild.net";
            systems = [
              "x86_64-linux"
              "aarch64-linux"
              "armv7l-linux"
            ];
            maxJobs = 100;
            supportedFeatures = [
              "benchmark"
              "big-parallel"
            ];
            sshUser = "root";
            sshKey = config.sops.secrets."nixbuild/my_nixbuild_key".path;
            publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBJUUNaYzU0cG9KOHZxYXdkOFRyYU5yeVFlSm52SDFlTHBJRGdiaXF5bU0K";
            speedFactor = 2;
          }
        ];
      };
    };
}
