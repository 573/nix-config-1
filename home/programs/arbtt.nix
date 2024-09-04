{ config, lib, pkgs, ... }:

let
  inherit (lib)
    attrValues
    mkEnableOption
    mkIf
    mkForce
    ;

  cfg = config.custom.programs.arbtt;
in
{

  ###### interface

  options = {

    custom.programs.arbtt.enable = mkEnableOption "arbtt config";

  };


  ###### implementation

  config = mkIf cfg.enable {
  # FIXME https://github.com/toonn/nix-config/blob/master/home/home.nix
  home.packages = attrValues {
    inherit (pkgs)
      arbtt
      ;
  };

  systemd.user = {
    services = {
      "arbtt-capture" = {
        Service = { # https://github.com/nix-community/home-manager/tree/release-24.05/modules/services
          Environment = let path = builtins.concatStringsSep ":"
                                     ( map (p: "${lib.getBin p}/bin")
                                           ( attrValues { inherit (pkgs) arbtt coreutils; } # with pkgs; []
                                           )
                                     );
                         in "PATH=${path}";
          ExecStart
            = let script
	    # TODO more config: https://github.com/NixOS/nixpkgs/blob/release-21.05/nixos/modules/services/monitoring/arbtt.nix
                    = pkgs.writeShellScript "arbtt-capture-start" ''
                        set -e
                        DATADIR="''${XDG_DATA_HOME:-$HOME/.local/share/arbtt}"
                        LOG="''${DATADIR}/''$(date +%Y).capture"
                        mkdir -p "''${DATADIR}"
                        arbtt-capture --logfile="''${LOG}"
                      '';
               in "${script}";
          Restart = "always";
        };
        Unit = {
          Description = "Arbtt capture service";
          PartOf = [ "graphical-session.target" ];
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
    startServices = mkForce "sd-switch";
  };
  };

}
