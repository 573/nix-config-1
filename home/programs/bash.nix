{ config, lib, ... }:

let
  inherit (lib)
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

        	# curr. https://github.com/nix-community/home-manager/blob/6e1eff9aac0e8d84bda7f2d60ba6108eea9b7e79/modules/programs/bash.nix#L211 - initExtra should (?) run before the hm-session-vars.sh is sourced so I make sure history expansion is suspended by then. Could reenable it at a certain phase again as well, is it guaranteed, that nix closures bodies are run in order ?
        	# set +H

		# inspo: https://discourse.nixos.org/t/how-do-folks-keep-a-cheat-sheet-of-terminal-konsole-commands/58565/6 https://unix.stackexchange.com/a/147787
		set -o vi
		bind Space:magic-space
      '';
    };

  };

}
