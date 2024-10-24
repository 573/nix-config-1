{
  pkgs,
  config,
  lib,
  inputs,
  unstable,
  yazi,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;

  cfg = config.custom.programs.yazi;
in

{

  ###### interface

  options = {

    custom.programs.yazi = {
      enable = mkEnableOption "yazi config";

      finalPackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package of final emacs-nano.
        '';
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.yazi.finalPackage = config.programs.yazi.package;

    programs.yazi = {
      enable = true;

      # https://github.com/sxyazi/yazi/issues/1046
      # FIXME https://github.com/sxyazi/yazi/issues/1726 (in upstream main only, use https://yazi-rs.github.io/docs/installation#cache)
        # also tried as in: https://discourse.nixos.org/t/patching-src-fails-and-limiting-hunks-doesnt-work-either/54406
      package = yazi;

      enableBashIntegration = true;

      keymap = {
        # F1 or ~ for help
        manager.prepend_keymap = [
          {
            run = "plugin ouch --args=zip";
            on = [ "C" ];
            desc = "Compress with ouch";
          }
        ];
      };
      # https://yazi-rs.github.io/docs/resources
      settings = {
        log = {
          enabled = false;
        };
        opener = {
          extract = [
            {
              run = ''ouch d -y "%*"'';
              desc = "Extract here with ouch";
              for = "windows";
            }
            {
              run = ''ouch d -y "$@"'';
              desc = "Extract here with ouch";
              for = "unix";
            }
          ];
        };
        plugin = {
          prepend_previewers = [
            # Archive previewer
            {
              mime = "application/*zip";
              run = "ouch";
            }
            {
              mime = "application/x-tar";
              run = "ouch";
            }
            {
              mime = "application/x-bzip2";
              run = "ouch";
            }
            {
              mime = "application/x-7z-compressed";
              run = "ouch";
            }
            {
              mime = "application/x-rar";
              run = "ouch";
            }
            {
              mime = "application/x-xz";
              run = "ouch";
            }
          ];
        };
      };
    };

    xdg.enable = true;

    xdg.configFile."yazi/plugins/ouch.yazi".source = inputs.ouch-yazi;

    # https://github.com/GianniBYoung/rsync.yazi https://github.com/KKV9/compress.yazi https://github.com/ndtoan96/ouch.yazi
    home.packages = [
      unstable._7zz
    #  unstable.ouch
     # unstable.chafa
    ];
  };
}
