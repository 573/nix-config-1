{ config, lib, pkgs, homeModules, inputs, rootPath, ... }@configArgs:

let
  inherit (lib)
    genAttrs
    mkEnableOption
    mkForce
    mkIf
    mkMerge
    mkOption
    types
    ;

  cfg = config.custom.base.general;

  commonConfig = config.lib.custom.commonConfig configArgs;
in

{

  imports = [
    inputs.home-manager.nixosModules.home-manager
    # Is in 23.05
    #    "${inputs.latest}/nixos/modules/services/web-apps/photoprism.nix"

    # FIXME Can this be guarded somehow as well ?
    inputs.nixos-wsl.nixosModules.wsl
  ];


  ###### interface

  options = {
    custom.base.general = {
      enable = mkEnableOption "basic config" // { default = true; };

      wsl = mkEnableOption "nixos-wsl specific config";

      hostname = mkOption {
        type = types.enum [ "DANIELKNB1" ];
        description = "Host name.";
      };
    };

  };


  ###### implementation

  config = mkIf cfg.enable (mkMerge [
  {

    boot.cleanTmpDir = true;

    console.keyMap = "de";

    custom = {
      system.firewall.enable = true;
    };

    documentation.nixos.enable = false;

    environment = {
      defaultPackages = [ ];
      shellAliases = mkForce { };
    };

    home-manager = {
      inherit (commonConfig.homeManager.baseConfig)
        backupFileExtension
        extraSpecialArgs
        sharedModules
        useGlobalPkgs
        useUserPackages
        ;

      users = genAttrs [ "root" "dkahlenberg" ] (commonConfig.homeManager.userConfig cfg.hostname);
    };

    i18n.supportedLocales = [
      "C.UTF-8/UTF-8"
      "de_DE.UTF-8/UTF-8"
      "en_US.UTF-8/UTF-8"
    ];

    networking = {
      hostName = cfg.hostname;
      usePredictableInterfaceNames = false;
    };

    nix = {
      settings = {
        inherit (commonConfig.nix.settings)
          experimental-features
          flake-registry
          log-lines
          substituters
          trusted-public-keys
          ;

        trusted-users = [ "root" "dkahlenberg" ];
      };

      inherit (commonConfig.nix)
        nixPath
        package
        registry
        ;
    };

    system = {
      configurationRevision = inputs.self.rev or "dirty";
      stateVersion = "23.05";
    };

    time.timeZone = "Europe/Berlin";

    users.users = {
      dkahlenberg = {
        uid = config.custom.ids.uids.dkahlenberg;
        extraGroups = [ "wheel" "syncthing" ];
        isNormalUser = true;
      };
    };
  }

  (mkIf (cfg.wsl) {
    wsl = {
      enable = true;
      defaultUser = "dkahlenberg";
      interop = {
        register = true;
        preserveArgvZero = true;
      };
      # FIXME disabled until https://www.catalog.update.microsoft.com/Search.aspx?q=KB5020030, https://support.microsoft.com/en-us/topic/november-15-2022-kb5020030-os-builds-19042-2311-19043-2311-19044-2311-and-19045-2311-preview-237a9048-f853-4e29-a3a2-62efdbea95e2 https://devblogs.microsoft.com/commandline/the-windows-subsystem-for-linux-in-the-microsoft-store-is-now-generally-available-on-windows-10-and-11/, native systemd needs these versions
      nativeSystemd = true;
      docker-native = {
        enable = true;
      };
    };

    # https://github.com/nix-community/NixOS-WSL/discussions/71
    security.sudo.wheelNeedsPassword = true;
  })

  ]);

}
