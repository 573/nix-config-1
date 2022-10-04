{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.custom.base.general;

  localeGerman = "de_DE.UTF-8";
  localeEnglish = "en_US.UTF-8";

  sessionVariables = {
    EDITOR = "vim";
    SHELL = "bash";
    #LC_CTYPE = localeEnglish;
    #LC_NUMERIC = localeEnglish;
    #LC_TIME = localeGerman;
    #LC_COLLATE = localeEnglish;
    LC_MONETARY = localeEnglish;
    #LC_MESSAGES = localeEnglish;
    LC_PAPER = localeGerman;
    LC_NAME = localeEnglish;
    LC_ADDRESS = localeEnglish;
    LC_TELEPHONE = localeEnglish;
    LC_MEASUREMENT = localeGerman;
    LC_IDENTIFICATION = localeEnglish;
    LC_ALL = "";

    LANG = localeEnglish;
    LANGUAGE = localeEnglish;

    LESS = builtins.concatStringsSep " " [
      "--RAW-CONTROL-CHARS"
      "--no-init"
      "--quit-if-one-screen"
      "--tabs=4"
    ];
    PAGER = "${pkgs.less}/bin/less";
  };
in
{
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
      home = {
        inherit sessionVariables;

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

        stateVersion = "22.05";
      };

      # FIXME: set to sd-switch once it works for krypton
      systemd.user.startServices = "legacy";
    }

    (mkIf (!cfg.minimal) {
      custom = {
        misc.util-bins.enable = true;

        /* see ./home/programs
          programs = {
          };
        */
      };

      programs = {
        fzf.enable = true;
        home-manager.enable = true;
        git.enable = true;
        nnn.enable = true;
      };
    })
  ]);
}
