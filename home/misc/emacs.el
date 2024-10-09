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

;; stolen from here:
;; https://github.com/minad/corfu?tab=readme-ov-file#configuration (example configuration)
(use-package corfu
  ;; Optional customizations
  ;; :custom
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

;; stolen here: https://blog.binchen.org/posts/autocomplete-with-a-dictionary-with-hippie-expand.html
;; Technical details
;;
;;    based on ac-ispell
;;    lazy load of ispell-mode to speed Emacs startup
;;    add a fallback dictionary "english-words.txt" so autocompletion never fails
;;    `ispell-lookup-words` or `lookup-words` simply does grep thing, so english-words.txt is just a plain text file.
;;(global-set-key (kbd "M-/") 'hippie-expand)

;; The actual expansion function
(defun try-expand-by-dict (old)
  ;; old is true if we have already attempted an expansion
  (unless (bound-and-true-p ispell-minor-mode)
    (ispell-minor-mode 1))

  ;; @scowl@/share/dict/words.txt is the fallback dicitonary
  (if (not ispell-alternate-dictionary)
      (setq ispell-alternate-dictionary (file-truename "@scowl@/share/dict/words.txt")))
  (let ((lookup-func (if (fboundp 'ispell-lookup-words)
                       'ispell-lookup-words
                       'lookup-words)))
    (unless old
      (he-init-string (he-lisp-symbol-beg) (point))
      (if (not (he-string-member he-search-string he-tried-table))
        (setq he-tried-table (cons he-search-string he-tried-table)))
      (setq he-expand-list
            (and (not (equal he-search-string ""))
                 (funcall lookup-func (concat (buffer-substring-no-properties (he-lisp-symbol-beg) (point)) "*")))))
    (if (null he-expand-list)
      (if old (he-reset-string))
      (he-substitute-string (car he-expand-list))
      (setq he-expand-list (cdr he-expand-list))
      t)
    ))

;;(setq hippie-expand-try-functions-list
;;      '(;; try-expand-dabbrev
;;        ;; try-expand-dabbrev-all-buffers
;;        try-expand-by-dict))
