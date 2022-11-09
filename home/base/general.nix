{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.base.general;

  localeGerman = "de_DE.UTF-8";
  localeEnglish = "en_US.UTF-8";
in {
  ###### interface

  options = {
    custom.base.general = {
      enable = mkEnableOption "basic config" // { default = true; };

      lightWeight =
        mkEnableOption "light weight config for low performance hosts";

      minimal = mkEnableOption "minimal config";
    };
  };

  ###### implementation

  config = mkIf cfg.enable (mkMerge [
    {
      custom.programs = {
#        bash.enable = true;
        htop.enable = true;
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
          httpie
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
          EDITOR = "vim";
          SHELL = "bash";
        };

        stateVersion = "22.05";
      };

      # FIXME: set to sd-switch once it works for krypton
      systemd.user.startServices = "legacy";
    }

    (mkIf (!cfg.minimal) {
      custom = {
        misc.util-bins.enable = true;

        # see ./home/programs
        programs = {
          nix-index.enable = true;
          nnn.enable = true;
        };
      };

      programs = {
        fzf.enable = true;
        home-manager.enable = true;
        git.enable = true;
      };
    })
  ]);
}
