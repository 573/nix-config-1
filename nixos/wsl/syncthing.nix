{
  config,
  lib,
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
  options.custom.wsl.syncthing = {
    enable = mkEnableOption "enable syncthing config" // optionalAttrs (config.custom.base.general.wsl) { default = true; };
  };

  config = mkIf (cfg.enable) {
    services = {
      syncthing = {
        enable = true;
        overrideFolders = true;
        overrideDevices = true;
        # see https://nixos.wiki/wiki/Syncthing
        user = "nixos";
        configDir = "/home/nixos/.config/syncthing";
        # https://search.nixos.org/options?channel=unstable&show=services.syncthing.settings&from=0&size=50&sort=alpha_asc&type=packages&query=services.syncthing
        settings = {
          options = {
            # https://docs.syncthing.net/users/faq.html#should-i-keep-my-device-ids-secret 
            announceLANAddresses = false;
            globalAnnounceEnabled = false;
            # https://forum.syncthing.net/t/enable-nat-traversal-what-does-it-do/13044/4
            natEnabled = false;
          };
          devices = {
            "Newer Laptop" = {
              id = config.sops.secrets."syncthing/device_1/id".path;
            };
            "Phone" = {
              id = config.sops.secrets."syncthing/device_2/id".path;
              label = config.sops.secrets."syncthing/device_2/label".path;
            };
            "Older Lenovo" = {
              id = config.sops.secrets."syncthing/device_3/id".path;
            };
          };
          folders = {
            "eins" = {
              devices = [
                "Newer Laptop"
                "Phone"
                "Older Lenovo"
              ];
              path = config.sops.secrets."syncthing/folder_1/path".path;
              id = config.sops.secrets."syncthing/folder_1/id".path;
              label = config.sops.secrets."syncthing/folder_1/label".path;
            };
          };
        };
      };
    };
  };
}
