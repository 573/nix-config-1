/**
  Original author's home'nix files are always prefixed with `{ config, lib, pkgs, ... }:` header

  Parameter `[inputs]` here is a deviation from the orinal author's intent (doing that via overlay) and should maybe be fixed
  For `[inputs]` parameter determine a solution (./../../nixos/programs/docker.nix also has the issue yet)
*/
{
  config,
  lib,
  pkgs,
  unstable,
  ...
}:
let
  inherit (lib)
    attrValues
    concatStringsSep
    mkEnableOption
    mkAfter
    mkIf
    mkMerge
    ;
  /**
    Attribute `system` here is determined that way (`inherit (pkgs.stdenv.hostPlatform) system;`) to make later use of parameter `[inputs]` here in this file (./../../home/base/desktop.nix), which is a deviation from the orinal author's intent (there an overlay is used to determine derivations from inputs, the intention of which is fine to narrow down `system` use to flake-related nix files I guess).

    If I want to rid overlays I might have to find a way with less potentially bad implications, IDK are there any ?
  */
  #inherit (pkgs.stdenv.hostPlatform) system;
  cfg = config.custom.base.general;
  localeGerman = "de_DE.UTF-8";
  localeEnglish = "en_US.UTF-8";
in
{
  ###### interface

  options = {
    custom.base.general = {
      enable = mkEnableOption "basic config" // {
        default = true;
      };

      lightWeight = mkEnableOption "light weight config for low performance hosts" // {
        default = false;
      };

      wsl = mkEnableOption "config for NixOS-WSL instances";

      minimal = mkEnableOption "minimal config";

      # FIXME https://github.com/nix-community/nix-on-droid/issues/257
      termux = mkEnableOption "config for the non-nixos termux android app";
    };
  };

  ###### implementation

  config = mkIf cfg.enable (mkMerge [
    {
      custom.programs = {
        #emacs-novelist.enable = true;
        emacs-no-el.enable = true;
        #emacs-nano.enable = true;
        bash.enable = true;
        #shell = {
        #  initExtra = mkAfter ''
        #                eval "$(${unstable.bat-extras.batpipe}/bin/batpipe)"
        #    	  '';
        #};
        htop.enable = true;
        nix-index.enable = true;
	helix.enable = true;
	#yazi.enable = true;
        #xplr.enable = true;
        neovim = {
          enable = true;
          # not inherit not same attr
          lightWeight = cfg.lightWeight;
        };
      };

	programs = {
	zoxide = {
	  enable = true;
	  package = unstable.zoxide;
	  enableBashIntegration = true;
	};
	bat = {
	  enable = true;
	  package = unstable.bat;
	  extraPackages = with unstable.bat-extras; [ batpipe batman ];
	};
	eza = {
	  enable = true;
	  enableBashIntegration = true;
	  package = unstable.eza;
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

        packages = attrValues {
          inherit (pkgs)
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
            #iotop
            jq
            mmv-go
            nmap
            ncdu
            #nload # network traffic monitor
            #pwgen
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

            psmisc # killall
            whois

            sqlite

            #actionlint
            #powerline-rs

            gist
            fd
            sd
            #pv

            # TODO https://www.arthurkoziel.com/restic-backups-b2-nixos
            #backblaze-b2
            attr

            nix-inspect
            #            zellij
            viddy
            #zoxide # rather home module
            ;

          #inherit (unstable)
           # eza
            #            yazi
            #;


          #	  batman = (unstable.bat-extras.batman.overrideAttrs (oldAttrs: {
          #    propagatedBuildInputs = [
          #      unstable.bat
          #    ];
          #  }));

        }; # replaces with pkgs; [], i. e. because nixd catches duplicates this way

        sessionVariables = {
          LESS = concatStringsSep " " [
            "--RAW-CONTROL-CHARS"
            "--no-init"
            "--quit-if-one-screen"
            "--tabs=4"
          ];
          PAGER = "${pkgs.less}/bin/less";
          SHELL = "bash";
          # TODO how does that interfere with same attr in neovim.nix
          #EDITOR = "vi";
          VISUAL = config.home.sessionVariables.EDITOR;
          # (ft-man-plugin),
          # https://neovim.io/doc/user/starting.html#starting,
          # https://www.chrisdeluca.me/2022/03/07/use-neovim-as.html
          # nix-repl> nixOnDroidConfigurations.sams9.config.home-manager.config.home.sessionVariables.MANPAGER
          # MANPAGER="nvim -u NONE -i NONE \"+runtime plugin/man.lua\" -c \"Man"'!'"\" -o -"
          # export MANPAGER='nvim -u NONE -i NONE "+runtime plugin/man.lua" -c "Man"''!'' -o -'
          #working#MANPAGER = "${config.custom.programs.neovim.finalPackage}/bin/nvim -u NONE -i NONE '+runtime plugin/man.lua' -c Man! -o -";
        };
      };
    }

    {
      home.stateVersion = "24.05";
    }

    {
      programs.fzf.enable = true;

      # FIXME: set to sd-switch once it works for krypton, https://home-manager-options.extranix.com/?query=systemd.user.startServices&release=release-24.05
      systemd.user.startServices = "legacy";
    }

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

      programs.home-manager.enable = true;
    })

    (mkIf cfg.wsl {
      custom.programs.shell.shellAliases = {
        pbcopy = "powershell.exe -NoProfile -Command \"Set-Clipboard -Value \\\$input\"";
        pbpaste = "powershell.exe -NoProfile -Command 'Get-Clipboard'";
      };

      # programs.starship.enable = true; # long lines are distorted
    })

    (mkIf (!cfg.lightWeight) {
      custom.programs = {
        tmux.enable = true;
        #emacs.enable = true;
      };

      home.packages = attrValues {
        inherit (pkgs)
          lshw
          ouch
          strace
          lineselect
          git-annex
          cyme

          # poc
          age

          #git-annex-remote-googledrive
          #haskellPackages.feedback
          #haskellPackages.pushme # broken
          #datalad
          #git-annex-utils
          ;
      };
    })
  ]);
}
