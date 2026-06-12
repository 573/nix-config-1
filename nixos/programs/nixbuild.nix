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
      # DONT /etc/ssh/ssh_config should not be used as the Include will be attempted to be parsed at least
      # downstream aka user ssh except I put -F ~/.ssh/config then everytime or override GIT_SSH_COMMAND
      # which seems more cumbersome then just creating a ~/.ssh/config aka /root/.ssh/config to be used
      # by nix-daemon for the time being
      # /etc/ssh/ssh_config should really only contain common as in non-disputable stuff that doesn't
      # break valid user configs or makes the latter harder to maintain
      # programs.ssh.[...]

      #programs.bash.shellAliases = {
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
      #nixbuild-shell = "${lib.getExe pkgs.rlwrap} ssh -F ~/.ssh/config nixbuild-shell shell";
      # since using ~/.ssh/config this is simpler
      # DONT [also] this rather blongs entirely in home nixbuild.nix as the ssh stuff is configured there anyways see
      # comments there also why it belongs in the home module rather than in the nixos module. The use of the
      # ssh config nixbuild-shell host entry here isn't very transparent, a strong argument to put that config
      # entirely there close to the other ssh configuration related to nixbuild
      #nixbuild-shell = "${lib.getExe pkgs.rlwrap} ssh nixbuild-shell shell";
      #};

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
            # concerns nix-daemon so yes, root permissions
            # TODO now nixos sops-nix should work here too, i.e., [...].path = "/root/.ssh/id_ed25519"; not needed
            sshKey = "/root/.ssh/id_ed25519";
            publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBJUUNaYzU0cG9KOHZxYXdkOFRyYU5yeVFlSm52SDFlTHBJRGdiaXF5bU0K";
            speedFactor = 2;
          }
        ];
      };
    };
}
