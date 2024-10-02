# TODO Rework
{ config, lib, pkgs, rootPath, inputs, emacs, emacsWithPackagesFromUsePackage, ... }:

let
  inherit (lib)
    mkEnableOption
    mkIf
    mkOption
    optionalAttrs
    types
    ;
  inherit (pkgs.stdenv) isLinux isAarch64;

  inherit (emacs.pkgs) withPackages;# crucial to use the right version here as epkgs get byte-compiled for this exact emacs

  org-novelist = (emacs.pkgs.trivialBuild rec {
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
  });

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

  ox-html-markdown-style-footnotes = (emacs.pkgs.trivialBuild rec {
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
  });

  # TODO https://emacsnotes.wordpress.com/2022/06/29/use-org-extra-emphasis-when-you-need-more-emphasis-markers-in-emacs-org-mode/
  org-extra-emphasis = (emacs.pkgs.trivialBuild rec {
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
  });

  # https://raw.githubusercontent.com/hrs/sensible-defaults.el/main/sensible-defaults.el
  my-default-el = pkgs.emacsPackages.trivialBuild {
    pname = "default.el";
    version = "0";
    src = pkgs.writeText "default.el" ''
;; FIXME https://github.com/Gavinok/emacs.d/blob/main/init.el#L725
;;;; Code Completion
(use-package corfu
  :disabled
  :ensure t
  ;; Optional customizations
  :custom
  (corfu-cycle t)                 ; Allows cycling through candidates
  (corfu-auto t)                  ; Enable auto completion
  (corfu-auto-prefix 2)
  (corfu-auto-delay 0.1)
  (corfu-popupinfo-delay '(0.5 . 0.2))
  (corfu-preview-current 'insert) ; insert previewed candidate
  (corfu-preselect 'prompt)
  (corfu-on-exact-match nil)      ; Don't auto expand tempel snippets
  ;; Optionally use TAB for cycling, default is `corfu-complete'.
  :bind (:map corfu-map
              ("M-SPC"      . corfu-insert-separator)
              ("TAB"        . corfu-next)
              ([tab]        . corfu-next)
              ("S-TAB"      . corfu-previous)
              ([backtab]    . corfu-previous)
              ("S-<return>" . corfu-insert)
              ("RET"        . nil))

  :init
  (global-corfu-mode)
  (corfu-history-mode)
  (corfu-popupinfo-mode)) ; Popup completion info

(use-package cape
  :ensure t
  :defer 10
  :bind ("C-c f" . cape-file)
  :init
  ;; Add `completion-at-point-functions', used by `completion-at-point'.
  (defun my/add-shell-completion ()
    (interactive)
    (add-to-list 'completion-at-point-functions 'cape-history)
    (add-to-list 'completion-at-point-functions 'pcomplete-completions-at-point))
  (add-hook 'shell-mode-hook #'my/add-shell-completion nil t)
  :config
  ;; Make capfs composable
  (advice-add #'eglot-completion-at-point :around #'cape-wrap-nonexclusive)
  (advice-add #'comint-completion-at-point :around #'cape-wrap-nonexclusive)

  ;; Silence then pcomplete capf, no errors or messages!
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-silent)

  ;; Ensure that pcomplete does not write to the buffer
  ;; and behaves as a pure `completion-at-point-function'.
  (advice-add 'pcomplete-completions-at-point :around #'cape-wrap-purify))

      (use-package gcmh
        :ensure t
        :diminish
        :init (setq gc-cons-threshold (* 80 1024 1024))
        :hook (emacs-startup . gcmh-mode))

      (use-package which-key
        :hook (on-first-input . which-key-mode))

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
        :demand t
        :bind
        (:prefix-map rab/files-map
         :prefix "C-c f")
        :bind
        (:prefix-map rab/toggles-map
         :prefix "C-c t"))

      (use-package diminish :ensure t)

      (use-package corfu-terminal
        :ensure t
        :hook (on-first-buffer . global-corfu-mode))

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
        :bind
        ([remap capitalize-word] . capitalize-dwim)
        ([remap downcase-word] . downcase-dwim)
        ([remap upcase-word] . upcase-dwim))

      (use-package titlecase
        :ensure t
        :defer t)

      (setopt cursor-type 'bar)

      (use-package olivetti
        :demand t
        :init
        (setq olivetti-body-width 40)
        (setq olivetti-style 'fancy)
        (setq olivetti-minimum-body-width 30)
        :ensure t)

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

(setenv "DICPATH" "${pkgs.hunspellDicts.de_DE}/share/hunspell:${pkgs.hunspellDicts.en_US}/share/hunspell")

      ;; FROM HERE: https://blog.binchen.org/posts/what-s-the-best-spell-check-set-up-in-emacs/
      ;; and https://www.reddit.com/r/emacs/comments/10336qd/comment/j2xmb7g/
      ;; find aspell and hunspell automatically
(cond
 ;; try hunspell at first
  ;; if hunspell does NOT exist, use aspell
 ((executable-find "hunspell")
  (setq ispell-program-name "hunspell"
   flyspell-issue-message-flag t
   ispell-highlight-p t
   ispell-silently-savep t
   ispell-current-dictionary "de_DE,en_US")
   (setq ispell-hunspell-dict-paths-alist ;; /nix/store/8icvklwcdm08ksfzkjy6m610ycrd6c2d-home-manager-path/share/hunspell/de_DE.aff
   '(("de_DE" "${pkgs.hunspellDicts.de_DE.outPath}/share/hunspell/de_DE.aff")
     ("en_US" "${pkgs.hunspellDicts.en_US.outPath}/share/hunspell/en_US.aff")))
  (setq ispell-local-dictionary "de_DE")
  (setq ispell-local-dictionary-alist
        ;; Please note the list `("-d" "en_US")` contains ACTUAL parameters passed to hunspell
        ;; You could use `("-d" "en_US,en_US-med")` to check with multiple dictionaries
        '(("de_DE,en_US" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "de_DE,en_US") nil utf-8)))
 
  ;; new variable `ispell-hunspell-dictionary-alist' is defined in Emacs
  ;; If it's nil, Emacs tries to automatically set up the dictionaries.
  (when (boundp 'ispell-hunspell-dictionary-alist)
    (setq ispell-hunspell-dictionary-alist ispell-local-dictionary-alist))
;; Configure German and English.
   (setq ispell-dictionary "de_DE,en_US")

     ;; ispell-set-spellchecker-params has to be called before ispell-hunspell-add-multi-dic will work
  (ispell-set-spellchecker-params)
  (ispell-hunspell-add-multi-dic "de_DE,en_US")
  ;; For saving words to the personal dictionary, don't infer it from
  ;; the locale, otherwise it would save to ~/.hunspell_de_DE.
  (setq ispell-personal-dictionary "~/.emacs.d/.hunspell_personal")

  ;; The personal dictionary file has to exist, otherwise hunspell will
  ;; silently not use it.
  (unless (file-exists-p ispell-personal-dictionary)
    (write-region "" nil ispell-personal-dictionary nil 0))

    ;; for ispell see https://emacs.stackexchange.com/questions/42508/how-to-use-an-ispell-dictionary-in-company-mode and https://emacs.stackexchange.com/a/17238 and https://github.com/company-mode/company-mode/issues/1146
    )

  ((executable-find "aspell")
  (setq ispell-program-name "aspell")
  ;; Please note ispell-extra-args contains ACTUAL parameters passed to aspell
  (setq ispell-extra-args '("--sug-mode=ultra" "--lang=de_DE"))))

      ;; https://emacs.stackexchange.com/questions/73878/how-to-start-scratch-buffer-with-olivetti-org-mode-and-exotica-theme-altogether?rq=1
      (defun my/initial-layout ()
        "Create my initial screen layout."
        (interactive)
        ;; 2. having org-mode launch in scratch buffer from the beginning, and
        (switch-to-buffer "*scratch*")
        (org-mode)
        ;; (org-indent-mode)
        ;; 3. to have olivetti mode enabled too.
        ;; (olivetti-mode)
        ;; (delete-other-windows)
        )

      (my/initial-layout)
    '';
    /*''
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
    '';*/
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
      fun = epkgs: builtins.attrValues {
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
        corfu-terminal
        diminish
        no-littering
        gcmh
        olivetti
				cape 
				corfu
	;
      } ++ [
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
      custom.programs.emacs-novelist.finalPackage = (emacsWithPackagesFromUsePackage {
        alwaysEnsure = true;
        package = config.custom.programs.emacs-novelist.initialPackage;
        extraEmacsPackages = fun;
        config = "";
      });

      custom.programs.emacs-novelist.homePackage =
        (pkgs.runCommand "emacs-novelist" { nativeBuildInputs = [ pkgs.makeWrapper ]; } ''
          mkdir -p $out/bin	
          makeWrapper ${config.custom.programs.emacs-novelist.finalPackage.outPath}/bin/emacs $out/bin/emacs-novelist --argv0 emacs    
        '');

      custom.programs.shell.shellAliases = { } // optionalAttrs (isLinux && isAarch64) { emacs-novelist = "emacs-novelist -nw"; };

      programs.info.enable = true;

      home.packages = builtins.attrValues {
        inherit (pkgs)
        hunspell
	aspell
	;

	inherit
        (pkgs.hunspellDicts) 
	en_US
        de_DE
	;
	/*inherit
	(pkgs.texliveBasic)
	out
	;*/
	inherit
        (config.custom.programs.emacs-novelist)
	homePackage
	;
      };
    };
}
