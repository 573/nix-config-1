# TODO Rework
{
  config,
  lib,
  pkgs,
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
    types
    ;
  inherit (pkgs.stdenv) isLinux isAarch64;

  inherit (emacs.pkgs) withPackages; # crucial to use the right version here as epkgs get byte-compiled for this exact emacs

  org-novelist = (
    emacs.pkgs.trivialBuild rec {
      pname = "org-novelist";
      version = "0";
      src = "${inputs.org-novelist.outPath}";
      installPhase = ''
        target=$out/share/emacs/site-lisp/$pname/${pname}.el
        mkdir -p "$(dirname "$target")"
        cp "$src/${pname}.el" "$(dirname "$target")"
      '';
      meta = {
        description = "Org Novelist is a system for writing novel-length fiction using Emacs Org mode.";
      };
    }
  );

  ox-odt = emacs.pkgs.melpaBuild {
    pname = "ox-odt";
    # nix-style unstable version 0-unstable-20240427 can be used after
    # https://github.com/NixOS/nixpkgs/pull/316726 reaches you
    version = "20240427.0";
    src = pkgs.fetchFromGitHub {
      owner = "kjambunathan";
      repo = "org-mode-ox-odt";
      rev = "89d3b728c98d3382a8e6a0abb8befb03d27d537b";
      hash = "sha256-/AXechWnUYiGYw/zkVRhUFwhcfknTzrC4oSWoa80wRw=";
    };
    # not needed after https://github.com/NixOS/nixpkgs/pull/316107 reaches you
    commit = "foo";

    # use :files to include only related files
    # https://github.com/melpa/melpa?tab=readme-ov-file#recipe-format
    recipe = pkgs.writeText "recipe" ''
      (ox-odt :fetcher git :url "")
    '';
  };

  ox-html-markdown-style-footnotes = (
    emacs.pkgs.trivialBuild rec {
      pname = "ox-html-markdown-style-footnotes";
      version = "0.2.0";
      src = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/jeffkreeftmeijer/ox-html-markdown-style-footnotes.el/0.2.0/ox-html-markdown-style-footnotes.el";
        sha256 = "sha256-S+lzFpGY44OgXAeM9Qzdhvceh8DvvOFiw5tgXoXDrsQ=";
      };

      meta = with lib; {
        description = "Markdown-style footnotes for ox-html.el";
        homepage = "https://jeffkreeftmeijer.com/ox-html-markdown-style-footnotes/";
        license = licenses.gpl3;
        platforms = platforms.all;
      };
    }
  );

  # TODO https://emacsnotes.wordpress.com/2022/06/29/use-org-extra-emphasis-when-you-need-more-emphasis-markers-in-emacs-org-mode/
  org-extra-emphasis = (
    emacs.pkgs.trivialBuild rec {
      pname = "org-extra-emphasis";
      version = "1";
      src = "${inputs.org-extra-emphasis.outPath}";
      # elisp dependencies
      #propagatedUserEnvPkgs = [
      #  ox-odt
      #];
      #buildInputs = propagatedUserEnvPkgs;
      #   installPhase = ''
      #     target=$out/share/emacs/site-lisp/$pname/${pname}.el
      #     mkdir -p "$(dirname "$target")"
      #     cp "$src/${pname}.el" "$(dirname "$target")"
      #   '';
      meta = {
        description = "Extra Emphasis markers for Emacs Org mode. https://irreal.org/blog/?p=10649";
      };
    }
  );

  # https://raw.githubusercontent.com/hrs/sensible-defaults.el/main/sensible-defaults.el
  my-default-el = pkgs.emacsPackages.trivialBuild {
    pname = "default.el";
    version = "0";
    src = pkgs.writeText "default.el" ''
            ;; https://git.rossabaker.com/ross/cromulent/src/commit/8bc7c365ad6e0ab16328cec3c34515b1f2554f94/gen/flake/emacs/init.el
            (use-package gcmh
              :ensure t
              :diminish
              :init (setq gc-cons-threshold (* 80 1024 1024))
              :hook (emacs-startup . gcmh-mode))

      (use-package zoom
        :ensure t
        :custom
        `(zoom-size ,(let ((phi (- (/ (+ 1 (sqrt 5)) 2) 1)))
                      (cons phi phi))))


            (use-package which-key
              :hook (on-first-input . which-key-mode)
        :diminish
        :custom
        (which-key-show-early-on-C-h t)
        (which-key-idle-delay most-positive-fixnum)
        (which-key-idle-secondary-delay 1e-9)
      	)

            (use-package no-littering
              :ensure t
              :init
              (setq no-littering-etc-directory "~/.cache/emacs/etc/"
                    no-littering-var-directory "~/.cache/emacs/var/")
              (when (fboundp 'startup-redirect-eln-cache)
                (startup-redirect-eln-cache
                 (convert-standard-filename
                  (expand-file-name  "eln-cache/" no-littering-var-directory)))))

            (use-package bind-key
              :demand t)

            (use-package diminish :ensure t)

      (use-package corfu
        :ensure t
          ;; Optional customizations
        ;; :custom
        ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
        ;; (corfu-auto t)                 ;; Enable auto completion
        ;; (corfu-separator ?\s)          ;; Orderless field separator
        ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
        ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
        ;; (corfu-preview-current nil)    ;; Disable current candidate preview
        ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
        ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
        ;; (corfu-scroll-margin 5)        ;; Use scroll margin

      ;;  :hook (on-first-buffer . global-corfu-mode)
      ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
        ;; be used globally (M-/).  See also the customization variable
        ;; `global-corfu-modes' to exclude certain modes.
        :init
        (global-corfu-mode))

            (use-package emacs-lock
              :config
              (with-current-buffer "*scratch*"
                (emacs-lock-mode 'kill)))

            (use-package ibuffer
              :bind
              ([remap list-buffers] . ibuffer))

            (use-package persist-state
              :ensure t
              :hook
              (on-first-input . persist-state-mode))

            (use-package suggest
              :ensure t)

            (setopt create-lockfiles nil)


            (use-package emacs
            :custom
        ;; TAB cycle if there are only few candidates
        ;; (completion-cycle-threshold 3)

        ;; Enable indentation+completion using the TAB key.
        ;; `completion-at-point' is often bound to M-TAB.
        (tab-always-indent 'complete)

        ;; Emacs 30 and newer: Disable Ispell completion function. As an alternative,
        ;; try `cape-dict'.
       ;; (text-mode-ispell-word-completion nil)

        ;; Hide commands in M-x which do not apply to the current mode.  Corfu
        ;; commands are hidden, since they are not used via M-x. This setting is
        ;; useful beyond Corfu.
        (read-extended-command-predicate #'command-completion-default-include-p))

      	;; Use Dabbrev with Corfu!
      (use-package dabbrev
        ;; Swap M-/ and C-M-/
        :bind (("M-/" . dabbrev-completion)
               ("C-M-/" . dabbrev-expand))
        :config
        (add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
        ;; Since 29.1, use `dabbrev-ignored-buffer-regexps' on older.
        (add-to-list 'dabbrev-ignored-buffer-modes 'doc-view-mode)
        (add-to-list 'dabbrev-ignored-buffer-modes 'pdf-view-mode)
        (add-to-list 'dabbrev-ignored-buffer-modes 'tags-table-mode))

            (use-package titlecase
              :ensure t
              :defer t)

            (setopt cursor-type 'bar)



      ;; https://elektrubadur.se/emacs-configuration/
      (use-package orderless
        :custom
        (completition-styles '(orderless basic))
        (completion-category-defaults nil)
        (completion-category-overrides '((file (styles partial-completion))))
        :config
        (let ((hook (defun my/minibuffer-setup ()
                      (setq-local completion-styles '(orderless basic)))))
          (remove-hook 'minibuffer-setup-hook hook)
          (add-hook 'minibuffer-setup-hook hook 1)))


            (use-package  org-novelist
              :ensure nil
            ;;  :load-path "~/Downloads/"  ; The directory containing 'org-novelist.el'
              :custom
            ;; Setting de-DE leads to subtle errors (no localised files)
                (org-novelist-language-tag "en-GB")  ; The interface language for Org Novelist to use. It defaults to 'en-GB' when not set
                (org-novelist-author "Daniel Kahlenberg")  ; The default author name to use when exporting a story. Each story can also override this setting
                (org-novelist-author-email "573@users.noreply.github.com")  ; The default author contact email to use when exporting a story. Each story can also override this setting
                (org-novelist-automatic-referencing-p nil))

            ;; inserting notes as comment blocks in org https://irreal.org/blog/?p=2029 has it's own command now see https://emacs.stackexchange.com/a/46992

            ;;  (require 'ox-odt)
              (require 'org-extra-emphasis)

      	
      ;; Add extensions
      (use-package cape
        ;; Bind prefix keymap providing all Cape commands under a mnemonic key.
        ;; Press C-c p ? to for help.
        :bind ("C-c p" . cape-prefix-map) ;; Alternative keys: M-p, M-+, ...
        ;; Alternatively bind Cape commands individually.
        ;; :bind (("C-c p d" . cape-dabbrev)
        ;;        ("C-c p h" . cape-history)
        ;;        ("C-c p f" . cape-file)
        ;;        ...)
        :init
        ;; Add to the global default value of `completion-at-point-functions' which is
        ;; used by `completion-at-point'.  The order of the functions matters, the
        ;; first function returning a result wins.  Note that the list of buffer-local
        ;; completion functions takes precedence over the global list.
        (add-hook 'completion-at-point-functions #'cape-dabbrev)
        (add-hook 'completion-at-point-functions #'cape-file)
        (add-hook 'completion-at-point-functions #'cape-elisp-block)
        ;;(add-hook 'completion-at-point-functions #'cape-dict)
        (add-to-list 'completion-at-point-functions #'cape-dict)
      ;; ...
      ;; https://github.com/minad/cape/issues/131
        ;; https://sourcegraph.com/github.com/erikbackman/nixos-config/-/blob/modules/programs/emacs/config/ebn-init.el?L777&rev=26a7a26
        ;;:config
        ;;(setq cape-dict-file "${pkgs.scowl}/share/dict/words.txt")
      )

      ;;(setq-local
      ;; cape--dict-words '(the be to of and a in that have I it for not on with he as you do at this but his by from they we say her she or an will my one all would there their what so up out if about who get which go me when make can like time no just him know take people into year your good some could them see other than then now look only come its over think also back after use two how our work first well way even new want because any these give day most us)
      ;; completion-at-point-functions (list #'cape-dict)
      ;; corfu-auto-delay 0
      ;; corfu-auto-prefix 0)

      (use-package jinx
        :bind (("M-?" . jinx-correct)
      	 ("M-C-k" . jinx-languages))
        :init
        (add-hook 'emacs-startup-hook #'global-jinx-mode)
        )

    '';
    /*
      ''
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
      '';
    */
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
          	  nix eval --json .#nixosConfigurations.DANIELKNB1.config.home-manager.users.nixos.custom.programs.emacs-novelist.listOfPkgs  --json
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
            #better-defaults
            bind-key # FIXME not redundant ? Is in https://github.com/jwiegley/use-package
            use-package
            #writeroom-mode
            which-key
            # https://cestlaz.github.io/posts/using-emacs-16-undo-tree/
            undo-tree
            #smooth-scrolling
            #sensible-defaults
            #sane-defaults
            #jinx
            titlecase
            suggest
            persist-state
            ibuffer-vc
            emacs
            #corfu-terminal
            diminish
            no-littering
            gcmh
            olivetti
            cape
            corfu
            zoom
            orderless
            ;

          inherit (epkgs.elpaPackages)
            jinx
            ;
        }
        ++ [
          org-novelist
          my-default-el
          org-extra-emphasis # FIXME https://emacsnotes.wordpress.com/2022/06/29/use-org-extra-emphasis-when-you-need-more-emphasis-markers-in-emacs-org-mode/, also install pdflatex etc.
          ox-odt
          ox-html-markdown-style-footnotes
        ];
    in
    mkIf cfg.enable {
      # don't know how to avoid redundancy here
      custom.programs.emacs-novelist.listOfPkgs = withPackages fun;

      custom.programs.emacs-novelist.initialPackage = emacs;

      # Or as in https://github.com/szermatt/mistty/issues/14
      custom.programs.emacs-novelist.finalPackage = (
        emacsWithPackagesFromUsePackage {
          alwaysEnsure = true;
          package = config.custom.programs.emacs-novelist.initialPackage;
          extraEmacsPackages = fun;
          config = "";
        }
      );

      custom.programs.emacs-novelist.homePackage = (
        pkgs.runCommand "emacs-novelist" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
          mkdir -p $out/bin	
          makeWrapper ${config.custom.programs.emacs-novelist.finalPackage.outPath}/bin/emacs $out/bin/emacs-novelist --argv0 emacs    
        ''
      );

      custom.programs.shell.shellAliases =
        { }
        // optionalAttrs (isLinux && isAarch64) { emacs-novelist = "emacs-novelist -nw"; };

      programs.info.enable = true;

      home.packages = builtins.attrValues {
        inherit (pkgs)
          hunspell
          aspell
          enchant
          ;

        inherit (pkgs.hunspellDicts)
          en_US
          de_DE
          ;
        /*
          inherit
             	(pkgs.texliveBasic)
             	out
           	;
        */
        inherit (config.custom.programs.emacs-novelist)
          homePackage
          ;
      };
    };
}
