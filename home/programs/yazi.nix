{
  pkgs,
  config,
  lib,
  inputs,
  #unstable,
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
        pkgs.yazi.override {
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

      initLua = ''
        require("git"):setup()

        require("yamb"):setup {
          -- Optional, the cli of fzf.
          cli = "fzf",
          -- Optional, a string used for randomly generating keys, where the preceding characters have higher priority.
          keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
          -- Optional, the path of bookmarks
          path = (ya.target_family() == "windows" and os.getenv("APPDATA") .. "\\yazi\\config\\bookmark") or
	    (os.getenv("HOME") .. "/.config/yazi/bookmark"),
        }
      '';

      keymap = {
        # F1 or ~ for help
        mgr.prepend_keymap = [
	  # https://github.com/sxyazi/yazi/discussions/2928
	  {
	    on = "s";
	    run = [ "tab_create ~" "search --via=fd" ];
	    desc = "Search in $HOME";
	  }
	  # https://github.com/sxyazi/yazi/discussions/3022#discussioncomment-14196133
	  {
	    on = [ "ß" ];
	    # copied https://github.com/lpnh/fr.yazi/blob/3d32e55b7367334abaa91f36798ef723098d0a6b/main.lua#L48
	    # see also https://github.com/phiresky/ripgrep-all/issues/151#issuecomment-1823138420
	    # default (via htop) seems --pre-glob *.{epub,EPUB,odt,ODT,docx,DOCX,fb2,FB2,ipynb,IPYNB,html,HTML,htm,HTM,pdf,PDF,asciipagebreaks,ASCIIPAGEBREAKS,mkv,MKV,mp4,MP4,avi,AVI,mp3,MP3,ogg,OGG,flac,FLAC,webm,WEBM,zip,ZIP,jar,JAR,xpi,XPI,kra,KRA,snagx,SNAGX,als,ALS,bz2,BZ2,gz,GZ,tbz,TBZ,tbz2,TBZ2,tgz,TGZ,xz,XZ,zst,ZST,tar,TAR,db,DB,db3,DB3,sqlite,SQLITE,sqlite3,SQLITE3}
	    run = ''search --via=rga --args="-g '!~$*'"'';
	    desc = "Search via rga";
	  }
          {
            run = "plugin ouch --args=zip";
            on = [ "C" ];
            desc = "Compress with ouch";
          }
	  {
	    run = "search --via=fd --args='-HI'";
	    on = [ "s" ];
	    desc = "Search files by name via fd";
	  }
          {
            on = [
              "c"
              "p"
            ];
            run = "plugin command";
            desc = "Yazi command prompt";
          }
          {
            on = [
              "u"
              "a"
            ];
            run = "plugin yamb save";
            desc = "Add bookmark";
          }
          {
            on = [
              "u"
              "g"
            ];
            run = "plugin yamb jump_by_key";
            desc = "Jump bookmark by key";
          }
          {
            on = [
              "u"
              "G"
            ];
            run = "plugin yamb jump_by_fzf";
            desc = "Jump bookmark by fzf";
          }
          {
            on = [
              "u"
              "d"
            ];
            run = "plugin yamb delete_by_key";
            desc = "Delete bookmark by key";
          }
          {
            on = [
              "u"
              "D"
            ];
            run = "plugin yamb delete_by_fzf";
            desc = "Delete bookmark by fzf";
          }
          {
            on = [
              "u"
              "A"
            ];
            run = "plugin yamb delete_all";
            desc = "Delete all bookmarks";
          }
          {
            on = [
              "u"
              "r"
            ];
            run = "plugin yamb rename_by_key";
            desc = "Rename bookmark by key";
          }
          {
            on = [
              "u"
              "R"
            ];
            run = "plugin yamb rename_by_fzf";
            desc = "Rename bookmark by fzf";
          }
          {
            on = [
              "g"
              "i"
            ];
            run = "shell 'gitui' --block";
            desc = "run gitui";
          }
          {
            on = "<A-t>";
            # See https://github.com/sxyazi/yazi/discussions/1430#discussion-7021191 and https://www.reddit.com/r/commandline/comments/8itpmd/comment/dyumsw3/
            # Also this does not help here but https://github.com/phiresky/ripgrep-all/discussions/168
            # Also the redir of error due to https://github.com/phiresky/ripgrep-all/issues/220
            # DONT for now no fzf --multi as it turned my session down with a sample of 2GB of zip files
            # Also see https://github.com/BurntSushi/ripgrep/issues/691#issuecomment-347044130 (escaping single quotes in multiline nix string didn't work neither ''' nor ''\' did)
            # On the other hand this glob pattern does need no quotes as it has no spaces
            run = ''shell 'rga "" --glob !*_ok.zip --hidden --no-follow 2> /dev/null | fzf --keep-right --wrap --preview "echo {}" --preview-window 'nohidden:wrap' | xclip -selection clipboard' --cursor=9 --block --interactive'';
            desc = "Opens fzf with results of rga query, just type in the filter in fzf when it runs.";
          }
        ];
      };

      plugins = with pkgs.yaziPlugins; {
        inherit
          ouch
          git
          ;
        bat = inputs.yazi-plugin-bat;
        command = inputs.command-yazi;
        yamb = inputs.yamb-yazi;
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

          prepend_fetchers = [
            {
              id = "git";
              name = "*";
              run = "git";
            }
            {
              id = "git";
              name = "*/";
              run = "git";
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

    programs.gitui.enable = true;

    # https://github.com/GianniBYoung/rsync.yazi https://github.com/KKV9/compress.yazi https://github.com/ndtoan96/ouch.yazi
    home.packages =
      builtins.attrValues {
        inherit (pkgs)
          _7zz
          zathura
          poppler
          bat
          ripgrep-all
          ;
      }
      ++ [
        (lib.hiPrio pkgs.ouch)
      ];
  };
}
