{
  config,
  lib,
  pkgs,
  ...
}@args:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    ;

  /*
    nixbuild-builder = lib.optionalString config.custom.base.non-nixos.enable ''
      ssh-ng://root@eu.nixbuild.net aarch64-linux,armv7l-linux,x86_64-linux ${
        config.sops.secrets."ssh/my-nixbuild-key".path
      } 100 2 benchmark,big-parallel - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBJUUNaYzU0cG9KOHZxYXdkOFRyYU5yeVFlSm52SDFlTHBJRGdiaXF5bU0K
    '';
  */
  /*
      evaluation warning: nixos profile: `programs.ssh.matchBlocks` defined in `/nix/store/d85ha9x4p056xjnf51fjl9r3wb1pqbl0-source/home/programs/ssh/default.nix' and `/nix/store/d85ha9x4p056xjnf51fjl9r3wb1pqbl0-source/home/programs/nixbuild.nix' is deprecated. Use `programs.ssh.settings`.
    evaluation warning: nixos profile: `programs.ssh.matchBlocks.nixbuild-shell.extraOptions` defined in `/nix/store/d85ha9x4p056xjnf51fjl9r3wb1pqbl0-source/home/programs/ssh/default.nix' and `/nix/store/d85ha9x4p056xjnf51fjl9r3wb1pqbl0-source/home/programs/nixbuild.nix' is deprecated. Move these OpenSSH options to `programs.ssh.settings.nixbuild-shell` using upstream directive names.
    evaluation warning: root profile: `programs.ssh.matchBlocks` defined in `/nix/store/d85ha9x4p056xjnf51fjl9r3wb1pqbl0-source/home/programs/ssh/default.nix' and `/nix/store/d85ha9x4p056xjnf51fjl9r3wb1pqbl0-source/home/programs/nixbuild.nix' is deprecated. Use `programs.ssh.settings`.
    evaluation warning: root profile: `programs.ssh.matchBlocks.nixbuild.extraOptions` defined in `/nix/store/d85ha9x4p056xjnf51fjl9r3wb1pqbl0-source/home/programs/ssh/default.nix' and `/nix/store/d85ha9x4p056xjnf51fjl9r3wb1pqbl0-source/home/programs/nixbuild.nix' is deprecated. Move these OpenSSH options to `programs.ssh.settings.nixbuild` using upstream directive names.
    evaluation warning: root profile: `programs.ssh.matchBlocks.nixbuild-shell.extraOptions` defined in `/nix/store/d85ha9x4p056xjnf51fjl9r3wb1pqbl0-source/home/programs/ssh/default.nix' and `/nix/store/d85ha9x4p056xjnf51fjl9r3wb1pqbl0-source/home/programs/nixbuild.nix' is deprecated. Move these OpenSSH options to `programs.ssh.settings.nixbuild-shell` using upstream directive names.
  */
  identityFile =
    let
      inherit (pkgs.stdenv) isLinux isAarch64;
    in
    if isLinux && isAarch64 then
      "${config.home.homeDirectory}/.ssh/my-nixbuild-key"
    else
      (
        if (!onNixos) then
          "${config.sops.secrets."nixbuild/my_nixbuild_key".path}"
        else
          # nixos sops-nix
          (
            if (config.home.username == "root") then
              "/run/secrets/nixbuild/my_nixbuild_key"
            else
              "/run/secrets/nixbuild/my_nixbuild_shell_key"
          )
      );

  cfg = config.custom.programs.nixbuild;

  # see https://github.com/nix-community/home-manager/blob/3ee51fbdac8c8bdfe1e7e1fcaba6520a563f394f/docs/manual/installation/nixos.md?plain=1#L147
  # and https://www.reddit.com/r/NixOS/comments/1hr7k3v/comment/m4vkz9k/
  # and https://www.reddit.com/r/NixOS/comments/1hr7k3v/comment/m4vugsi/
  # WARN only works when home-manager used as nixos module
  onNixos = builtins.hasAttr "osConfig" args;
in

{
  # FIXME overlap with ../../home/base/non-nixos.nix

  ###### interface

  options = {

    custom.programs.nixbuild.enable = mkEnableOption "nixbuild config";

  };

  ###### implementation
  config = mkIf cfg.enable (mkMerge [
    (mkIf (!onNixos) {
      # I.e., needed only when not on NixOS, bc when on NixOS nixos-config will handle:
      # - nix.buildMachines
      # - nix.settings
      # - home sops-nix
      nix.buildMachines = [
        {
          #hostName = "eu.nixbuild.net";
          hostName = "nixbuild";
          maxJobs = 100;
          protocol = "ssh-ng";
          publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBJUUNaYzU0cG9KOHZxYXdkOFRyYU5yeVFlSm52SDFlTHBJRGdiaXF5bU0K";
          speedFactor = 2;
          sshKey = identityFile;
          sshUser = "root";
          supportedFeatures = [
            "benchmark"
            "big-parallel"
          ];
          systems = [
            "aarch64-linux"
            "armv7l-linux"
            "x86_64-linux"
          ];
        }
      ];

      nix.settings.builders-use-substitutes = true;

      nix.extraOptions = lib.concatLines [ "builders = @~/.config/nix/machines" ];

      # FIXME remove
      # explainer why lib.debug.traceIf (...) here would give infinite recursion: here, with potential workaround `mkMergeTopLevel` function https://gist.github.com/udf uses: https://gist.github.com/573/1ff0527f8b42b0123dc3a13bc523f487
      custom.base.non-nixos.builders = [ "eu.nixbuild.net" ];

      custom.programs.sops-nix.enable = true;
    })

    {
      # for both NixOS and non-NixOS
      custom.programs.shell.shellAliases.nixbuild-shell =
        "${lib.getExe pkgs.rlwrap} ssh nixbuild-shell shell";

      # programs.ssh[...] needed both on NixOS as well as non-NixOS:
      # /root/.ssh/config (home.nix) favoured as opposed to /etc/ssh/ssh_config as latter
      # which leads to permissions worm hole.
      # secrets ought still to be handled different as sops-nix is not available on nix-on-droid.
      programs.ssh.settings =
        lib.optionalAttrs ((config.home.username == "root") || (!onNixos)) {
          nixbuild = lib.optionalAttrs ((config.home.username == "root") || (!onNixos)) (
            (
              {
                hostname = "eu.nixbuild.net";
                user = "root";
                serverAliveInterval = 60;
                identitiesOnly = true;
                inherit identityFile;
                hashKnownHosts = true;
              }
              // (lib.optionalAttrs (!onNixos) {
                PubkeyAcceptedKeyTypes = "ssh-ed25519";
                IPQoS = "throughput";
                LogLevel = "Debug1";
                IgnoreUnknown = "WarnWeakCrypto";
                WarnWeakCrypto = "no-pq-kex";
                Include =
                  let
                    inherit (pkgs.stdenv) isLinux isAarch64;
                  in
                  if isLinux && isAarch64 then
                    "${config.home.homeDirectory}/.ssh/secret_env"
                  else
                    "${config.sops.secrets."nixbuild/secret_env".path}";
              })
            )
            // (lib.optionalAttrs (onNixos && (config.home.username == "root")) {
              PubkeyAcceptedKeyTypes = "ssh-ed25519";
              IPQoS = "throughput";
              LogLevel = "Debug1";
              IgnoreUnknown = "WarnWeakCrypto";
              WarnWeakCrypto = "no-pq-kex";
              Include = "/run/secrets/nixbuild/secret_env";
            })
          );
        }
        // {
          "nixbuild-shell" = {
            hostname = "eu.nixbuild.net";
            user = "root";
            LogLevel = "Debug1";
            IgnoreUnknown = "WarnWeakCrypto";
            WarnWeakCrypto = "no-pq-kex";
            PubKeyAcceptedKeyTypes = "ssh-ed25519";
            IPQoS = "throughput";
            serverAliveInterval = 60;
            identitiesOnly = true;
            inherit identityFile;
          };
        };
    }
  ]);
}
