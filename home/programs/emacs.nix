{ config, lib, pkgs, rootPath, inputs, emacs, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optionalAttrs
    optionals
    optionalString
    types
    ;
  inherit (pkgs.stdenv) isLinux isAarch64 isx86_64;

  cfg = config.custom.programs.emacs;
in

{

  # TODO research https://github.com/rougier/nano-emacs and nixvim in this flake for how to make many flavours of an editor @once

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

    # TODO Or better for later refs: To built emacs when using the home-manager module as configured here, I would do:
    # nix build --json --accept-flake-config  --impure --print-build-logs .#nixOnDroidConfigurations.sams9.config.home-manager.config.programs.emacs.finalPackage | jq -r '.[].outputs | to_entries[].value' | cachix push 573-bc
    # See also https://github.com/nix-community/home-manager/blob/19c6a40/modules/programs/emacs.nix#L90
    # Does make sense now:
    # This is the goal - WITH packages
    # nix-repl> :p nixOnDroidConfigurations.sams9.config.home-manager.config.custom.programs.emacs.finalPackage.drvPath
    # "/nix/store/aiibhwmjwki6w7kfzpqfb0a9dxxqdsgs-emacs-unstable-with-packages-29.1-nox.drv"
    # This is just the bare emacs - WITHOUT packages
    # nix-repl> :p nixOnDroidConfigurations.sams9.pkgs.emacs.drvPath
    # "/nix/store/nanbgjyp8ys1sppyjbz6ksxql13ljgvr-emacs-unstable-29.1-nox.drv"
    # This could be used as well to cache, it comes via the inherit ... finalPackage
    # nix-repl> :p nixOnDroidConfigurations.sams9.config.home-manager.config.programs.emacs.finalPackage.drvPath
    # "/nix/store/aiibhwmjwki6w7kfzpqfb0a9dxxqdsgs-emacs-unstable-with-packages-29.1-nox.drv"
    custom.programs.emacs = { inherit (config.programs.emacs) finalPackage; };

    custom.programs.shell.shellAliases = { } // optionalAttrs (isLinux && isAarch64) { emacs = "emacs -nw"; };

    home.packages = builtins.attrValues {
      inherit (pkgs.librsvg)
      # https://www.emacswiki.org/emacs/EmacsSvg; not working when emacs -nw
      out
      # DONT # https://github.com/nix-community/home-manager/issues/3113
      #dconf
      #emacsPackages.git-annex
      ;
    };

    programs.info.enable = true;

    programs.emacs = {
      enable = true;

      package = emacs; #.pkgs.withPackages(epkgs: with epkgs; [mistty]); # pkgs.emacs; only when via overlay

      # .text = pkgs.lib.mkDefault( pkgs.lib.mkAfter "# hi" );
      # (load "~/.emacs.d/sanemacs.el" nil t)
      #extraConfig = builtins.readFile inputs."sanemacs.el".outPath; # builtins.readFile "${rootPath}/home/misc/emacs.el";
      extraConfig = ''
        (add-to-list 'load-path "${inputs.sensible-defaults.outPath}")
        (add-to-list 'load-path "${inputs.sane-defaults.outPath}")
        ${builtins.readFile "${rootPath}/home/misc/minimal.el"}
      '' + (optionalString (isLinux && isx86_64) ''
        ${builtins.readFile "${rootPath}/home/misc/emacs.el"}
      '') + ''
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

        (add-hook 'before-save-hook nil)
      '';

      extraPackages = epkgs: builtins.attrValues {
        inherit (epkgs)
        #(pack emacs.pkgs.melpaPackages) ++
          moe-theme
          better-defaults
          #vterm
          bind-key # FIXME not redundant ? Is in https://github.com/jwiegley/use-package
          use-package
          writeroom-mode
          which-key
          # https://cestlaz.github.io/posts/using-emacs-16-undo-tree/
          undo-tree
          smooth-scrolling
          repl-driven-development
          sensible-defaults
          sane-defaults
          org-novelist
	  ;
	}
        ++ optionals (isLinux && isx86_64) builtins.attrValues {
	inherit (epkgs)
          flymake-hledger
          hledger-mode
          sqlite3
          keycast
          deft
          zetteldeft
          company-emoji
          org-contrib
          visual-fill-column
          org-bullets
          ob-mermaid
          magit
	  ;
	  inherit (pkgs)
          git-annex
	  ;
        };

      overrides = _self: _super: {
        org-novelist = (pkgs.emacsPackages.trivialBuild rec {
          pname = "org-novelist";
          version = "0";
          src = "${inputs.org-novelist}";
          installPhase = ''
            target=$out/share/emacs/site-lisp/$pname/${pname}.el
            mkdir -p "$(dirname "$target")"
            cp *.el "$target"
          '';
          meta = {
            lib.description = "Org Novelist is a system for writing novel-length fiction using Emacs Org mode.";
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
          meta = {
            lib.description = "A simple, modular collection of better Emacs default settings.";
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
          meta = {
            lib.description = "An ever-changing set of emacs settings..";
          };
        });
      };
    };
  };
}
