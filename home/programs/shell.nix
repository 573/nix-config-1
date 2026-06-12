{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

let
  inherit (lib)
    concatStringsSep
    escapeShellArg
    mapAttrsToList
    mkBefore
    mkEnableOption
    mkIf
    mkMerge
    mkOption
    optionalAttrs
    types
    ;

  cfg = config.custom.programs.shell;

  dynamicShellInitModule = types.submodule (_: {
    options = {
      condition = mkOption {
        type = types.str;
        example = "available cargo";
        description = ''
          Condition to be matched before the provided aliases and config are set.
          The value has to be a bash/zsh expression to be placed into an `if`.
        '';
      };

      initExtra = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Extra commands that should be run when `condition` is
          met. Commands need to be idempotent as they are potentially executed
          mulitple times.
        '';
      };

      shellAliases = mkOption {
        default = { };
        type = types.attrsOf types.str;
        example = {
          ll = "ls -l";
          ".." = "cd ..";
        };
        description = ''
          An attribute set that maps aliases (the top level attribute names in
          this option) to command strings or directly to build outputs.
        '';
      };
    };
  });

  initExtra = mkMerge [
    # mkBefore is needed because these commands need to be executed early in
    # the config
    (mkBefore ''
      available() {
        hash "$1" > /dev/null 2>&1
      }

      is_bash() {
        [[ -n "''${BASH_VERSION-}" ]]
      }

      eval "$(dircolors -b)"
    '')

    ''
      real-which() {
        realpath $(which -a $1)
      }

      # see https://junegunn.github.io/fzf/tips/ripgrep-integration/#8-handle-multiple-selections
      # ripgrep->fzf->vim [QUERY], vim install assumed
      rfv() (
	  RELOAD='reload:${lib.getExe' pkgs.ripgrep "rg"} --column --color=always --smart-case {q} || :'
	  # shellcheck disable=SC2016
	  OPENER='if [[ $FZF_SELECT_COUNT -eq 0 ]]; then
		    vim {1} +{2}     # No selection. Open the current line in Vim.
		  else
		    vim +cw -q {+f}  # Build quickfix list for the selected items.
		  fi'
	  ${lib.getExe' pkgs.fzf "fzf"} --disabled --ansi --multi \
	      --bind "start:$RELOAD" --bind "change:$RELOAD" \
	      --bind "enter:become:$OPENER" \
	      --bind "ctrl-o:execute:$OPENER" \
	      --bind 'alt-a:select-all,alt-d:deselect-all,ctrl-/:toggle-preview' \
	      --delimiter : \
	      --preview 'cat {2} {1}' \
	      --preview-window '~4,+{2}+4/3,<80(up)' \
	      --query "$*"
      )

      # I have a global ssh config for nixbuild that uses an include pointing
      # to a file readable by root aka the nix-daemon only.
      # Thus when using non-root ssh config without -F ssh parameter this
      # include aka file is always tried to be parsed which fails due to
      # permission situation.
      # See, i.e., https://www.cyberciti.biz/faq/tell-ssh-to-exclude-ignore-config-file/
      # Include /dev/null or /dev/zero also won't work, thus I simply use a
      # shell function that automates the -F ~/.ssh/config setting.
      ssh-do () {
        local server
	local arguments="$@"
	server=$(${lib.getExe' pkgs.gnugrep "grep"} -E '^Host ' ~/.ssh/config ~/.ssh/config.d/morehosts | ${lib.getExe' pkgs.gawk "awk"} '{print $2}' | ${lib.getExe pkgs.fzf})
	if [[ -n $server ]]; then
	  echo Running: ${lib.getExe' pkgs.openssh "ssh"} -F ~/.ssh/config "$server" "$arguments"
	  echo "  only hostnames supported, for ssh options passing run the raw command"
	  ${lib.getExe' pkgs.openssh "ssh"} -F ~/.ssh/config "$server" "$arguments" 
	fi
      }

      GIT_PROMPT_ONLY_IN_REPO=1
      source "${inputs.bash-git-prompt}/gitprompt.sh"

      source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh

      ${pkgs.ncurses}/bin/tabs -4 # set tab width to 4 spaces
    ''

    cfg.initExtra

    dynamicShellInit
  ];

  logoutExtra = ''
    [[ -e "$HOME/.lesshst" ]]             && rm -f "$HOME/.lesshst"
    [[ -e "$HOME/.xsession-errors.old" ]] && rm -f "$HOME/.xsession-errors.old"
    [[ -e "$HOME/.zcompdump" ]]           && rm -f "$HOME/.zcompdump"*

    ${pkgs.ncurses}/bin/clear

    ${cfg.logoutExtra}
  '';

  profileExtra = ''
    umask 022
  '';

  shellAliases =
    {
      #ls = "ls --color=auto";
      la = "ls -AFv";
      l1 = "ls -AFh1v";
      ll = "ls -AFhlv";
      llr = "ll /nix/var/nix/gcroots/auto --color=always | grep result";

      cp = "cp -iav";
      mv = "mv -iv";
      rm = "rm -iv";
      ln = "ln -iv";

      # WARNING do not use, as it brings errors all the time, i.e., when using cat in a pipe, i.e., cat file-with-base64 | [...] | base64 -d, I always forget to use the unaliased, aka \cat, version and loose hours debugging
      #cat = "${pkgs.bat}/bin/bat --color=always --paging=never --style=plain";

      # FIXME python dependency doesn't build on n-o-d prerelease-25.11
      #ytmp3 = ''${pkgs.yt-dlp}/bin/yt-dlp -x --continue --add-metadata --embed-thumbnail --audio-format mp3 --audio-quality 0 --metadata-from-title="%(artist)s - %(title)s" --prefer-ffmpeg -o "%(title)s.%(ext)s"'';

      grep = "grep --color=auto";
      fgrep = "fgrep --color=auto";
      egrep = "egrep --color=auto";

      sort-vn = "sort -t. -k 1,1n -k 2,2n -k 3,3n -k 4,4n";

      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";

      fcd = "cd $(${pkgs.fd}/bin/fd --type d | ${pkgs.skim}/bin/sk)";

      e = "nvim";

      bc = "bc -l";

      df = "df --human-readable --local --print-type";
      du = "du --human-readable --one-file-system --time --time-style=+'%Y-%m-%d' --total";

      rg = "rg --ignore-case --sort=path";

      ls = "${pkgs.eza}/bin/eza -alh --icons --git --group-directories-first";

      open = "xdg-open";

      pwgen = "pwgen -cns";
      pgen = "pwgen 30 1";

      tailf = "tail -f";

      tree = "tree -F --dirsfirst";
      treea = "tree -a";
      treei = "treea -I '.git|.idea'";

      ghlimits = "${pkgs.coreutils}/bin/date --date @`${pkgs.curl.bin}/bin/curl -s -i https://api.github.com/users/573 | ${pkgs.gnugrep}/bin/grep x-ratelimit-reset | ${pkgs.gawk}/bin/awk '{print $2}'`";
      dateviaepoch = "date --date @$(echo $EPOCHSECONDS)";
      nvimscaffold = "echo import os | nvim +\":set autochdir\" - +'file main.py' # https://neovim.io/doc/user/starting.html";

      nvi = "nvim -u NONE -i NONE";

      nix-stray-roots = "nix-store --gc --print-roots | egrep -v '^(/nix/var|/run/\w+-system|\{memory|\{censored|/proc/maps/)'";
    }
    // cfg.shellAliases
    // (optionalAttrs (dynamicShellInit != "") {
      refresh-shell = "source ${pkgs.writeText "refresh-shell" dynamicShellInit}";
    });

  dynamicShellInit = concatStringsSep "\n" (
    map (
      options:
      if (options.initExtra == "" && options.shellAliases == { }) then
        ""
      else
        ''
          if ${options.condition}; then
            ${
              concatStringsSep "\n" (mapAttrsToList (k: v: "alias ${k}=${escapeShellArg v}") options.shellAliases)
            }

            ${options.initExtra}
          fi
        ''
    ) cfg.dynamicShellInit
  );
in

{

  ###### interface

  options = {

    custom.programs.shell = {

      enable = mkEnableOption "basic shell config";

      envExtra = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Extra commands that should be run when setting up a shell.
        '';
      };

      initExtra = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Extra commands that should be executed when starting an interactive shell.
        '';
      };

      logoutExtra = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Extra commands that should be run when exiting a login shell.
        '';
      };

      loginExtra = mkOption {
        default = "";
        type = types.lines;
        description = ''
          Extra commands that should be run when initializing a login shell.
        '';
      };

      shellAliases = mkOption {
        default = { };
        type = types.attrsOf types.str;
        example = {
          ll = "ls -l";
          ".." = "cd ..";
        };
        description = ''
          An attribute set that maps aliases (the top level attribute names in
          this option) to command strings or directly to build outputs.
        '';
      };

      dynamicShellInit = mkOption {
        default = [ ];
        type = types.listOf dynamicShellInitModule;
        example = [
          {
            condition = "available composer";

            shellAliases = {
              cinstall = "composer install";
            };

            initExtra = ''
              # extra config
            '';
          }
        ];
        description = ''
          Specify dynamic shell init which has to be reloaded after environment change.

          Note: This only adds config and is not intended to cleanup after context switch
          when to defined conditions are no more true.
        '';
      };

    };

  };

  ###### implementation

  config = mkIf cfg.enable {

    programs = {
      bash = {
        inherit logoutExtra shellAliases;
        profileExtra = mkMerge [
          profileExtra
          cfg.envExtra
        ];
        initExtra = mkMerge [
          initExtra
          cfg.loginExtra
        ];
      };
    };

  };

}
