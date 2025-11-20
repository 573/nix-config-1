# TODO Rework
{
  config,
  lib,
  pkgs,
  rootPath,
  inputs,
  emacs,
  emacsWithPackagesFromUsePackage,
  ...
}:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optionalAttrs
    optionalString
    types
    ;
  inherit (pkgs.stdenv) isLinux isAarch64;

  inherit (emacs.pkgs) withPackages; # crucial to use the right version here as epkgs get byte-compiled for this exact emacs

  cfg = config.custom.programs.emacs-configured;
in

{

  # TODO research https://github.com/rougier/nano-emacs and nixvim in this flake for how to make many flavours of an editor @once

  ###### interface

  options = {

    custom.programs.emacs-configured = {

      enable = mkEnableOption "emacs where you load (via -l elfile) your own config";

      finalPackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package of final emacs-configured.
        '';
      };
      initialPackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package of package=emacs.
        '';
      };

      homePackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package in home.packages.
        '';
      };
      listOfPkgs = mkOption {
        # unnecessary but I want to learn about building emacs-packages-deps
        # so I could i. e. nix derivation show /nix/store/c8vwsxnbqfp09bg6gwhxvvz3f0hpym6y-emacs-moe-theme-20231006.639.drv | grep '"path"'
        default = null;
        internal = true;
        description = ''
                    list of Extra packages available to Emacs.
          	  nix eval --json .#nixosConfigurations.DANIELKNB1.config.home-manager.users.nixos.custom.programs.emacs-no-el.listOfPkgs  --json
          	  nix build ...
          	   0.0 MiB DL] building emacs-packages-deps
          	  nix derivation show ...
        '';
      };
    };

  };

  ###### implementation

  config =
    let
      fun =
        epkgs:
        builtins.attrValues {
          inherit (epkgs)
            moe-theme
            bind-key # u
            use-package # u
            which-key # https://elpa.gnu.org/packages/which-key.html
            emacs # u
            gcmh # https://elpa.gnu.org/packages/gcmh.html
            org # https://elpa.gnu.org/packages/org.html
            denote-silo # https://elpa.gnu.org/packages/denote-silo.html
            magit
            ;

          # See https://github.com/nix-community/emacs-overlay/blob/bdb0c5b/repos/melpa/recipes-archive-melpa.json
          inherit (epkgs.melpaPackages)
            #ac-ispell # https://elpa.gnu.org/packages/orderless.html, use case: https://blog.binchen.org/posts/autocomplete-with-a-dictionary-with-hippie-expand.html
            el-fly-indent-mode # u
            deadgrep
            #denote-org
            #denote-silo
            doom-modeline
            doom-themes
            nyan-mode
            org-cliplink
            pink-bliss-uwu-theme
            ;

          # See https://github.com/nix-community/emacs-overlay/blob/50e5f56/repos/elpa/elpa-generated.nix
          inherit (epkgs.elpaPackages)
            jinx # u
            cape # u
            corfu # u
            denote
            denote-org
            ;
        };
    in
    mkIf cfg.enable {
      # don't know how to avoid redundancy here
      custom.programs.emacs-configured.listOfPkgs = withPackages fun;

      custom.programs.emacs-configured.initialPackage = emacs;

      # Or as in https://github.com/szermatt/mistty/issues/14
      custom.programs.emacs-configured.finalPackage = (
        emacsWithPackagesFromUsePackage {
          alwaysEnsure = true;
          package = config.custom.programs.emacs-configured.initialPackage;
          extraEmacsPackages = fun;
          # Your Emacs config file. Org mode babel files are also
          # supported.
          # NB: Config files cannot contain unicode characters, since
          #     they're being parsed in nix, which lacks unicode
          #     support.
          # config = ./emacs.org;
          config = ""; # not used as defaultInitFile below is non-bool

          # Whether to include your config as a default init file.
          # If being bool, the value of config is used.
          # Its value can also be a derivation like this if you want to do some
          # substitution:
          defaultInitFile = pkgs.substitute {
            name = "default.el";
            # meaning el-file may contain @out@ etc. references to drv
            src = "${rootPath}/home/misc/emacs-gui.el";
	    substitutions = [
	      "--subst-var-by" "scowl" pkgs.scowl
	      "--subst-var-by" "hunspellDicts_de_DE" pkgs.hunspellDicts.de_DE 
	    ];
            #inherit (pkgs) scowl;
            #hunspellDicts_de_DE = pkgs.hunspellDicts.de_DE;
          };
        }
      );

      custom.programs.emacs-configured.homePackage = (
        pkgs.runCommand "emacs-configured"
          {
            nativeBuildInputs = [ pkgs.makeWrapper ];
          }
          ''
                      mkdir -p $out/bin
                      makeWrapper ${config.custom.programs.emacs-configured.finalPackage.outPath}/bin/emacs $out/bin/emacs-configured \
            	    --argv0 emacs --set TERM xterm-256color
          ''
        # https://discourse.nixos.org/t/home-manager-spacemacs/8033/5
      );

      custom.programs.shell.shellAliases =
        { }
        // optionalAttrs (isLinux && isAarch64) { emacs-no-el = "emacs-no-el -nw"; };

      programs.info.enable = true;

      home.packages = builtins.attrValues {
        inherit (pkgs)
          hunspell
          aspell
          enchant
	  ripgrep
          ;

        inherit (pkgs.hunspellDicts)
          en_US
          de_DE
          ;
        inherit (config.custom.programs.emacs-configured)
          homePackage
          ;
      };
    };
}
