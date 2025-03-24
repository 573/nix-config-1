{
  config,
  lib,
  pkgs,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    ;

  cfg = config.custom.programs.alacritty;
in

{

  ###### interface

  options = {

    custom.programs.alacritty.enable = mkEnableOption "alacritty config";

  };

  ###### implementation

  config = mkIf cfg.enable {

    fonts = {
      fontconfig = {
        enable = true;
        defaultFonts = {
          monospace = [ "UbuntuMono Nerd Font" ];
        };
      };
    };

    home.packages = [ pkgs.nerd-fonts.ubuntu-mono ];

    programs.alacritty = {
      enable = true;

      package = config.lib.custom.wrapProgram {
        name = "alacritty";
        source = pkgs.alacritty;
        path = "/bin/alacritty";
        fixGL = true;
      };
      
      settings = {
        terminal.shell = {
	  # See man tmux
	  # See https://superuser.com/questions/209437/how-do-i-scroll-in-tmux
          args = [ "new-session" "-A" "-D" "-s" "main" ];
	  program = "${lib.getExe' config.custom.programs.tmux.finalPackage "tmux"}";
	};
      };
    };

  };

}
