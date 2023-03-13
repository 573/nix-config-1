{ config, lib, pkgs, inputs, rootPath, ... }:

let
  inherit (lib)
    elem
    mkIf
    mkMerge
    mkOption
    types
    ;

  cfg = config.custom.agenix;

  buildConfig = { name, host, user, fileName ? name }: mkIf (elem name cfg.secrets) {
    ${name} = {
      file = "${rootPath}/secrets/${host}/${fileName}.age";
      owner = user;
      group = user;
    };
  };
in

{

  imports = [ inputs.agenix.nixosModules.age ];


  ###### interface

  options = {

    custom.agenix.secrets = mkOption {
      type = types.listOf (types.enum [
        "wireless-config"
      ]);
      default = [ ];
      description = ''
        Secrets to install.
      '';
    };

  };


  ###### implementation

  config = {

    age = {
      secrets = mkMerge [
        (buildConfig {
          name = "wireless-config";
          host = "twopi";
          user = "root";
        })

      ];

      identityPaths = [
        "/root/.age/key.txt"
      ];
    };

  };

}
