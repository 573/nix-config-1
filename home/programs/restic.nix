{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  #cfg = config.custom.programs.restic;
in

{

  ###### interface

  options = {

    #custom.programs.restic.enable = mkEnableOption "restic config";

    # exists in hm as well as nixos
    # options.
    services.restic.backups = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.submodule (
          { name, config, ... }:
          {
            options = {
	    /**
	      How many days should be kept
	    */
              dailySnapshotsToKeep = lib.mkOption {
                type = lib.types.int;
              };
            };

            config = {
              pruneOpts = [
                "--keep-daily ${lib.toString config.dailySnapshotsToKeep}"
              ];
            };
          }
        )
      );
    };
  };

  ###### implementation

  /*
    config = mkIf cfg.enable {

    };
  */
}
