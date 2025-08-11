{
  pkgs,
  config,
  lib,
  inputs,
  ...
}@configArgs:
# TODO https://github.com/search?q=repo%3AGerschtli%2Fnix-config%20custom.base.desktop&type=code
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

  inherit (lib.lists)
    optional
    ;

  cfg = config.custom.base.general;

  commonConfig = config.lib.custom.commonConfig configArgs;
in

{
  imports = [
    inputs.home-manager.nixosModules.home-manager
  ];

  ###### interface

  options = {
    custom.base.general = {
      enable = mkEnableOption "basic config" // {
        default = true;
      };

      wsl = mkEnableOption "nixos-wsl specific nixos config";

      hostname = mkOption {
        type = types.enum [
          "DANIELKNB1"
          "nixos"
          "guitar"
          "twopi"
        ];
        description = "Host name.";
      };
    };

  };

  ###### implementation

  config = mkIf cfg.enable (mkMerge [
    {

      boot.tmp.cleanOnBoot = true;

      console.keyMap = lib.mkDefault "us-acentos";

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

        users = genAttrs ([ "root" ] ++ optional (!cfg.wsl) "dani" ++ optional cfg.wsl "nixos") (
          commonConfig.homeManager.userConfig cfg.hostname
        );
      };

      i18n.supportedLocales = [
        "C.UTF-8/UTF-8"
        "de_DE.UTF-8/UTF-8"
        "en_US.UTF-8/UTF-8"
      ];

      # Select internationalisation properties.
      i18n.defaultLocale = "en_US.UTF-8";

      i18n.extraLocaleSettings = {
        LC_ADDRESS = "de_DE.UTF-8";
        LC_IDENTIFICATION = "de_DE.UTF-8";
        LC_MEASUREMENT = "de_DE.UTF-8";
        LC_MONETARY = "de_DE.UTF-8";
        LC_NAME = "de_DE.UTF-8";
        LC_NUMERIC = "de_DE.UTF-8";
        LC_PAPER = "de_DE.UTF-8";
        LC_TELEPHONE = "de_DE.UTF-8";
        LC_TIME = "de_DE.UTF-8";
      };

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

          trusted-users = [ "root" ] ++ optional (!cfg.wsl) "dani" ++ optional cfg.wsl "nixos";
        };

        inherit (commonConfig.nix)
          nixPath
          package
          registry
          ;
      };

      # disabled because manually set via commonConfig.nix
      nixpkgs.flake = {
        setNixPath = false;
        setFlakeRegistry = false;
      };

      system = {
        configurationRevision = inputs.self.rev or "dirty";
        # FIXME this should go in host configuration.nix as each host
        # can be bootstrapped on a different version
        stateVersion = "24.11";
      };

      time.timeZone = "Europe/Berlin";

      users.users = (
        lib.optionalAttrs (!cfg.wsl) {
          # for NixOS-WSL in case of own user, see https://github.com/nix-community/NixOS-WSL/blob/4840f5d/modules/wsl-distro.nix#L89C5-L93C7
          dani = {
            uid = config.custom.ids.uids.dani;
            extraGroups = [ "wheel" ];
            isNormalUser = true;
          };
        }
      );
    }
  ]);
}
