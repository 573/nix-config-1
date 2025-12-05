;;; -*- lexical-binding: t -*-

;; @out@
;; @scowl@/share/dict/words.txt
;; @hunspellDicts_de_DE@/share/hunspell/de_DE.aff
;; my legacy stolen configs https://github.com/573/nix-config-1/commit/b534362097b3ca0d4011561b1085de40df0a7292#diff-9038ab981032e7f24c7ee557adf7d2ea5fbb6702153e6242d80dc61b3e256051
(message "https://www.gnu.org/software/emacs/manual/html_node/efaq/Learning-how-to-do-something.html")
(message "configuration is %S" "templated from home/misc/emacs.el: @out@ see C-x b *Messages* for the real path of emacs.el")
(message "works")

;; ;;https://emacs.stackexchange.com/questions/27027/how-to-supply-ispell-program-with-dictionaries
 (setenv "LC_ALL" "de_DE.UTF-8")

 ;;(setenv "DICPATH"
 ;; (concat (getenv "HOMEDRIVE") (getenv "HOMEPATH") "");;)
 (setenv "LANG" "de_DE")

(set-face-attribute 'default nil
                    :family "Droid Sans Mono"
		    :width 'normal
		    :slant 'normal
                    :height 148
                    :weight 'regular
                    :width 'normal)
(copy-face 'default 'fixed-pitch)

(setq touch-screen-display-keyboard t)

(server-start)

;; (with-temp-buffer
;;   (insert-file-contents "/sdcard/wordlist-german.txt")
;; )

(use-package bind-key
  :demand t)

(use-package corfu
  :custom
   (corfu-auto t)                 ;; Enable auto completion
  :init
  (global-corfu-mode))

(use-package emacs
  :custom
  (tab-always-indent 'complete)
  (text-mode-ispell-word-completion nil)
  (read-extended-command-predicate #'command-completion-default-include-p))

(use-package cape
  ;;:pin localelpa
  ;;:after corfu
  ;; Bind prefix keymap providing all Cape commands under a mnemonic key.
  ;; Press C-c p ? to for help.
  :bind ("C-c p" . cape-prefix-map) ;; Alternative keys: M-p, M-+, ...
  :init
  (add-hook 'completion-at-point-functions #'cape-dabbrev)
  (add-hook 'completion-at-point-functions #'cape-file)
  (add-hook 'completion-at-point-functions #'cape-elisp-block)
  ;;(add-hook 'completion-at-point-functions #'cape-dict)
  
  :config ;; start emacs ; C-x b *scratch* ; start typing ; C-c p w should suggest from dictionary now
  ;;(setq cape-dict-file "/storage/3332-6135/wordlist-german.txt")
  ;;(setq cape-dict-grep nil)
  (setq dabbrev-case-replace nil)
  
(defun cape-dabbrev-keyword ()
  (cape-wrap-super #'cape-dabbrev #'cape-keyword))
  (setq-local completion-at-point-functions (list #'cape-dabbrev-keyword))
  )

;; https://stackoverflow.com/questions/683425/globally-override-key-binding-in-emacs/683575#683575
;; https://emacs.stackexchange.com/a/72045
;; https://lambdaland.org/posts/2022-12-27_repl_buffer_on_the_right/
;; https://www.masteringemacs.org/article/demystifying-emacs-window-manager#hiding-buffers
(add-to-list 'display-buffer-alist
             '("wordlist-german.txt"
               (display-buffer-no-window)
               (allow-no-window . t)))
(add-to-list 'display-buffer-alist
             '("count_1w.txt"
               (display-buffer-no-window)
               (allow-no-window . t)))
(global-set-key (kbd "C-c C-SPC C-d")
		(lambda ()
		(interactive)
(find-file "~/wordlist-german.txt")))
(global-set-key (kbd "C-c C-SPC C-e")
		(lambda ()
		  (interactive)
;; https://github.com/karthink/.emacs.d/blob/25a0aec771c38e340789d7c304f3e39ff23aee3e/lisp/setup-corfu.el#L162
  ;; Use Peter Norvig's 300,000 most used English words as the word list
;;(shell-command (concat "sed -re 's_[ \t0-9]*__g' -i " "/sdcard/count_1w.txt"))
		  (find-file "~/count_1w.txt")))

(global-set-key (kbd "C-c C-d e")
		(lambda ()
		  (interactive)
		  (find-file user-init-file)))

(use-package gcmh
  :ensure t
  :diminish
  :init (setq gc-cons-threshold most-positive-fixnum)
  :hook (emacs-startup . gcmh-mode)
  :custom
  (gcmh-idle-delay 'auto)
  (gcmh-auto-idle-delay-factor 10)
  (gcmh-high-cons-threshold (* 16 1024 1024)))

;; read about what does here https://christiantietze.de/posts/2020/05/delete-word-or-region-emacs/
(defun ct/kill-word (arg)
  "Kill characters forward until encountering the end of a word, or the current selection."
  (interactive "p")
  (if (use-region-p)
      (delete-active-region 'kill)
      (kill-word arg)))
(global-set-key (kbd "M-d") 'ct/kill-word)

;; https://emacs.stackexchange.com/questions/461/configuration-of-eshell-running-programs-from-directories-in-path-env-variable
;;(add-to-list 'exec-path "/data/data/org.gnu.emacs/files/bin")

;; /storage/3332-6135/Download/org-novelist/
   ;; https://github.com/KarimAziev/atomic-chrome?#manual-installation
;;(add-to-list 'load-path "/storage/3332-6135/Download/org-novelist/")
;;(require 'org-novelist)

;;(use-package  org-novelist
;;  :ensure nil
  ;;  :load-path "~/Downloads/"  ; The directory containing 'org-novelist.el'
;;  :custom
  ;; Setting de-DE leads to subtle errors (no localised files)
;;  (org-novelist-language-tag "en-GB")  ; The interface language for Org Novelist to use. It defaults to 'en-GB' when not set
;;  (org-novelist-author "Daniel Kahlenberg")  ; The default author name to use when exporting a story. Each story can also override this setting
;;  (org-novelist-author-email "573@users.noreply.github.com")  ; The default author contact email to use when exporting a story. Each story can also override this setting
;;  (org-novelist-automatic-referencing-p nil))

(add-hook 'org-mode-hook (lambda ()
			   (setq truncate-lines nil)))


     ;; Remember that the website version of this manual shows the latest
     ;; developments, which may not be available in the package you are
     ;; using.  Instead of copying from the web site, refer to the version
     ;; of the documentation that comes with your package.  Evaluate:
     ;;
     ;;     (info "(denote) Sample configuration")
     (use-package denote
       :ensure t
       :hook (dired-mode . denote-dired-mode)
       :bind
       (("C-c n n" . denote)
        ("C-c n r" . denote-rename-file)
        ("C-c n l" . denote-link)
        ("C-c n b" . denote-backlinks)
        ("C-c n d" . denote-dired)
        ("C-c n g" . denote-grep))
       :config
       (setq denote-directory (expand-file-name "~/zettelkasten"))
       
       ;; Automatically rename Denote buffers when opening them so that
       ;; instead of their long file name they have, for example, a literal
       ;; "[D]" followed by the file's title.  Read the doc string of
       ;; `denote-rename-buffer-format' for how to modify this.
       (denote-rename-buffer-mode 1))

(auto-save-visited-mode 1)
(setq auto-save-visited-interval 30
      denote-save-buffer-after-creation t
      ;; C-h v RET grep-template
       )

;; https://github.com/Genivia/ugrep?tab=readme-ov-file#using-ugrep-within-emacs
(with-eval-after-load 'xref
  ;; https://stackoverflow.com/questions/9812393/elisp-how-to-delete-an-element-from-an-association-list-with-string-key#comment12499293_9812393
  (setq xref-search-program-alist (assq-delete-all 'grep xref-search-program-alist))
 (push '(grep . "xargs -0 grep <C> -snHE -e <R>")
       xref-search-program-alist)
 (setq-default xref-search-program 'grep))


;; (use-package doom-modeline
;;   :ensure t
;;   :init (doom-modeline-mode 1))

;; (use-package doom-themes
;;   :ensure t
;;   :config
;;   ;; Global settings (defaults)
;;   (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
;;         doom-themes-enable-italic t) ; if nil, italics is universally disabled
;;   (load-theme 'doom-fairy-floss t)

;;   ;; Enable flashing mode-line on errors
;;   (doom-themes-visual-bell-config)
;;   ;; Enable custom neotree theme (nerd-icons must be installed!)
;;   (doom-themes-neotree-config)
;;   ;; or for treemacs users
;;   (setq doom-themes-treemacs-theme "doom-atom") ; use "doom-colors" for less minimal icon theme
;;   (doom-themes-treemacs-config)
;;   ;; Corrects (and improves) org-mode's native fontification.
;;   (doom-themes-org-config))

;; (use-package moe-theme
;;   :init
;;   ;; Show highlighted buffer-id as decoration. (Default: nil)
;;   (setq moe-theme-highlight-buffer-id t)

;;   ;; Resize titles (optional).
;;   (setq moe-theme-resize-markdown-title '(1.5 1.4 1.3 1.2 1.0 1.0))
;;   (setq moe-theme-resize-org-title '(1.5 1.4 1.3 1.2 1.1 1.0 1.0 1.0 1.0))
;;   (setq moe-theme-resize-rst-title '(1.5 1.4 1.3 1.2 1.1 1.0))

;;   ;; Highlight Buffer-id on Mode-line
;;   (setq moe-theme-highlight-buffer-id nil)

;;   ;; Choose a color for mode-line.(Default: blue)
;;   (setq moe-theme-set-color 'cyan)

;;   (load-theme 'moe-light t))

;;(use-package pink-bliss-uwu-theme
;;  :config
;;  (load-theme 'pink-bliss-uwu t))

(use-package nyan-mode
  :config
  (setq nyan-minimum-window-width 0))
(nyan-mode)

(set-register ?e (cons 'file user-init-file))
;;(set-register ?d (cons 'file "/storage/emulated/0/zettelkasten/"))
;;(set-register ?a (cons 'file "/storage/emulated/0/"))
(add-to-list 'default-frame-alist
             '(font . "Monaspace Radon Var 16"))

;;(use-package vundo)

(global-set-key (kbd "C-c d s") #'deadgrep)

;; I'm so used to zetteldeft's keybindings
;; have to rewrite them to denote commands
(global-set-key (kbd "C-c d n") #'denote)

;; instead of org-protocol when on android
(global-set-key (kbd "C-x p i") #'org-cliplink)

;;(global-set-key (kbd "C-c o n") #'org-novelist)

;;(global-set-key (kbd "C-c o n")
;;		(lambda () (interactive)
;;		  (org-novelist-mode)))

;; C-h i g (denote-silo)
     (use-package denote-silo
       :ensure t
       ;; Bind these commands to key bindings of your choice.
       :commands ( denote-silo-create-note
                   denote-silo-open-or-create
                   denote-silo-select-silo-then-command
                   denote-silo-dired
                   denote-silo-cd )
       :bind
       (("C-c n n" . denote-silo-create-note)
        ("C-c n o" . denote-silo-open-or-create)
        ("C-c n t" . denote-silo-select-silo-then-command)
        ("C-c n d" . denote-silo-dired)
        ("C-c n c" . denote-silo-cd))
       :config
       ;; Add your silos to this list.  By default, it only includes the
       ;; value of the variable `denote-directory'.
       (setq denote-silo-directories
             (list denote-directory
		   ;;                   "/storage/emulated/0/worknotes"
		   )))

(global-set-key (kbd "<f5>") #'deadgrep)

;; https://stackoverflow.com/a/78838107/3320256
(add-hook 'dired-mode-hook (lambda () (dired-hide-details-mode 1)))
(add-hook 'dired-mode-hook (lambda () (dired-omit-mode 1)))


;; see https://www.gnu.org/software/emacs/manual/html_node/elisp/Defining-Functions.html
(defun foofoo () "my zettelkasten" (interactive)
       ;; see https://emacs.stackexchange.com/questions/50737/force-opening-file-in-new-buffer
       (let* ((buf (create-file-buffer "zettelkasten")))
	 (with-current-buffer buf 
       (find-alternate-file (expand-file-name "zettelkasten" (getenv "HOME")))
       (forward-page)))
       )
;; see https://www.gnu.org/software/emacs/manual/html_node/elisp/Standard-Hooks.html (via https://emacs.stackexchange.com/a/15099)
(add-hook 'window-setup-hook #'foofoo)

;; https://org-roam.discourse.group/t/opening-internal-links-in-the-same-window-frame/542
;; https://emacs.stackexchange.com/questions/62720/open-org-link-in-the-same-window
;; FIXME does not work in non-nixos full-nix-managed emacs
(add-to-list 'org-link-frame-setup '(file . find-file))

