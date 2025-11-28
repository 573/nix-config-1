{
  config,
  lib,
  inputs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    optionalAttrs
    ;
  cfg = config.custom.wsl.syncthing;
in
{
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];

  options.custom.wsl.syncthing = {
    enable =
      mkEnableOption "enable syncthing config"
      // optionalAttrs (config.custom.base.general.wsl) { default = true; };
  };

  config = mkIf (cfg.enable) {
    sops = {
      validateSopsFiles = false;
      /*
              when using this form:
              defaultSopsFile = "/home/nixos/.sops/secrets/secrets.yaml";
              error:
               Failed assertions:
               - '/home/nixos/.sops/secrets/secrets.yaml' is not in the Nix store. Either add it to the Nix store or
        set sops.validateSopsFiles to false
      */
      defaultSopsFile = "/home/nixos/.sops/secrets/secrets.yaml"; # "${homeDir}/.sops/secrets/secrets.yaml";
      age.keyFile = "/home/nixos/.config/sops/age/keys.txt";
      secrets = {
        "syncthing_ts_key" = {
        };
        "syncthing_ts_cert" = {
        };
      };
    };
    systemd.services.syncthing.environment.STNODEFAULTFOLDER = "true";
    services = {
      syncthing = {

        enable = true;
        # see https://nixos.wiki/wiki/Syncthing
        user = "nixos";
        configDir = "/home/nixos/.config/syncthing";
        key = ''${config.sops.secrets."syncthing_ts_key".path}'';
        cert = ''${config.sops.secrets."syncthing_ts_cert".path}'';
        # https://search.nixos.org/options?channel=unstable&show=services.syncthing.settings&from=0&size=50&sort=alpha_asc&type=packages&query=services.syncthing
        settings = {
          options = {
            # https://docs.syncthing.net/users/faq.html#should-i-keep-my-device-ids-secret
            announceLANAddresses = false;
            globalAnnounceEnabled = false;
            # https://forum.syncthing.net/t/enable-nat-traversal-what-does-it-do/13044/4
            natEnabled = false;
            localAnnounceEnabled = false;
            urAccepted = -1;
            relaysEnabled = false;
          };
          devices = {
            Phone.name = "Phone";
            Phone.id = "A3G3H6Q-RF3GJOT-AXXJSNJ-ZZCC2WW-3R55I3Y-XR5EJD7-S6RQAXT-FI6HWA2";
            "Older Lenovo".name = "Older Lenovo";
            "Older Lenovo".id = "U37SSAX-BKPDCLM-VLYMAQ7-P5I256H-FWRUTZQ-WS2R4UM-5VTDREP-3BUG7QB";
            Samsung.name = "Samsung";
            Samsung.id = "KTQ3YZD-722APNB-ONOELMK-3WYUV44-75VXJYC-IFTQ43G-HDS7BZ2-X2BWWQW";
          };
        };
      };
    };
  };
}
