{ config, lib, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    types
    ;

  cfg = config.custom.system.boot;
in

{

  ###### interface

  options = {

    custom.system.boot = {

      enable = mkEnableOption "Boot mode and device config" // {
        default = true;
      };

      mode = mkOption {
        type = types.enum [
          "efi"
          "grub"
          "raspberry"
        ];
        description = ''
          Sets mode for boot options.
        '';
      };

      device = mkOption {
        type = types.nullOr types.str;
        default = null;
        description = ''
          Device for GRUB boot loader.
        '';
      };
    };

  };

  ###### implementation

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.mode == "grub" -> cfg.device != null;
          message = "custom.system.boot.device needs to be set for grub mode.";
        }
      ];
    }

    (mkIf (cfg.mode == "efi") {
      boot.loader = {
        efi.canTouchEfiVariables = true;

        systemd-boot = {
          enable = true;
          editor = false;
        };
      };
    })

    (mkIf (cfg.mode == "grub") {
      boot.loader.grub = {
        inherit (cfg) device;

        enable = true;
      };
    })

    (mkIf (cfg.mode == "raspberry") {
      boot = {
        loader = {
          generic-extlinux-compatible.enable = true;

          grub.enable = false;
        };

        kernel.sysctl = {
          "vm.dirty_background_ratio" = 5;
          "vm.dirty_ratio" = 80;
        };

        kernelParams = [ "cma=32M" ];
      };
    })

  ]);
}
