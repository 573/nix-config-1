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
    enable = mkEnableOption "i" // optionalAttrs (config.custom.base.general.wsl) { default = true; };
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
              id = "FDBTMR3-XQDMU6L-AJF6WBP-WC65GPB-ZS67G4Q-7KWG3LY-2JGOSL7-Z4QUJQF";
            };
            "Phone" = {
              id = "A3G3H6Q-RF3GJOT-AXXJSNJ-ZZCC2WW-3R55I3Y-XR5EJD7-S6RQAXT-FI6HWA2";
              label = "SM-G950F";
            };
            "Older Lenovo" = {
              id = "JVIDDEN-NPYWDCO-V37UT56-ICT46YW-MIGUWO3-AHANFTX-LYJX7Y4-S5G7UQ2";
            };
          };
          folders = {
            "xbvei-t7pxz" = {
              devices = [
                "Newer Laptop"
                "Phone"
                "Older Lenovo"
              ];
              path = "~/Musicupload";
              id = "xbvei-t7pxz";
              label = "Musicupload";
            };
            "v9gme-7b6ou" = {
              devices = [
                "Newer Laptop"
                "Phone"
                "Older Lenovo"
              ];
              path = "~/lebenslauf-cv.git";
              id = "v9gme-7b6ou";
              label = "Lebenslauf Git-Dir";
            };
            "ph2s3-y0cec" = {
              devices = [
                "Newer Laptop"
                "Phone"
                "Older Lenovo"
              ];
              path = "~/lebenslauf-cv";
              id = "ph2s3-y0cec";
              label = "Lebenslauf";
            };
            "n9duo-eqmww" = {
              devices = [
                "Newer Laptop"
                "Phone"
                "Older Lenovo"
              ];
              path = "~/stories";
              id = "n9duo-eqmww";
              label = "Stories";
            };
            "7zqso-s3dap" = {
              devices = [
                "Newer Laptop"
                "Phone"
                "Older Lenovo"
              ];
              path = "~/stories";
              id = "7zqso-s3dap";
              label = "Stories Git-Dir";
            };
          };
        };
      };
    };
  };
}
