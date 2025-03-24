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

  nixbuild-builder = lib.optionalString config.custom.base.non-nixos.enable "ssh-ng://root@eu.nixbuild.net aarch64-linux,armv7l-linux ${config.home.homeDirectory}/.ssh/my-nixbuild-key 100 2 benchmark,big-parallel - c3NoLWVkMjU1MTkgQUFBQUMzTnphQzFsWkRJMU5URTVBQUFBSVBJUUNaYzU0cG9KOHZxYXdkOFRyYU5yeVFlSm52SDFlTHBJRGdiaXF5bU0K";

  cfg = config.custom.programs.nixbuild;
in

{ # FIXME overlap with ../../home/base/non-nixos.nix

  ###### interface

  options = {

    custom.programs.nixbuild.enable = mkEnableOption "nixbuild config";

  };

  ###### implementation
  config = mkIf cfg.enable (mkMerge [
    (mkIf (config.custom.base.non-nixos.enable) {
      programs.ssh.matchBlocks.nixbuild = lib.debug.traceIf (config.custom.base.non-nixos.builders != []) ''setting builder entry: ${builtins.toString nixbuild-builder}'' {
	  hostname = "eu.nixbuild.net";
	  user = "root";
	  extraOptions = {
	    "PubkeyAcceptedKeyTypes" = "ssh-ed25519";
	    "IPQoS" = "throughput";
	  };
          serverAliveInterval = 60;
	  identitiesOnly = true;
          identityFile = "${config.home.homeDirectory}/.ssh/my-nixbuild-key";
      };

      # explainer why lib.debug.traceIf (...) here would give infinite recursion: here, with potential workaround `mkMergeTopLevel` function https://gist.github.com/udf uses: https://gist.github.com/573/1ff0527f8b42b0123dc3a13bc523f487
      custom.base.non-nixos.builders = [ nixbuild-builder ];
    })

    {
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
