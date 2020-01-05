{ config, pkgs, ... }:

{
  imports = [ ../../modules ];

  custom = {
    base = {
      general.lightWeight = true;

      non-nixos.installNix = false;
    };

    misc.dotfiles.modules = [ "nix-on-droid" ];

    programs = {
      shell.initExtra = ''
        if [[ -z "$SSH_AUTH_SOCK" ]]; then
          eval $(ssh-agent -s)
        fi
      '';

      ssh = {
        enableKeychain = false;
        controlMaster = "no";
        modules = [ "private" ];
      };
    };
  };

  home = {
    packages = with pkgs; [
      diffutils
      findutils
      gawk
      glibc.bin
      gnugrep
      gnused
      hostname
      man
      ncurses
    ];
  };
}
