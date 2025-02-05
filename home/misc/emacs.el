;; @out@
;; @scowl@/share/dict/words.txt
;; @hunspellDicts_de_DE@/share/hunspell/de_DE.aff
;; my legacy stolen configs https://github.com/573/nix-config-1/commit/b534362097b3ca0d4011561b1085de40df0a7292#diff-9038ab981032e7f24c7ee557adf7d2ea5fbb6702153e6242d80dc61b3e256051
(message "https://www.gnu.org/software/emacs/manual/html_node/efaq/Learning-how-to-do-something.html")
(message "configuration is %S" "templated from home/misc/emacs.el: @out@ see C-x b *Messages* for the real path of emacs.el")
(message "works")

;; A simple way to manage personal keybindings.
;; needed by use-package
;; M-x describe-personal-keybindings
 (use-package bind-key
   :demand t)

(use-package gcmh
  :ensure t
  :diminish
  :init (setq gc-cons-threshold most-positive-fixnum)
  :hook (emacs-startup . gcmh-mode)
  :custom
  (gcmh-idle-delay 'auto)
  (gcmh-auto-idle-delay-factor 10)
  (gcmh-high-cons-threshold (* 16 1024 1024)))

(which-key-mode)

;; stolen from here:
;; https://github.com/minad/corfu?tab=readme-ov-file#configuration (example configuration)
(use-package corfu
  ;; Optional customizations
  :custom
  ;; (corfu-cycle t)                ;; Enable cycling for `corfu-next/previous'
   (corfu-auto t)                 ;; Enable auto completion
  ;; (corfu-separator ?\s)          ;; Orderless field separator
  ;; (corfu-quit-at-boundary nil)   ;; Never quit at completion boundary
  ;; (corfu-quit-no-match nil)      ;; Never quit, even if there is no match
  ;; (corfu-preview-current nil)    ;; Disable current candidate preview
  ;; (corfu-preselect 'prompt)      ;; Preselect the prompt
  ;; (corfu-on-exact-match nil)     ;; Configure handling of exact matches
  ;; (corfu-scroll-margin 5)        ;; Use scroll margin

  ;; Enable Corfu only for certain modes. See also `global-corfu-modes'.
  ;; :hook ((prog-mode . corfu-mode)
  ;;        (shell-mode . corfu-mode)
  ;;        (eshell-mode . corfu-mode))

  ;; Recommended: Enable Corfu globally.  This is recommended since Dabbrev can
  ;; be used globally (M-/).  See also the customization variable
  ;; `global-corfu-modes' to exclude certain modes.
  :init
  (global-corfu-mode))

;; A few more useful configurations...
(use-package emacs
  :custom
  ;; TAB cycle if there are only few candidates
  ;; (completion-cycle-threshold 3)

  ;; Enable indentation+completion using the TAB key.
  ;; `completion-at-point' is often bound to M-TAB.
  (tab-always-indent 'complete)

  ;; Emacs 30 and newer: Disable Ispell completion function. As an alternative,
  ;; try `cape-dict'.
  ;;(text-mode-ispell-word-completion nil)

  ;; Hide commands in M-x which do not apply to the current mode.  Corfu
  ;; commands are hidden, since they are not used via M-x. This setting is
  ;; useful beyond Corfu.
  (read-extended-command-predicate #'command-completion-default-include-p))

;; Use Dabbrev with Corfu!
;;(use-package dabbrev
  ;; Swap M-/ and C-M-/
;;  :bind (("M-/" . dabbrev-completion)
;;         ("C-M-/" . dabbrev-expand))
;;  :config
  ;;(add-to-list 'dabbrev-ignored-buffer-regexps "\\` ")
  ;; Since 29.1, use `dabbrev-ignored-buffer-regexps' on older.
;;  (add-to-list 'dabbrev-ignored-buffer-modes 'doc-view-mode)
;;  (add-to-list 'dabbrev-ignored-buffer-modes 'pdf-view-mode)
;;  (add-to-list 'dabbrev-ignored-buffer-modes 'tags-table-mode))

;; stolen from here:
;; https://github.com/minad/cape?tab=readme-ov-file#configuration
;; Enable Corfu completion UI
;; See the Corfu README for more configuration tips.
;; Add extensions
(use-package cape
  ;;:after corfu
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
  (add-hook 'completion-at-point-functions #'cape-dict)
  ;; https://sourcegraph.com/github.com/MiniApollo/kickstart.emacs/-/blob/init.el?L320-322
  ;;(add-to-list 'completion-at-point-functions #'cape-dict) ;; Dictionary completion
  ;; ...
  :config ;; start emacs ; C-x b *scratch* ; start typing ; C-c p w should suggest from dictionary now
  (setq cape-dict-file "@scowl@/share/dict/words.txt")
  ;; https://github.com/minad/cape/blob/ae98ec2/README.org#capf-transformers
  ;; Example 3: Create a Capf with debugging messages
  ;;(setq-local completion-at-point-functions (list (cape-capf-debug #'cape-dict)))
  ;; https://github.com/minad/cape?tab=readme-ov-file#super-capf---merging-multiple-capfs
;; Merge the dabbrev, dict and keyword capfs, display candidates together.
;;(setq-local completion-at-point-functions
;;            (list (cape-capf-super #'cape-dabbrev #'cape-dict #'cape-keyword)))

;; Alternative: Define named Capf instead of using the anonymous Capf directly
(defun cape-dabbrev-dict-keyword ()
  (cape-wrap-super #'cape-dabbrev #'cape-dict #'cape-keyword))
  (setq-local completion-at-point-functions (list #'cape-dabbrev-dict-keyword))
  )


;;M-? triggers correction for the misspelled word before point.
;;C-u M-? triggers correction for the entire buffer.
;;C-u C-u M-? forces correction of the word at point, even if it is not misspelled.
(use-package jinx
  :bind (("M-?" . jinx-correct)
	 ("M-C-k" . jinx-languages))
  :init
  (add-hook 'emacs-startup-hook #'global-jinx-mode))

;; TODO https://github.com/jiahaoli95/el-fly-indent-mode.el
(use-package el-fly-indent-mode
  :init
  (add-hook 'emacs-lisp-mode-hook #'el-fly-indent-mode))

(use-package  org-novelist
  :ensure nil
  ;;  :load-path "~/Downloads/"  ; The directory containing 'org-novelist.el'
  :custom
  ;; Setting de-DE leads to subtle errors (no localised files)
  (org-novelist-language-tag "en-GB")  ; The interface language for Org Novelist to use. It defaults to 'en-GB' when not set
  (org-novelist-author "Daniel Kahlenberg")  ; The default author name to use when exporting a story. Each story can also override this setting
  (org-novelist-author-email "573@users.noreply.github.com")  ; The default author contact email to use when exporting a story. Each story can also override this setting
  (org-novelist-automatic-referencing-p nil))


(use-package moe-theme
  :init
  ;; Show highlighted buffer-id as decoration. (Default: nil)
  (setq moe-theme-highlight-buffer-id t)

  ;; Resize titles (optional).
  (setq moe-theme-resize-markdown-title '(1.5 1.4 1.3 1.2 1.0 1.0))
  (setq moe-theme-resize-org-title '(1.5 1.4 1.3 1.2 1.1 1.0 1.0 1.0 1.0))
  (setq moe-theme-resize-rst-title '(1.5 1.4 1.3 1.2 1.1 1.0))

  ;; Highlight Buffer-id on Mode-line
  (setq moe-theme-highlight-buffer-id nil)

  ;; Choose a color for mode-line.(Default: blue)
  (setq moe-theme-set-color 'cyan)

  (load-theme 'moe-dark t))


;; https://stackoverflow.com/questions/36416030/how-to-enable-org-indent-mode-by-default
(setq org-startup-indented t)

;; https://stackoverflow.com/a/14370689
(show-paren-mode 1)
(setq blink-matching-delay 0.3)

;; https://www.emacswiki.org/emacs/AnsiTermHints
;; Terminal buffer configuration.
 (add-hook 'term-mode-hook 'my-term-mode-hook)
 (defun my-term-mode-hook ()
   ;; https://debbugs.gnu.org/cgi/bugreport.cgi?bug=20611
   (setq bidi-paragraph-direction 'left-to-right))

;; https://emacs.stackexchange.com/a/17674
;; https://github.com/AntonHakansson/org-nix-shell/blob/f359d9e1053fadee86dd668f4789ae2e700d8e8a/demo.org?plain=1#L5
;; https://discourse.nixos.org/t/nix-shells-in-emacs-org-mode-source-blocks/12673/73878
;; https://orgmode.org/worg/org-contrib/babel/languages/index.html
(org-babel-do-load-languages
 'org-babel-load-languages '((C . t) (python . t) (shell . t)))

;; Invalid read syntax "#" 1,2 when eval-buffer their demo.org and no nix-shell effective when using C-c C-c on 
;; blocks - if it worked added (nix . t) above to 'org-babel-load-languages
;;(use-package org-nix-shell
;;  :hook (org-mode . org-nix-shell-mode))

;; https://emacs.stackexchange.com/questions/73878/how-to-start-scratch-buffer-with-olivetti-org-mode-and-exotica-theme-altogether?rq=1
(defun my/initial-layout ()
  "Create my initial screen layout."
  (interactive)
  ;; 2. having org-mode launch in scratch buffer from the beginning, and
  (switch-to-buffer "*scratch*")
  (org-mode)
  ;; (org-indent-mode)
  ;; 3. to have olivetti mode enabled too.
  (olivetti-mode)
  (delete-other-windows)
  )

(my/initial-layout)
