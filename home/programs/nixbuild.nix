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
    mkMerge
    ;

  /*
    nixbuild-builder = lib.optionalString config.custom.base.non-nixos.enable ''
      ssh-ng://root@eu.nixbuild.net aarch64-linux,armv7l-linux,x86_64-linux ${
        config.sops.secrets."ssh/my-nixbuild-key".path
      } 100 2 benchmark,big-parallel - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBJUUNaYzU0cG9KOHZxYXdkOFRyYU5yeVFlSm52SDFlTHBJRGdiaXF5bU0K
    '';
  */

  my_key =
    let
      inherit (pkgs.stdenv) isLinux isAarch64;
    in
    if isLinux && isAarch64 then
      "${config.home.homeDirectory}/.ssh/my-nixbuild-key"
    else
      "${config.sops.secrets."ssh/my-nixbuild-key".path}";

  cfg = config.custom.programs.nixbuild;
in

{
  # FIXME overlap with ../../home/base/non-nixos.nix

  ###### interface

  options = {

    custom.programs.nixbuild.enable = mkEnableOption "nixbuild config";

  };

  ###### implementation
  config = mkIf cfg.enable (mkMerge [
    (mkIf (config.custom.base.non-nixos.enable) {
      #      programs.ssh.includes = config.programs.ssh.includes ++ [ "${config.sops.secrets."ssh/secret_env".path}" ];
      programs.ssh.matchBlocks.nixbuild =
        lib.debug.traceIf (config.custom.base.non-nixos.builders != [ ])
          "setting builder entry: eu.nixbuild.net" # "${builtins.toString nixbuild-builder}"
          {
            hostname = "eu.nixbuild.net";
            user = "root";
            extraOptions = {
              "Include" =
                let
                  inherit (pkgs.stdenv) isLinux isAarch64;
                in
                if isLinux && isAarch64 then
                  "${config.home.homeDirectory}/.ssh/secret_env"
                else
                  "${config.sops.secrets."ssh/secret_env".path}";
              "PubkeyAcceptedKeyTypes" = "ssh-ed25519";
              "IPQoS" = "throughput";
              # Rather no Debug3 here as that leaks secrets, still could use -vvv command line option when needed
              "LogLevel" = "Debug1";
              "IgnoreUnknown" = "WarnWeakCrypto";
              "WarnWeakCrypto" = "no-pq-kex";
            };
            serverAliveInterval = 60;
            identitiesOnly = true;
            identityFile = my_key;
            hashKnownHosts = true;
            #setEnv = {
            #  # builtins.readFile would put the secret into store
            # Also not what to do, rather use ssh -F config-loc with https://github.com/Mic92/sops-nix?tab=readme-ov-file#templates
            #  or see that https://discourse.nixos.org/t/sops-nix-templates-in-config-file/40225/2
            #  or even - though tat didn't work for openssh https://www.reddit.com/r/NixOS/comments/1draqf1/comment/lb3tyvc/
            #  NIXBUILDNET_SIGNING_KEY_FOR_BUILDS = config.sops.templates."nixbuild-sshconfig".content;
            #};
          };

      # explainer why lib.debug.traceIf (...) here would give infinite recursion: here, with potential workaround `mkMergeTopLevel` function https://gist.github.com/udf uses: https://gist.github.com/573/1ff0527f8b42b0123dc3a13bc523f487
      custom.base.non-nixos.builders = [
        # WARN to be tested but maybe nixbuild belonged here, see nix.buildMachines.nixbuild below
        (lib.optionalString config.custom.base.non-nixos.enable "eu.nixbuild.net") # nixbuild-builder
      ];
    })

    {

      nix.buildMachines.nixbuild = {
        hostName = "eu.nixbuild.net";
        maxJobs = 100;
        protocol = "ssh-ng";
        publicHostKey = "c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBJUUNaYzU0cG9KOHZxYXdkOFRyYU5yeVFlSm52SDFlTHBJRGdiaXF5bU0K";
        speedFactor = 2;
        sshKey = my_key;
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
      };

      #      nix.buildMachines = [ "eu.nixbuild.net" ];

      home.packages = builtins.attrValues {
        inherit (pkgs)
          rlwrap
          ;
      };

      custom.programs.shell.shellAliases = {
        nixbuild-shell = "nix run nixpkgs#rlwrap ssh nixbuild shell";
      };

    }
  ]);
}
