{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.base.general;

  localeGerman = "de_DE.UTF-8";
  localeEnglish = "en_US.UTF-8";
in
{
  ###### interface

  options = {
    custom.base.general = {
      enable = mkEnableOption "basic config" // { default = true; };

      lightWeight =
        mkEnableOption "light weight config for low performance hosts";

      wsl = mkEnableOption "config for NixOS-WSL instances";

      minimal = mkEnableOption "minimal config";
    };
  };

  ###### implementation

  config = mkIf cfg.enable (mkMerge [
    {
      custom.programs = {
        bash.enable = true;
        htop.enable = true;
        neovim.enable = true;
        nix-index.enable = true;
        tmux.enable = true;
        emacs.enable = true;
      };

      home = {
        language = {
          base = localeEnglish;
          address = localeEnglish;
          #collate = localeEnglish;
          #ctype = localeEnglish;
          measurement = localeGerman;
          #messages = localeEnglish;
          monetary = localeEnglish;
          name = localeEnglish;
          #numeric = localeEnglish;
          paper = localeGerman;
          telephone = localeEnglish;
          #time = localeGerman;
        };

        packages = with pkgs; [
          bc
          file
          # httpie   # build for aarch64-linux times out, https://github.com/573/nix-config-1/actions/runs/3744580521/jobs/6358117765#step:5:7429
          iotop
          jq
          mmv-go
          nmap
          ncdu
          nload # network traffic monitor
          pwgen
          ripgrep
          tree
          wget
          yq-go

          gzip
          unzip
          xz
          zip

          bind # dig
          netcat
          psmisc # killall
          whois
        ];

        sessionVariables = {
          LESS = concatStringsSep " " [
            "--RAW-CONTROL-CHARS"
            "--no-init"
            "--quit-if-one-screen"
            "--tabs=4"
          ];
          PAGER = "${pkgs.less}/bin/less";
          SHELL = "bash";
          # (ft-man-plugin),
          # https://neovim.io/doc/user/starting.html#starting,
          # https://www.chrisdeluca.me/2022/03/07/use-neovim-as.html
          # nix-repl> nixOnDroidConfigurations.sams9.config.home-manager.config.home.sessionVariables.MANPAGER
          # MANPAGER="nvim -u NONE -i NONE \"+runtime plugin/man.lua\" -c \"Man"'!'"\" -o -"
          # export MANPAGER='nvim -u NONE -i NONE "+runtime plugin/man.lua" -c "Man"''!'' -o -'
          MANPAGER = "${config.custom.programs.neovim.finalPackage}/bin/nvim -u NONE -i NONE '+runtime plugin/man.lua' -c Man! -o -";
        };

        stateVersion = "23.05";
      };

      programs.fzf.enable = true;

      # FIXME: set to sd-switch once it works for krypton
      systemd.user.startServices = "legacy";
    }

    (mkIf cfg.wsl {
      custom.programs.shell.shellAliases = {
        pbcopy = "powershell.exe -NoProfile -Command \"Set-Clipboard -Value \\\$input\"";
        pbpaste = "powershell.exe -NoProfile -Command 'Get-Clipboard'";
      };
    })

    (mkIf (!cfg.minimal) {
      custom = {
        misc.util-bins.enable = true;

        # see ./home/programs
        programs = {
          git.enable = true;
          nnn.enable = true;
          rsync.enable = true;
        };
      };

      programs = {
        home-manager.enable = true;
      };
    })
  ]);
}
