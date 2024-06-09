{ config, lib, pkgs, inputs, ... }:
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

      termux = mkEnableOption "config for the non-nixos termux android app";
    };
  };



  ###### implementation

  config = mkIf cfg.enable (mkMerge [
    (mkIf (!cfg.termux) {
      custom.programs = {
        emacs-novelist.enable = true;
        bash.enable = true;
        htop.enable = true;
        nix-index.enable = true;
        neovim = {
          enable = true;
          lightWeight = false; # FIXME Remove this line, only for testing if build works on nix-on-droid
        };
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
          # TODO Put into home/programs/neovim ASAP
          # https://discourse.nixos.org/t/how-can-i-distinguish-between-two-packages-who-has-the-same-name-for-the-binary/39770/2
          #(inputs.nixvim.packages."${system}".default)
          # this way can have nvim-mini in parallel
          # https://discourse.nixos.org/t/how-can-i-distinguish-between-two-packages-who-has-the-same-name-for-the-executable/39770/4
          # FIXME assumes now broken https://github.com/nix-community/nixvim/commit/d53afe0d7348b6c41a9127db4217adeaf1e9d69b
          # https://github.com/nix-community/nixvim/compare/main...573:nixvim:fit-23.11
          #(pkgs.runCommand "nix-nvim" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
          #           mkdir -p $out/bin
          #           makeWrapper ${inputs.nixvim.packages."${system}".default}/bin/nvim $out/bin/nix-nvim
          #           '')
          #nixvim-configured
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
          #ripgrep # build broken on aarch64-linux, https://github.com/573/nix-config-1/actions/runs/6309380420/job/17129186691, also build unmaintained currently
          silver-searcher
          tree
          wget
          yq-go

          gzip
          unzip
          xz
          zip

          bind # dig
          netcat

          iotop
          ncdu
          nload
          psmisc # killall
          whois

          sqlite

          eza
          #cachix
          yazi
          #actionlint
          #powerline-rs

          gist
          fd
          sd
          pv

          # TODO https://www.arthurkoziel.com/restic-backups-b2-nixos
          backblaze-b2
          attr

	  # poc
	  age
	  agenix-cli

	  nix-inspect
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
	  EDITOR = "vi";
	  VISUAL = "vi";
          # (ft-man-plugin),
          # https://neovim.io/doc/user/starting.html#starting,
          # https://www.chrisdeluca.me/2022/03/07/use-neovim-as.html
          # nix-repl> nixOnDroidConfigurations.sams9.config.home-manager.config.home.sessionVariables.MANPAGER
          # MANPAGER="nvim -u NONE -i NONE \"+runtime plugin/man.lua\" -c \"Man"'!'"\" -o -"
          # export MANPAGER='nvim -u NONE -i NONE "+runtime plugin/man.lua" -c "Man"''!'' -o -'
          #working#MANPAGER = "${config.custom.programs.neovim.finalPackage}/bin/nvim -u NONE -i NONE '+runtime plugin/man.lua' -c Man! -o -";
        };

      };

      programs.fzf.enable = true;

      # FIXME: set to sd-switch once it works for krypton
      systemd.user.startServices = "legacy";
    })

    (mkIf cfg.wsl {
      custom.programs.shell.shellAliases = {
        pbcopy = "powershell.exe -NoProfile -Command \"Set-Clipboard -Value \\\$input\"";
        pbpaste = "powershell.exe -NoProfile -Command 'Get-Clipboard'";
      };

      # programs.starship.enable = true; # long lines are distorted
    })

    {
        home.stateVersion = "23.11";
    }

    (mkIf cfg.termux {
      custom = {
        base.general = {
          lightWeight = true;
          minimal = true;
	};
        programs.emacs-novelist.enable = true;
      };
    })

    (mkIf (!cfg.lightWeight) {
      custom.programs = {
        tmux.enable = true;
        emacs.enable = true;
        emacs-novelist.enable = true;
        emacs-nano.enable = true;
        neovim = {
          enable = true;
          lightWeight = false;
        };
      };

      home.packages = with pkgs; [
        lshw
        ouch
        strace
        lineselect
        git-annex
        #git-annex-remote-googledrive
        #haskellPackages.feedback
        #haskellPackages.pushme # broken
        #datalad
        #git-annex-utils
      ];
    })

    (mkIf (!cfg.minimal) {
      custom = {
        misc.util-bins.enable = true;

        # see ./home/programs
        programs = {
          git.enable = true;
          nnn.enable = true;
          rsync.enable = true;
	  ssh = {
            enable = true;
          #  modules = [ "vcs" ];
          };
        };
      };

      programs = {
        home-manager.enable = true;
      };
    })
  ]);
}
