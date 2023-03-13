;; TODO Use / Integrate with https://github.com/radian-software/straight.el#integration-with-use-package-1 to also have things like https://github.com/rougier/nano-emacs possible

      ;; Disable startup message.
      (setq inhibit-startup-screen t
	    ;; https://github.com/emacs-dashboard/emacs-dashboard#emacs-daemon
	    initial-buffer-choice (lambda () (get-buffer "*Deft*"))
            ;; initial-buffer-choice 'ignore
            inhibit-startup-echo-area-message (user-login-name))

      (setq initial-major-mode 'fundamental-mode
            initial-scratch-message nil
            inhibit-startup-message t)

      ;; Set up fonts early.
      (set-face-attribute 'default
                          nil
                          :height 80
                          :family "Fantasque Sans Mono")
      (set-face-attribute 'variable-pitch
                          nil
                          :family "DejaVu Sans")


(use-package company-emoji
  :config (add-to-list 'company-backends 'company-emoji))

(use-package org
  :bind (
    ("C-c l" . org-store-link)
    :map org-mode-map
    ("C-c SPC" . nil)
    ("C-c SPC" . nil)
  )
  ;; https://orgmode.org/manual/Dynamic-Headline-Numbering.html - https://github.com/bzg/org-mode/blob/5dc8ea0/lisp/org.el#L1026
  :init (setq org-startup-numerated t)
  :config
    ;; Add some todo keywords.
  ;; https://orgmode.org/list/8763vfa9hl.fsf@legolas.norang.ca/
  (setq org-log-done t
    org-use-fast-todo-selection t
    )
  ;; https://orgmode.org/manual/Dynamic-Headline-Numbering.html#Dynamic-Headline-Numbering (numbered headlines in orgmode)

 ;; M-x list-colors-display (https://www.gnu.org/software/emacs/manual/html_node/elisp/Color-Names.html)
 (setq org-todo-keyword-faces
       '(("TODO"  . (:foreground "red" :weight bold))
 	("NEXT"  . (:foreground "red" :weight bold))
 	("DONE"  . (:foreground "forest green" :weight bold))
 	("WAITING"  . (:foreground "orange" :weight bold))
 	("RETEST"  . (:foreground "brightred" :weight bold))
 	("CANCELLED"  . (:foreground "forest green" :weight bold))
 	("SOMEDAY"  . (:foreground "orange" :weight bold))
 	("OPEN"  . (:foreground "red" :weight bold))
 	("CLOSED"  . (:foreground "forest green" :weight bold))
 	("ONGOING"  . (:foreground "orange" :weight bold))))

 (setq org-todo-keywords
       '((sequence "TODO(t)" "NEXT(n)" "|" "DONE(d!/!)")
 	(sequence "WAITING(w@/!)" "RETEST(r@/!)" "|" "CANCELLED(c!/!)")
 	(sequence "SOMEDAY(s!/!)" "|")
 	(sequence "OPEN(O!)" "|" "CLOSED(C!)")
     	(sequence "ONGOING(o)" "|")))

;; Unfortunately org-mode tends to take over keybindings that
;; start with C-c.
)

(use-package moe-theme
    :init
    ;; Show highlighted buffer-id as decoration. (Default: nil)
(setq moe-theme-highlight-buffer-id t)

;; Resize titles (optional).
(setq moe-theme-resize-markdown-title '(1.5 1.4 1.3 1.2 1.0 1.0))
(setq moe-theme-resize-org-title '(1.5 1.4 1.3 1.2 1.1 1.0 1.0 1.0 1.0))
(setq moe-theme-resize-rst-title '(1.5 1.4 1.3 1.2 1.1 1.0))

;; Highlight Buffer-id on Mode-line
;; (setq moe-theme-highlight-buffer-id nil)

;; Choose a color for mode-line.(Default: blue)
(setq moe-theme-set-color 'cyan)

(load-theme 'moe-dark t))

;; https://github.com/EFLS/zetteldeft/blob/a16a02e/docs/index.html#L628 - source for https://efls.github.io/zetteldeft/ that is linked here https://github.com/EFLS/zetteldeft/blame/0e56fe3b0bf8fddca6e3537abdc79128c93408f7/README.org#L13
(use-package deft
;;  :after org-super-links ;; does not work, needed ?
  :bind ("C-<f12>" . deft)
  :commands (deft)
  :config ;; https://github.com/jrblevin/deft/blame/462dd37db34a7c13baf3e2295c988d783ca9680b/README.md#L220
    (setq deft-extensions '("org")
    deft-directory "~/meinzettelkasten"
    deft-recursive t
          ;; deft-new-file-format "%Y-%m-%dT%H%M"
    deft-use-filename-as-title t
          ;; I tend to write org-mode titles with #+title: (i.e., uncapitalized). Also other org-mode code at the beginning is written in lower case.
          ;; In order to filter these from the deft summary, let’s alter the regular expression:
    deft-strip-summary-regexp
           (concat "\\("
                   "[\n\t]" ;; blank
                   "\\|^#\\+[a-zA-Z_]+:.*$" ;;org-mode metadata
                   "\\)")
          ;; Its original value was \\([\n ]\\|^#\\+[[:upper:]_]+:.*$\\).
          
	   deft-default-extension "org"))

(use-package zetteldeft
  :after deft
  :config (zetteldeft-set-classic-keybindings))


(org-babel-do-load-languages
 'org-babel-load-languages
 '((emacs-lisp . nil)
   (shell . t)))

;; https://github.com/joostkremers/visual-fill-column - Emacs mode for wrapping visual-line-mode buffers at fill-column. See https://stackoverflow.com/a/4879934/3320256 and https://gitlab.com/ndw/dotfiles/-/blob/16a02b38bbf7c5a750f0009fcd19636b039d2006/emacs.d/emacs.org#L1136 as well
(setq line-move-visual nil)
(setq visual-line-fringe-indicators '(left-curly-arrow right-curly-arrow))
;; (use-package visual-fill-column
;; :hook visual-line-mode)

(global-visual-line-mode)
(setq-default visual-fill-column-width 103)
(global-visual-fill-column-mode)

;;(use-package tree-sitter)

;;(use-package tree-sitter-langs
;;  :after tree-sitter)

;; (use-package nix-mode
;;   :mode ("\\.nix\\'" "\\.nix.in\\'"))
;; (use-package nix-drv-mode
;;   :ensure nix-mode
;;   :mode "\\.drv\\'")
;; (use-package nix-shell
;;   :ensure nix-mode
;;   :commands (nix-shell-unpack nix-shell-configure nix-shell-build))
;; (use-package nix-repl
;;   :ensure nix-mode
;;   :commands (nix-repl))

;; https://mstempl.netlify.app/post/beautify-org-mode/
(use-package org-bullets
  :custom
  (org-bullets-bullet-list '("◉" "☯" "○" "☯" "✸" "☯" "✿" "☯" "✜" "☯" "◆" "☯" "▶"))
  (org-ellipsis "⤵")
  :hook org-mode)

(font-lock-add-keywords 'org-mode
                        '(("^ *\\([-]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "•"))))))
(font-lock-add-keywords 'org-mode
                        '(("^ *\\([+]\\) "
                           (0 (prog1 () (compose-region (match-beginning 1) (match-end 1) "◦"))))))

;; i. e. https://github.com/DougBeney/emacs/blob/e55430a4c5fa6fc238676f3b3565f0afe6ee8e70/sanemacs.el#L56 does something annoying at least for me, see also https://stackoverflow.com/a/14164500/3320256 and for a cool workaround see https://emacs.stackexchange.com/questions/14438/remove-hooks-for-specific-modes
;; (remove-hook 'before-save-hook 'delete-trailing-whitespace)


;; TODO how to create a dynamic headline (rendered only) line in emacs

(deft)
