{ config, lib, pkgs, rootPath, ... }:

with lib;

let
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

  ###### interface

  options = {

    custom.agenix.secrets = mkOption {
      type = types.listOf (types.enum [
        "cachix-agent-token-neon"
        "gitea-dbpassword"
        "id-rsa-backup"
        "mysql-backup-password"
        "teamspeak-serverquery-password"
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
          name = "cachix-agent-token-neon";
          fileName = "cachix-agent-token";
          host = "neon";
          user = "root";
        })

        (buildConfig {
          name = "gitea-dbpassword";
          host = "krypton";
          user = "gitea";
        })

        (buildConfig {
          name = "id-rsa-backup";
          host = "xenon";
          user = "storage";
        })

        (buildConfig {
          name = "mysql-backup-password";
          host = "argon";
          user = "backup";
        })

        (buildConfig {
          name = "teamspeak-serverquery-password";
          host = "krypton";
          user = "teamspeak-update-notifier";
        })

      ];

      identityPaths = [
        "/root/.age/key.txt"
      ];
    };

  };

}
