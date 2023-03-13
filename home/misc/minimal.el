(setq inhibit-startup-screen t
      ;; https://github.com/emacs-dashboard/emacs-dashboard#emacs-daemon
      ;; initial-buffer-choice (lambda () (get-buffer "*Deft*"))
      initial-buffer-choice 'ignore
      inhibit-startup-echo-area-message (user-login-name))

;; Enable transient mark mode
;;(transient-mark-mode 1)

;;(delete-selection-mode 1)

(setq initial-major-mode 'fundamental-mode
      initial-scratch-message nil
      inhibit-startup-message t)

;; Set up fonts early.
(set-face-attribute 'default
                    nil
                    :height 60
                    :family "Fantasque Sans Mono")
(set-face-attribute 'variable-pitch
                    nil
                    :family "DejaVu Sans")

(require 'sensible-defaults)
(sensible-defaults/use-all-settings)
(sensible-defaults/use-all-keybindings)

(require 'sane-defaults)


;; ICOP see https://github.com/justbur/emacs-which-key/issues/130
(which-key-mode)

(use-package bind-key)

;; Source: https://alhassy.com/emacs.d/
;; Allow tree-semantics for undo operations.
(use-package undo-tree
  :diminish                       ;; Don't show an icon in the modeline
  :bind ("C-x u" . undo-tree-visualize) ;; needs (use-package bind-key) or similar
  ;;:hook (org-mode . undo-tree-mode) ;; For some reason, I need this. FIXME.
  :config
    ;; Always have it on
    (global-undo-tree-mode)

    ;; Each node in the undo tree should have a timestamp.
    (setq undo-tree-visualizer-timestamps t)

    ;; Show a diff window displaying changes between undo nodes.
    (setq undo-tree-visualizer-diff t))

;; Execute (undo-tree-visualize) then navigate along the tree to witness
;; changes being made to your file live!

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

(use-package jinx
  :hook (emacs-startup . global-jinx-mode)
  :bind (("M-$" . jinx-correct)
         ("C-M-$" . jinx-languages)))

(use-package  org-novelist
  :ensure nil
;;  :load-path "~/Downloads/"  ; The directory containing 'org-novelist.el'
  :custom
;; Setting de-DE leads to subtle errors (no localised files)
    (org-novelist-language-tag "en-GB")  ; The interface language for Org Novelist to use. It defaults to 'en-GB' when not set
    (org-novelist-author "Daniel Kahlenberg")  ; The default author name to use when exporting a story. Each story can also override this setting
    (org-novelist-author-email "573@users.noreply.github.com")  ; The default author contact email to use when exporting a story. Each story can also override this setting
    (org-novelist-automatic-referencing-p nil))

;; if the last doesn't work, try
;; https://www.reddit.com/r/emacs/comments/t01efg/comment/iat14ob/?utm_source=share&utm_medium=web3x&utm_name=web3xcss&utm_term=1&utm_content=share_button
;; https://emacs.stackexchange.com/questions/70982/cursor-jumps-words-jumbled-emacs-in-terminal-via-iterm2-on-macos
;; https://emacs.stackexchange.com/questions/17085/undesirable-cursor-jump-after-movement-with-m-left-or-m-right-in-term-mode
(eval-after-load "term"
  '(progn
     ;; Fix forward/backward word when (term-in-char-mode).
     (define-key term-raw-map (kbd "<C-left>")
       (lambda () (interactive) (term-send-raw-string "\eb")))
     (define-key term-raw-map (kbd "<M-left>")
       (lambda () (interactive) (term-send-raw-string "\eb")))
     (define-key term-raw-map (kbd "<C-right>")
       (lambda () (interactive) (term-send-raw-string "\ef")))
     (define-key term-raw-map (kbd "<M-right>")
       (lambda () (interactive) (term-send-raw-string "\ef")))
     ;; Disable killing and yanking in char mode (term-raw-map).
     (mapc
      (lambda (func)
        (eval `(define-key term-raw-map [remap ,func]
                 (lambda () (interactive) (ding)))))
      '(backward-kill-paragraph
        backward-kill-sentence backward-kill-sexp backward-kill-word
        bookmark-kill-line kill-backward-chars kill-backward-up-list
        kill-forward-chars kill-line kill-paragraph kill-rectangle
        kill-region kill-sentence kill-sexp kill-visual-line
        kill-whole-line kill-word subword-backward-kill subword-kill
        yank yank-pop yank-rectangle))))

(add-to-list 'global-auto-revert-ignore-modes 'Buffer-menu-mode)
