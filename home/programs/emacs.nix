{ config, lib, pkgs, rootPath, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    types
    ;
  inherit (pkgs) emacsWithPackagesFromUsePackage;

  cfg = config.custom.programs.emacs;

  my-default-el = pkgs.runCommand "default.el" { text = builtins.readFile "${rootPath}/home/misc/emacs.el"; } ''
    	      target=$out/share/emacs/site-lisp/default.el
    	      mkdir -p "$(dirname "$target")"
    	      echo -n "$text" > "$target"
  '';

  alwaysEnsure = true;

  package = pkgs.emacs-git-nox;

  extraEmacsPackages = epkgs:
    with epkgs; [
      my-default-el # including this here seems essential while override = epkgs: epkgs // { inherit my-default-el; }; seems not and is also not sufficient itself
      vterm
      #treesit-grammars.with-all-grammars
      use-package
      moe-theme
      deft
      zetteldeft
      company-emoji
      org
      org-contrib
      visual-fill-column
      org-bullets
      writeroom-mode
    ];

in

{

  ###### interface

  options = {

    custom.programs.emacs = {

      enable = mkEnableOption "emacs config";

      finalPackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package of final emacs.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {

    custom.programs.emacs = { inherit (config.programs.emacs) finalPackage; };

    home.packages = [
      (emacsWithPackagesFromUsePackage {
        inherit package alwaysEnsure extraEmacsPackages;

        config = "";
      })
    ];
  };

}
