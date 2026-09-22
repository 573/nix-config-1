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

      # analog home.stateVersion = "26.05";
      shellWrapperName = lib.mkForce "y";

      # see also https://github.com/yazi-rs/yazi-rs.github.io/blob/0007618ca5cf144b6fb9634415239ec82a51576b/docs/installation.md?plain=1#L212
      # https://github.com/sxyazi/yazi/issues/1046
      # FIXME https://github.com/sxyazi/yazi/issues/1726 (in upstream main only, use https://yazi-rs.github.io/docs/installation#cache)
      # also tried as in: https://discourse.nixos.org/t/patching-src-fails-and-limiting-hunks-doesnt-work-either/54406
      /*
        package = (
          pkgs.yazi.override {
            # do this to shrink the set of optionalDeps - by default optionalDeps is https://github.com/NixOS/nixpkgs/blob/4c7870105e7f1fdf9c48688c8d7efc21abf0688a/pkgs/by-name/ya/yazi/package.nix#L8
            optionalDeps = lib.attrValues {
              inherit (pkgs)
                ripgrep-all
                _7zz
                zathura
                poppler
                ouch
                jq
                poppler-utils
                ffmpeg-headless
                fd
                ripgrep
                fzf
                zoxide
                imagemagick
                chafa
                resvg
                ;
            };
          }
        );
      */

      enableBashIntegration = true;

      # Rest is in already, see yazi --debug
      extraPackages = lib.attrValues {
        inherit (pkgs)
          ripgrep-all
          zathura
          poppler
          ouch
          git
          exiftool
          glow
          rich-cli
	  w3m-nox
          ;
      };

      keymap = {
        # F1 or ~ for help
        mgr.prepend_keymap = [
          {
            on = "T";
            run = "plugin toggle-pane max-preview";
            desc = "Maximize or restore the preview pane";
          }
          {
            # https://github.com/XYenon/yafg.yazi#usage
            on = [
              "F"
              "G"
            ];
            run = "plugin yafg";
          }
          # https://github.com/sxyazi/yazi/discussions/2928
          {
            on = "s";
            run = [
              "tab_create ~"
              "search --via=fd"
            ];
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
          #git
          toggle-pane
          piper
          rich-preview
          ;
        #bat = inputs.yazi-plugin-bat;
        # FIXME keybind c conflicting and ya.mgr_emit deprecated in https://github.com/KKV9/command.yazi/blob/523e6a57a4605013c99bda75174f344ec3460599/main.lua#L120
        #command = {
        #  package = inputs.command-yazi;
        #};

	term-cwd = {
	  package = "${inputs.yazi-plugins}/term-cwd.yazi";
	  setup = true;
	  settings = {
	    # Available values: OSC7 (default on unix), OSC9_9 (default on windows)
	    osc = "OSC7";
	  };
	};

        yafg = {
          package = yafg;
          setup = true;
          settings = {
            toggle_mode_key = "alt-t"; # fzf key to switch ripgrep/fzf mode (default: "ctrl-t")
            editor = "nvim"; # Editor command (default: "hx")
            args = ''{ "--noplugin" }''; # Additional editor arguments (default: {})
            file_arg_format = "+{row} {file}"; # File argument format (default: "{file}:{row}:{col}")
          };
        };

        yamb = {
          package = inputs.yamb-yazi;
          setup = true;
          settings = {
            # Optional, the cli of fzf.
            cli = "fzf";
            # Optional, a string used for randomly generating keys, where the preceding characters have higher priority.
            keys = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ";
            # Optional, the path of bookmarks
            path = ''
              (ya.target_family() == "windows" and os.getenv("APPDATA") .. "\\yazi\\config\\bookmark") or
                      	    (os.getenv("HOME") .. "/.config/yazi/bookmark")'';
          };
        };

        # TODO
        # https://codeberg.org/Hanker/augment-command.yazi#pager-pager
        # https://devctrl.blog/posts/search-yazi-unifying-fzf-ripgrep-fd-and-zoxide-in-the-terminal/
      };

      #      theme = builtins.fromTOML (
      #        builtins.readFile "${inputs.catppuccin-yazi}/themes/latte/catppuccin-latte-lavender.toml"
      #      );

      # https://yazi-rs.github.io/docs/resources
      # https://sourcegraph.com/search?q=context:global+file:%5E*yazi.toml%24+content:zathura&patternType=standard&sm=1
      # https://github.com/sxyazi/yazi/blob/f42a0df4df829b3c774e8f6dd03e10353269a23b/yazi-config/preset/yazi-default.toml#L109
      # https://github.com/sxyazi/yazi/tree/shipped/yazi-config/preset
      settings = lib.importTOML "${inputs.yazi}/yazi-config/preset/yazi-default.toml" // {
        preview = {
          # Change them to your desired values
          max_width = 3000;
          max_height = 3000;
        };
        opener = {
          zathura = [
            {
              run = ''zathura "$@" || echo "X11 needed"'';
              block = true;
              orphan = true;
              desc = "Open with zathura (on non-X11 use preview)";
              for = "unix";
            }
          ];
        };
        open = {
          prepend_rules = [
            {
              url = "*.pdf";
              use = "zathura";
            }
          ];
        };
        plugin = {
          prepend_previewers = [
            {
              url = "*.md";
              run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
            }
            {
              url = "*.csv";
              run = "rich-preview";
            } # for csv files
            {
              url = "*.md";
              run = "rich-preview";
            } # for markdown (.md) files
            {
              url = "*.rst";
              run = "rich-preview";
            } # for restructured text (.rst) files
            {
              url = "*.ipynb";
              run = "rich-preview";
            } # for jupyter notebooks (.ipynb)
            {
              url = "*.json";
              run = "rich-preview";
            } # for json (.json) files
            #    { url = "*.lang_type", run = "rich-preview"} # for particular language files eg. .py, .go., .lua, etc.
            {
              url = "*.html";
              run = ''piper -- w3m -dump -T text/html "$1"'';
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

    programs.zathura = {
      enable = true;
      package = pkgs.zathura.override {
        useMupdf = true;
      };
    };

    # https://github.com/GianniBYoung/rsync.yazi https://github.com/KKV9/compress.yazi https://github.com/ndtoan96/ouch.yazi

    /*
      home.packages = builtins.attrValues {
        inherit (pkgs)
          ripgrep-all
          _7zz
          zathura
          poppler
          ouch
          jq
          poppler-utils
          ffmpeg-headless
          fd
          ripgrep
          fzf
          zoxide
          imagemagick
          chafa
          resvg
          ;
      };
    */
  };
}
