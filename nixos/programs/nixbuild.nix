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
      programs.ssh = {
        extraConfig =
          lib.concatStringsSep "\n    " [
            "Host nixbuild"
            "HostName eu.nixbuild.net"
            "User root"
            "PubKeyAcceptedKeyTypes ssh-ed25519"
            "ServerAliveInterval 60"
            "IPQoS throughput"
            "IdentitiesOnly yes"
            "LogLevel Debug1"
            "IgnoreUnknown WarnWeakCrypto"
            "WarnWeakCrypto no-pq-kex"
            "IdentityFile /root/.ssh/id_ed25519"
            "Include ${config.sops.secrets."nixbuild/secret_env".path}"
          ];
      };

      programs.bash.shellAliases = {
        # After contemplating it for a while it does not make much sense to try and use nixbuild shell without
        #  sudo even if that is a code smell.
        #  One might duplicate the secrets needed against eu.nixbuild.net for the non-root user as well but
        #  then IDK if that is worth it.
        #  Long story short, see i.e., https://wiki.nixos.org/wiki/Distributed_build#Setting_up_SSH, for why
        #  on the NixOS deployment (i.e., multi user), the ssh configuration plus secrets need to be accessible
        #  by root.
	# 
	# The problem and probably a simple Host shell-on-nixbuild entry in global ssh_config would now 
	#  work too, that there was a remnant id_ed25519.pub file next to the private id_ed25519 that belonged
	#  to another older private IdentityFile latter which
	#  wasn't logged somehow even with -vvvvvv on nix build, I caught it when running plain
	#  rlwrap ssh -F ~/.ssh/config nixbuild-shell shell
        nixbuild-shell = "${lib.getExe pkgs.rlwrap} ssh -F ~/.ssh/config nixbuild-shell shell";
      };

      programs.ssh = {
        knownHosts = {
          nixbuild = {
            extraHostNames = [
              "eu.nixbuild.net"
              "88.99.66.151"
            ];
            # FIXME see https://search.nixos.org/options?channel=26.05&query=knownHosts#show=option%253Aprograms.ssh.knownHosts.%253Cname%253E.publicKey
            #  not hashed
            publicKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPIQCZc54poJ8vqawd8TraNryQeJnvH1eLpIDgbiqymM";
          };
        };

        # WARNING should have been "always included" https://search.nixos.org/options?channel=25.11&query=programs.ssh.knownHostsFiles but was not
        #knownHostsFiles = [ "/etc/ssh/ssh_known_hosts" ];
      };

      nix = {
        distributedBuilds = true;
        settings = {
          # DONT is already set in ./../base/general.nix
          #trusted-users = [ "${nixosUser}" ];
          builders-use-substitutes = true;
        };
        buildMachines = [
          {
            # TODO see man nix.conf (/machines), can use ssh match block's host here instead full hostname,
            # but tests on NixOS-WSL needed
            # WARNING new contrarian evidence: With eu.nixbuild.net set here the -vvvvv log shows that /etc/ssh/ssh_config is eread but only section * is actually applied aka section nixbuild ignored, thus using nixbuild again here:
            hostName = "nixbuild";
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
            sshKey = "/root/.ssh/id_ed25519";
            publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBJUUNaYzU0cG9KOHZxYXdkOFRyYU5yeVFlSm52SDFlTHBJRGdiaXF5bU0K";
            speedFactor = 2;
          }
        ];
      };
    };
}
