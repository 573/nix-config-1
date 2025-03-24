{
  pkgs,
  config,
  lib,
  inputs,
  unstable,
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
          Package of final yazi.
        '';
      };
    };
  };

  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.yazi.finalPackage = lib.findFirst (
      item: builtins.match ".+?yazi.+?" item.name != null
    ) (abort "no matches") config.home.packages;

    programs.yazi = {
      enable = true;

      # https://github.com/sxyazi/yazi/issues/1046
      # FIXME https://github.com/sxyazi/yazi/issues/1726 (in upstream main only, use https://yazi-rs.github.io/docs/installation#cache)
      # also tried as in: https://discourse.nixos.org/t/patching-src-fails-and-limiting-hunks-doesnt-work-either/54406
      package = (
        unstable.yazi.override {
          optionalDeps = with pkgs; [
            jq
            _7zz
            fd
            ripgrep
            fzf
            zoxide
          ];
        }
      );

      enableBashIntegration = true;

      keymap = {
        # F1 or ~ for help
        mgr.prepend_keymap = [
          {
            run = "plugin ouch --args=zip";
            on = [ "C" ];
            desc = "Compress with ouch";
          }
        ];
      };

      plugins = with unstable.yaziPlugins; {
        inherit vcs-files yatline-githead;
        bat = inputs.yazi-plugin-bat;
	ouch = inputs.ouch-yazi;
      };

      theme = builtins.fromTOML (
        builtins.readFile "${inputs.catppuccin-yazi}/themes/latte/catppuccin-latte-lavender.toml"
      );

      # https://yazi-rs.github.io/docs/resources
      # https://sourcegraph.com/search?q=context:global+file:%5E*yazi.toml%24+content:zathura&patternType=standard&sm=1
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
          # FIXME preview not working, run="pdff"; wants .config/yazi/plugins/pdf.lua https://github.com/sxyazi/yazi/issues/110
          pdf = [
            {
              run = ''zathura "$@"'';
              block = true;
              desc = "Open with zathura";
              for = "unix";
            }
          ];
          edit = [
            {
              run = ''$EDITOR "$@"'';
              block = true;
              for = "unix";
            }
          ];
        };
        open = {
          rules = [
            # https://yazi-rs.github.io/docs/configuration/yazi#open
            # You can spot on a file to check it's mime-type with the default Tab key.
            {
              mime = "text/*";
              use = "edit";
            }
            {
              mime = "application/pdf";
              use = [
                "pdf"
                "reveal"
              ];
            }
          ];
        };
        plugin = {
          preloaders = [
            # PDF
            {
              mime = "application/pdf";
              run = "pdf";
            } # ?
          ];
          previewers = [
            # PDF
            {
              mime = "application/pdf";
              run = "pdf";
            } # ?
            {
              name = "*/";
              run = "folder";
              sync = true;
            }
            {
              mime = "text/*";
              run = "bat";
            }
            {
              mime = "*/xml";
              run = "bat";
            }
            {
              mime = "*/cs";
              run = "bat";
            }
            {
              mime = "*/javascript";
              run = "bat";
            }
            {
              mime = "*/x-wine-extension-ini";
              run = "bat";
            }
          ];

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
            # pdf previewer
            {
              mime = "application/pdf";
              run = "pdf";
            }
            {
              name = "*.csv";
              run = "bat";
            }
            {
              name = "*.md";
              run = "bat";
            }
          ];
        };
      };
    };

    xdg.enable = true;

    #xdg.configFile."yazi/plugins/ouch.yazi".source = inputs.ouch-yazi;
    #xdg.configFile."yazi/plugins/bat.yazi".source = inputs.yazi-plugin-bat;
    xdg.configFile."yazi/plugins/pdf.yazi/main.lua".source =
      "${inputs.yazi}/yazi-plugin/preset/plugins/pdf.lua";

    # https://github.com/GianniBYoung/rsync.yazi https://github.com/KKV9/compress.yazi https://github.com/ndtoan96/ouch.yazi
    home.packages =
      builtins.attrValues {
        inherit (unstable)
          _7zz
          zathura
          poppler
          bat
          ;
      }
      ++ [
        (lib.hiPrio unstable.ouch)
      ];
  };
}
