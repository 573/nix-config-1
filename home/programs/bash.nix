{ config, lib, pkgs, inputs, ... }:

let
  inherit (lib)
    mkAfter
    mkBefore
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.bash;
in

{

  ###### interface

  options = {

    custom.programs.bash.enable = mkEnableOption "bash config";

  };

  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.shell.enable = true;

    programs.bash = {
      enable = true;
      historySize = 10000000;
      historyFileSize = 20000000;
      historyControl = [
        "erasedups"
        "ignorespace"
        "ignoredups"
      ];
      historyIgnore = [
        "ls"
        "cd"
        "exit"
	"pwd"
      ];

      # mkBefore is needed because hashing needs to be enabled early in the config
      initExtra = mkBefore ''
                # enable hashing
                set -h

                # That still relevant ? Related see https://home-manager-options.extranix.com/?query=programs.bash.shellOptions with [ "histappend" ]
        	# curr. https://github.com/nix-community/home-manager/blob/6e1eff9aac0e8d84bda7f2d60ba6108eea9b7e79/modules/programs/bash.nix#L211 - initExtra should (?) run before the hm-session-vars.sh is sourced so I make sure history expansion is suspended by then. Could reenable it at a certain phase again as well, is it guaranteed, that nix closures bodies are run in order ?
        	# set +H

		# inspo: https://discourse.nixos.org/t/how-do-folks-keep-a-cheat-sheet-of-terminal-konsole-commands/58565/6 https://unix.stackexchange.com/a/147787
		set -o vi
		bind Space:magic-space
      '';

      bashrcExtra = lib.mkMerge [
''
      # DONE add https://github.com/magicmonty/bash-git-prompt to flake or make module 
      #if [ -f "$HOME/.bash-git-prompt/gitprompt.sh" ]; then
        GIT_PROMPT_ONLY_IN_REPO=1
	source "${inputs.bash-git-prompt}/gitprompt.sh"
      #fi

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
      ''
      # https://fzf-obc.readthedocs.io/en/1.3.0/installation/#add-fzf-obc-to-your-bashrc
      # Make sure that fzf-obc is always the last completion script loaded in your profile
    (mkAfter ''
    # from here: https://medium.com/@dvieitest/enhance-your-terminal-workflow-with-fzf-custom-completions-cc0e462cc483
#      _fzf_complete_docker() {
#    ARGS="$@"
#    if [[ "$ARGS" == "docker exec"* ]]; then
#      _fzf_complete --preview 'docker container logs {1} | ${lib.getExe' pkgs.coreutils "tail"}' -- "$@" < <(
#        docker container ls --format "table {{ .ID }}\t{{ .Image }}\t{{ .Names }}" | ${lib.getExe' pkgs.gawk "awk"} 'NR>1 {print $0}'
#      )
#    fi
#}

#_fzf_complete_docker_post() {
#  ${lib.getExe' pkgs.gawk "awk"} '{print $1}'
#}

     source ${pkgs.fzf-git-sh}/share/fzf-git-sh/fzf-git.sh
'')]; 
    };

  };

}
