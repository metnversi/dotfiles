;; This is modified version of tsoding's one
;;

(setq custom-file "~/.emacs.custom.el")
(package-initialize)

(add-to-list 'load-path "~/.emacs.local/")

(load "~/.emacs.rc/rc.el")
(load "~/.emacs.rc/misc-rc.el")
(load "~/.emacs.rc/org-mode-rc.el")
(load "~/.emacs.rc/autocommit-rc.el")

;;; Appearance
(defun rc/get-default-font ()
  (cond
   ((eq system-type 'gnu/linux) "Iosevka Nerd Font-20")))

(add-to-list 'default-frame-alist `(font . ,(rc/get-default-font)))

(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode 0)
(column-number-mode 1)
(show-paren-mode 1)

;;(rc/require-theme 'gruber-darker)
(rc/require-theme 'molokai)
;; (rc/require-theme 'zenburn)
;; (load-theme 'adwaita t)
;; (eval-after-load 'zenburn
;;  (set-face-attribute 'line-number nil :inherit 'default))
;; Set relative line number color
(custom-set-faces
 '(line-number ((t (:foreground "#5c6370"))))  
 '(line-number-current-line ((t (:foreground "#a83264" :weight bold))))) 

(use-package lsp-mode
  :ensure t
  :hook ((terraform-mode . lsp-deferred)))

(use-package terraform-mode
  :ensure t
  :mode ("\\.tf\\'" . terraform-mode)
  :hook (terraform-mode . lsp-deferred))

(unless (package-installed-p 'vimrc-mode)
    (package-refresh-contents)
    (package-install 'vimrc-mode))

(load-theme 'molokai t)
(set-face-attribute 'default nil :background "#000000" :foreground "#ffffff")
(set-face-background 'default "#000000")

;;; ido
(rc/require 'smex 'ido-completing-read+)

(require 'ido-completing-read+)

(ido-mode 1)
(ido-everywhere 1)
(ido-ubiquitous-mode 1)

(global-set-key (kbd "M-x") 'smex)
(global-set-key (kbd "C-c C-c M-x") 'execute-extended-command)

;;; c-mode
(setq-default c-basic-offset 4
              c-default-style '((java-mode . "java")
                                (awk-mode . "awk")
                                (other . "bsd")))

(add-hook 'c-mode-hook (lambda ()
                         (interactive)
                         (c-toggle-comment-style -1)))

;;;neotree
;;(add-to-list 'load-path "~/.emacs.d/neotree")
(rc/require 'neotree)
(global-set-key [f8] 'neotree-toggle)
(rc/require 'nerd-icons)
(setq neo-theme (if (display-graphic-p) 'icons 'nerd-icons))

;;; Paredit
(rc/require 'paredit)
(defun rc/turn-on-paredit ()
  (interactive)
  (paredit-mode 1))
(rc/require 'toml-mode)
;;; No confirmation if quit emacs/follow symlinks
(setq confirm-kill-emacs nil)
(setq vc-follow-symlinks t)

(add-hook 'emacs-lisp-mode-hook  'rc/turn-on-paredit)
(add-hook 'clojure-mode-hook     'rc/turn-on-paredit)
(add-hook 'lisp-mode-hook        'rc/turn-on-paredit)
(add-hook 'common-lisp-mode-hook 'rc/turn-on-paredit)
(add-hook 'scheme-mode-hook      'rc/turn-on-paredit)
(add-hook 'racket-mode-hook      'rc/turn-on-paredit)

;;; Emacs lisp
(add-hook 'emacs-lisp-mode-hook
          '(lambda ()
             (local-set-key (kbd "C-c C-j")
                            (quote eval-print-last-sexp))))
(add-to-list 'auto-mode-alist '("Cask" . emacs-lisp-mode))

;;; uxntal-mode
(rc/require 'uxntal-mode)

;;; Haskell mode
(rc/require 'haskell-mode)
(setq haskell-process-type 'cabal-new-repl)
(setq haskell-process-log t)

(add-hook 'haskell-mode-hook 'haskell-indent-mode)
(add-hook 'haskell-mode-hook 'interactive-haskell-mode)
(add-hook 'haskell-mode-hook 'haskell-doc-mode)

(require 'basm-mode)

(require 'fasm-mode)
(add-to-list 'auto-mode-alist '("\\.asm\\'" . fasm-mode))

(require 'porth-mode)
(require 'noq-mode)
(require 'jai-mode)
(require 'simpc-mode)
(add-to-list 'auto-mode-alist '("\\.[hc]\\(pp\\)?\\'" . simpc-mode))
(require 'c3-mode)

(require 'conf-mode)
(defun my/use-conf-mode-for-unknown-extensions ()
  "If buffer is in `fundamental-mode' due to unknown file extension,
switch to `conf-mode`."
  (when (and buffer-file-name
             (eq major-mode 'fundamental-mode)
             (let ((ext (file-name-extension buffer-file-name)))
               (or (not ext) ;; no extension -> conf-mode anyway
                   t)))
    (conf-mode)))

(add-hook 'find-file-hook #'my/use-conf-mode-for-unknown-extensions)

;;; Whitespace mode
(defun rc/set-up-whitespace-handling ()
  (interactive)
  (whitespace-mode 1)
  (add-to-list 'write-file-functions 'delete-trailing-whitespace))

;;(add-hook 'tuareg-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'c++-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'c-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'simpc-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'emacs-lisp-mode 'rc/set-up-whitespace-handling)
;;(add-hook 'java-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'lua-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'rust-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'scala-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'markdown-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'haskell-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'python-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'erlang-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'asm-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'fasm-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'go-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'nim-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'yaml-mode-hook 'rc/set-up-whitespace-handling)
;;(add-hook 'porth-mode-hook 'rc/set-up-whitespace-handling)

(use-package ivy
  :ensure t
  :init (ivy-mode 1))

(use-package counsel
  :ensure t)
(global-set-key (kbd "C-c b") 'counsel-switch-buffer)

;;; display-line-numbers-mode
(when (version<= "26.0.50" emacs-version)
  (global-display-line-numbers-mode))

;;; magit
(rc/require 'cl-lib)
(rc/require 'magit)
(setq magit-auto-revert-mode nil)

(global-set-key (kbd "C-c m s") 'magit-status)
(global-set-key (kbd "C-c m l") 'magit-log)

;;; multiple cursors
(rc/require 'multiple-cursors)

(global-set-key (kbd "C-S-c C-S-c") 'mc/edit-lines)
(global-set-key (kbd "C->")         'mc/mark-next-like-this)
(global-set-key (kbd "C-<")         'mc/mark-previous-like-this)
(global-set-key (kbd "C-c C-<")     'mc/mark-all-like-this)
(global-set-key (kbd "C-\"")        'mc/skip-to-next-like-this)
(global-set-key (kbd "C-:")         'mc/skip-to-previous-like-this)

;;; dired
(require 'dired-x)
(setq dired-omit-files
      (concat dired-omit-files "\\|^\\..+$"))
(setq-default dired-dwim-target t)
(setq dired-listing-switches "-alh")
(setq dired-mouse-drag-files t)

;;; helm
(rc/require 'helm 'helm-git-grep 'helm-ls-git)

(setq helm-ff-transformer-show-only-basename nil)

(global-set-key (kbd "C-c h t") 'helm-cmd-t)
(global-set-key (kbd "C-c h g g") 'helm-git-grep)
(global-set-key (kbd "C-c h g l") 'helm-ls-git-ls)
(global-set-key (kbd "C-c h f") 'helm-find)
(global-set-key (kbd "C-c h a") 'helm-org-agenda-files-headings)
(global-set-key (kbd "C-c h r") 'helm-recentf)

;;; yasnippet
(rc/require 'yasnippet)

(require 'yasnippet)

(setq yas/triggers-in-field nil)
(setq yas-snippet-dirs '("~/.emacs.snippets/"))

(yas-global-mode 1)

;;; word-wrap
(defun rc/enable-word-wrap ()
  (interactive)
  (toggle-word-wrap 1))

(add-hook 'markdown-mode-hook 'rc/enable-word-wrap)

;;; nxml
(add-to-list 'auto-mode-alist '("\\.html\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.xsd\\'" . nxml-mode))
(add-to-list 'auto-mode-alist '("\\.ant\\'" . nxml-mode))

;;; tramp
;;; http://stackoverflow.com/questions/13794433/how-to-disable-autosave-for-tramp-buffers-in-emacs
(setq tramp-auto-save-directory "/tmp")

;;; powershell
(rc/require 'powershell)
(add-to-list 'auto-mode-alist '("\\.ps1\\'" . powershell-mode))
(add-to-list 'auto-mode-alist '("\\.psm1\\'" . powershell-mode))

;;; eldoc mode
(defun rc/turn-on-eldoc-mode ()
  (interactive)
  (eldoc-mode 1))

(add-hook 'emacs-lisp-mode-hook 'rc/turn-on-eldoc-mode)

;;; Company
(rc/require 'company)
(require 'company)

(global-company-mode)

(add-hook 'tuareg-mode-hook
          (lambda ()
            (interactive)
            (company-mode 0)))

;;; Typescript
;;(rc/require 'typescript-mode)
;;(add-to-list 'auto-mode-alist '("\\.mts\\'" . typescript-mode))

;;; Tide
(rc/require 'tide)

(defun rc/turn-on-tide-and-flycheck ()  ;Flycheck is a dependency of tide
  (interactive)
  (tide-setup)
  (flycheck-mode 1))

(add-hook 'typescript-mode-hook 'rc/turn-on-tide-and-flycheck)

;;; Proof general
(rc/require 'proof-general)
(add-hook 'coq-mode-hook
          '(lambda ()
             (local-set-key (kbd "C-c C-q C-n")
                            (quote proof-assert-until-point-interactive))))

;;; LaTeX mode
(add-hook 'tex-mode-hook
          (lambda ()
            (interactive)
            (add-to-list 'tex-verbatim-environments "code")))

(setq font-latex-fontify-sectioning 'color)

;;; Move Text
(rc/require 'move-text)
(global-set-key (kbd "M-p") 'move-text-up)
(global-set-key (kbd "M-n") 'move-text-down)

;;; Ebisp
(add-to-list 'auto-mode-alist '("\\.ebi\\'" . lisp-mode))

;;; Packages that don't require configuration
(rc/require
 'scala-mode
 'd-mode
 'yaml-mode
 'glsl-mode
 'tuareg
 'lua-mode
 'less-css-mode
 'graphviz-dot-mode
 'clojure-mode
 'cmake-mode
 'rust-mode
 'csharp-mode
 'nim-mode
 'jinja2-mode
 'markdown-mode
 'purescript-mode
 'nix-mode
 'dockerfile-mode
 'toml-mode
 'nginx-mode
 'kotlin-mode
 'go-mode
 'php-mode
 'racket-mode
 'qml-mode
 'ag
 'elpy
 'typescript-mode
 'rfc-mode
 'sml-mode
 )

(load "~/.emacs.shadow/shadow-rc.el" t)

(defun astyle-buffer (&optional justify)
  (interactive)
  (let ((saved-line-number (line-number-at-pos)))
    (shell-command-on-region
     (point-min)
     (point-max)
     "astyle --style=kr"
     nil
     t)
    (goto-line saved-line-number)))

(add-hook 'simpc-mode-hook
          (lambda ()
            (interactive)
            (setq-local fill-paragraph-function 'astyle-buffer)))

(require 'compile)

;;mail
;;(add-to-list 'load-path "~/.emacs.d/epla/mu4e") ;; adjust path as needed
;;(require 'mu4e)
;;(setq
;; mu4e-maildir       "~/Mail/gmail"
;; mu4e-get-mail-command "mbsync gmail"
;; mu4e-update-interval 300
;; mu4e-view-show-images t
;; mu4e-view-show-addresses t
;; user-mail-address "nguyenthevinh2002.xuantruong@gmail.com"
;; user-full-name  "Vinh Nguyen"
;; mu4e-sent-folder   "/[Gmail]/Sent Mail"
;; mu4e-drafts-folder "/[Gmail]/Drafts"
;; mu4e-trash-folder  "/[Gmail]/Trash"
;; mu4e-refile-folder "/[Gmail]/All Mail")
;;(setq message-send-mail-function 'smtpmail-send-it
;;      smtpmail-stream-type 'starttls
;;      smtpmail-default-smtp-server "smtp.gmail.com"
;;      smtpmail-smtp-server "smtp.gmail.com"
;;      smtpmail-smtp-service 587
;;      smtpmail-auth-credentials '(("smtp.gmail.com" 587 "nguyenthevinh2002.xuantruong@gmail.com" nil)))

;; pascalik.pas(24,44) Error: Can't evaluate constant expression

compilation-error-regexp-alist-alist

(add-to-list 'compilation-error-regexp-alist
             '("\\([a-zA-Z0-9\\.]+\\)(\\([0-9]+\\)\\(,\\([0-9]+\\)\\)?) \\(Warning:\\)?"
               1 2 (4) (5)))

(load-file custom-file)
