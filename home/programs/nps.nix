{
  config,
  lib,
  inputs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.nix-podman-stacks;
in

{
  imports = [
    inputs.nps.homeModules.nps

    {
      # see https://github.com/Tarow/nix-config/blob/84fd9b2fb266bba74b0adf5a4900cd9fdeea9496/modules/home-manager/stacks/default.nix#L78C5-L91C6
      # Add default config to every container
      options.services.podman.containers = lib.mkOption {
        type = lib.types.attrsOf (
          lib.types.submodule (
            { config, ... }:
            {
              extraConfig.Unit = {
                Wants = [ "sops-nix.service" ];
                After = [ "sops-nix.service" ];
              };
            }
          )
        );
      };
    }
  ];

  ###### interface

  options = {

    custom.programs.nix-podman-stacks.enable = mkEnableOption "nix-podman-stacks config";

  };

  ###### implementation

  config = mkIf cfg.enable {

    # see https://github.com/Tarow/nix-podman-stacks/issues/195#issuecomment-3312196230
    nps = {
      # host ip also possible here, than the link from homepage to paperless will work
      hostIP4Address = "0.0.0.0"; # "0.0.0.0";
      # TODO use uid
      hostUid = 1000;
      storageBaseDir = "${config.home.homeDirectory}/stacks";
      # FIXME better place
      externalStorageBaseDir = "/tmp";
      stacks = {
        # needed (manually on archlinux to enable rootless podman via nix standalone home-manager): 
	# - https://docs.podman.io/en/latest/markdown/podman.1.html#rootless-mode
        # - podman system migrate
        docker-socket-proxy.enable = true;
        homepage = {
          enable = true;
          #  containers.homepage.ports = [ "3000:3000" ];
          #containers.homepage.traefik = {};
          # see https://tarow.github.io/nix-podman-stacks/book/container-options.html#servicespodmancontainersnametraefikservicehost
        };

        paperless = {
          enable = true;
          adminProvisioning = {
            username = "admin";
            email = "admin@example.com";
            passwordFile = config.sops.secrets."paperless/admin_password".path;
          };
          secretKeyFile = config.sops.secrets."paperless/secret_key".path;
          db.passwordFile = config.sops.secrets."paperless/db_password".path;
        };
      };
    };
  };
}
