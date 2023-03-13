{ config, lib, pkgs, rootPath, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.cachix-agent;
in

{

  ###### interface

  options = {

    custom.cachix-agent = {

      enable = mkEnableOption "cachix-agent";

      hostName = mkOption {
        type = types.str;
        description = "Host name for cachix agent";
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    # FIXME w/o homeage: https://sourcegraph.com/github.com/nix-community/home-manager@release-23.05/-/blob/modules/services/cachix-agent.nix
    #custom.misc.homeage.secrets = [ "cachix-agent-token-${cfg.hostName}" ];

    services.cachix-agent = {
      enable = true;
      name = cfg.hostName;
      # FIXME w/o homeage
      #credentialsFile = config.homeage.file."cachix-agent-token-${cfg.hostName}".path;
    };

  };

}
