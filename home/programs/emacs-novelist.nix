# TODO Rework
{ config, lib, pkgs, rootPath, inputs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optionalAttrs
    types
    ;
  inherit (pkgs.stdenv.hostPlatform) system;
  inherit (pkgs.stdenv) isLinux isAarch64;

  emacs =
    if isLinux && isAarch64
    then inputs.emacs-overlay-cached.packages.${system}.emacs-unstable-nox
    else
      inputs.emacs-overlay.packages.${system}.emacs-unstable /* disabled for now as it causes rebuilds obviously*/ # .override ({
    #  withImageMagick = true;
    #  # https://github.com/NixOS/nixpkgs/blob/90fba39/pkgs/applications/editors/emacs/generic.nix#L319
    #  withPgtk = true;
    #  withGTK3 = true;
    #})
  ;

  emacsWithPackagesFromUsePackage =
    if isLinux && isAarch64
    then inputs.emacs-overlay-cached.lib.${system}.emacsWithPackagesFromUsePackage
    else inputs.emacs-overlay.lib.${system}.emacsWithPackagesFromUsePackage
  ;

  org-novelist = (pkgs.emacsPackages.trivialBuild rec {
    pname = "org-novelist";
    version = "0";
    src = "${inputs.org-novelist}";
    installPhase = ''
      target=$out/share/emacs/site-lisp/$pname/${pname}.el
      mkdir -p "$(dirname "$target")"
      cp *.el "$target"
    '';
    meta = with lib; {
      description = "Org Novelist is a system for writing novel-length fiction using Emacs Org mode.";
    };
  });

  # https://raw.githubusercontent.com/hrs/sensible-defaults.el/main/sensible-defaults.el
  sensible-defaults = (pkgs.emacsPackages.trivialBuild rec {
    pname = "sensible-defaults";
    version = "0";
    src = "${inputs.sensible-defaults.outPath}";
    phases = [ "installPhase" ];
    installPhase = ''
      target=$out/share/emacs/site-lisp/$pname/${pname}.el
      mkdir -p "$(dirname "$target")"
      cp "$src" "$target"
    '';
    meta = with lib; {
      description = "A simple, modular collection of better Emacs default settings.";
    };
  });
  sane-defaults = (pkgs.emacsPackages.trivialBuild rec {
    pname = "sane-defaults";
    version = "0";
    src = "${inputs.sane-defaults.outPath}";
    phases = [ "installPhase" ];
    installPhase = ''
      target=$out/share/emacs/site-lisp/$pname/${pname}.el
      mkdir -p "$(dirname "$target")"
      cp "$src" "$target"
    '';
    meta = with lib; {
      description = "An ever-changing set of emacs settings..";
    };
  });
  my-default-el = pkgs.emacsPackages.trivialBuild {
    pname = "default.el";
    version = "0";
    src = pkgs.writeText "default.el" ''
              (add-to-list 'load-path "${inputs.sensible-defaults.outPath}")
              (add-to-list 'load-path "${inputs.sane-defaults.outPath}")
              ${builtins.readFile "${rootPath}/home/misc/minimal.el"}
      ;; for explanation see https://emacs.stackexchange.com/questions/51989/how-to-truncate-lines-by-default and from there also
      ;; https://stackoverflow.com/questions/950340/how-do-you-activate-line-wrapping-in-emacs/950406#950406
      ;; You can explicitly enable line truncation for a particular buffer with the command C-x x t ( toggle-truncate-lines ). This works by locally changing the variable truncate-lines . If that variable is non- nil , long lines are truncated; if it is nil , they are continued onto multiple screen lines.
      (set-default 'truncate-lines nil)
      (set-default 'truncate-partial-width-windows nil)
      (setq auto-hscroll-mode 'current-line)
      ;; most important:
      ;; https://orgmode.org/worg/doc.html#org-startup-truncated
      (set-default 'org-startup-truncated nil)
      ;; TODO [F12 is impractial] Add F12 to toggle line wrap
      ;;(global-set-key (kbd "<f12>") 'toggle-truncate-lines)
      (use-package moe-theme
        :init

        (load-theme 'moe-light t))
        (add-hook 'before-save-hook nil)
    '';
    preferLocalBuild = true;
    allowSubstitutes = false;
    buildPhase = "";
  };

  cfg = config.custom.programs.emacs-novelist;
in

{

  # TODO research https://github.com/rougier/nano-emacs and nixvim in this flake for how to make many flavours of an editor @once

  ###### interface

  options = {

    custom.programs.emacs-novelist = {

      enable = mkEnableOption "emacs config specialised for org-novelist";

      finalPackage = mkOption {
        type = types.nullOr types.package;
        default = null;
        internal = true;
        description = ''
          Package of final emacs-novelist.
        '';
      };

    };

  };


  ###### implementation

  config = mkIf cfg.enable {
    # Or as in https://github.com/szermatt/mistty/issues/14
    custom.programs.emacs-novelist.finalPackage = (emacsWithPackagesFromUsePackage {
      alwaysEnsure = true;
      package = emacs;
      extraEmacsPackages = epkgs: with epkgs; [
        my-default-el
        moe-theme
        org-novelist
        better-defaults
        bind-key # FIXME not redundant ? Is in https://github.com/jwiegley/use-package
        use-package
        writeroom-mode
        which-key
        # https://cestlaz.github.io/posts/using-emacs-16-undo-tree/
        undo-tree
        smooth-scrolling
        sensible-defaults
        sane-defaults
        jinx
      ];
      config = "";
    });

    custom.programs.shell.shellAliases = { } // optionalAttrs (isLinux && isAarch64) { emacs-novelist = "emacs-novelist -nw"; };

    programs.info.enable = true;

    home.packages = with pkgs; [
      (pkgs.runCommand "emacs-novelist" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
        mkdir -p $out/bin	
        makeWrapper ${config.custom.programs.emacs-novelist.finalPackage.outPath}/bin/emacs $out/bin/emacs-novelist --argv0 emacs    
      '')
    ];
  };
}
