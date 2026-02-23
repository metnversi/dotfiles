;; global emacs configuration files
;; edited from https://github.com/rexim/dotfiles/blob/master/.emacs
;; to suit personal use

(setq custom-file "~/.emacs.custom.el")
(package-initialize)
(add-to-list 'load-path "~/.emacs.local/")
(load "~/.emacs.rc/rc.el")
(load "~/.emacs.rc/misc-rc.el")
(load "~/.emacs.rc/org-mode-rc.el")
(load "~/.emacs.rc/autocommit-rc.el")

(defun rc/get-default-font ()
  (cond
   ((eq system-type 'darwin) "Iosevka Nerd Font-14:weight=bold")
   ((eq system-type 'gnu/linux) "Iosevka Nerd Font-14:weight=bold")
   )
  )
(add-to-list 'default-frame-alist `(font . ,(rc/get-default-font)))

;; Remove unnecessary bar, add line number
(tool-bar-mode 0)
(menu-bar-mode 0)
(scroll-bar-mode -1)
(column-number-mode 1)
(show-paren-mode 1)

(rc/require-theme 'gruber-darker)

(require 'project)
(require 'generic-x)

(rc/require 'smex 'ido-completing-read+)
(ido-mode 1)
(ido-everywhere 1)
(ido-ubiquitous-mode 1)
(electric-pair-mode 1)
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

;; neotree, nerd icons
(rc/require 'neotree)
(global-set-key [f8] 'neotree-toggle)
(rc/require 'nerd-icons)
(setq neo-theme (if (display-graphic-p) 'icons 'nerd-icons))
(setq confirm-kill-emacs nil)
(setq vc-follow-symlinks t)

;;; Emacs lisp
(add-hook 'emacs-lisp-mode-hook
          '(lambda ()
             (local-set-key (kbd "C-c C-j")
                            (quote eval-print-last-sexp))))
(add-to-list 'auto-mode-alist '("Cask" . emacs-lisp-mode))

(require 'basm-mode)
(require 'fasm-mode)
(add-to-list 'auto-mode-alist '("\\.asm\\'" . fasm-mode))

;;(require 'porth-mode)
(require 'noq-mode)
(require 'jai-mode)
(require 'c3-mode)
;;(require 'simpc-mode)
;;(add-to-list 'auto-mode-alist '("\\.[hc]\\(pp\\)?\\'" . simpc-mode))

(require 'conf-mode)
;; (defun my/use-conf-mode-for-unknown-extensions ()
;;   "If buffer is in fundamental-mode due to unknown file extension, switch to conf-mode."
;;   (when (and buffer-file-name
;;              (eq major-mode 'fundamental-mode)
;;              (let ((ext (file-name-extension buffer-file-name)))
;;                (or (not ext) ;; no extension -> conf-mode anyway
;;                    t)))
;;     (conf-mode)))
;;
;; (add-hook 'find-file-hook #'my/use-conf-mode-for-unknown-extensions)

;;; Whitespace mode
(defun rc/set-up-whitespace-handling ()
  (interactive)
  (whitespace-mode 1)
  (add-to-list 'write-file-functions 'delete-trailing-whitespace))

;;; display-line-numbers-mode
(when (version<= "26.0.50" emacs-version)
  (global-display-line-numbers-mode))

;; paredit for parentheses navigation
(rc/require 'paredit)
(defun rc/turn-on-paredit ()
  (interactive)
  (paredit-mode 1))
(add-hook 'emacs-lisp-mode-hook  'rc/turn-on-paredit)
(add-hook 'clojure-mode-hook     'rc/turn-on-paredit)
(add-hook 'lisp-mode-hook        'rc/turn-on-paredit)
(add-hook 'common-lisp-mode-hook 'rc/turn-on-paredit)
(add-hook 'scheme-mode-hook      'rc/turn-on-paredit)

;;; magit
(rc/require 'cl-lib)
(rc/require 'magit)
(setq magit-auto-revert-mode nil)
(setq magit-log-arguments '("--graph" "--decorate" "--color"))
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

;;; dired-x
(require 'dired-x)
(setq dired-omit-files
      (concat dired-omit-files "\\|^\\..+$"))
(setq-default dired-dwim-target t)
(setq dired-listing-switches "-alh")
(setq dired-mouse-drag-files t)

;;; helm
(rc/require 'helm 'helm-ls-git)
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

(rc/require 'powershell)
(add-to-list 'auto-mode-alist '("\\.ps1\\'" . powershell-mode))
(add-to-list 'auto-mode-alist '("\\.psm1\\'" . powershell-mode))

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

(rc/require 'move-text)
(global-set-key (kbd "M-p") 'move-text-up)
(global-set-key (kbd "M-n") 'move-text-down)

(add-to-list 'auto-mode-alist '("\\.ebi\\'" . lisp-mode))

(rc/require
 'scala-mode
 'yaml-mode
 'lua-mode
 'less-css-mode
 'graphviz-dot-mode
 'cmake-mode
 'rust-mode
 'csharp-mode
 'jinja2-mode
 'markdown-mode
 'nix-mode
 'dockerfile-mode
 'toml-mode
 'nginx-mode
 'go-mode
 'php-mode
 'qml-mode
 'ag
 'elpy
 ;;'typescript-mode
 ;;'glsl-mode
 ;;'tuareg
 ;;'sml-mode
 ;;'d-mode
 ;;'racket-mode
 ;;'kotlin-mode
 ;;'purescript-mode
 ;;'nim-mode
 ;;'clojure-mode
 'rfc-mode
 'systemd
 'vimrc-mode
 )

;; NOTE: I use mixed of both lsp and eglot
(use-package lsp-mode
  :ensure t
  :hook  (
	      (yaml-mode . lsp)
          (sh-mode . lsp)
          (terraform-mode . lsp-deferred)
          (markdown-mode . lsp-deferred)
          (go-mode . lsp-deferred)
          )
  :commands lsp lsp-deferred
  :config
  (setq lsp-clients-clangd-args
        '("--header-insertion=never" "--background-index"))
  (setq lsp-prefer-capf t)
  )

;; (use-package terraform-mode
;;   :ensure t
;;   :mode ("\\.tf\\'" . terraform-mode)
;;   :hook (terraform-mode . lsp-deferred))

(rc/require 'eglot)
(require 'eglot)
(add-to-list 'eglot-server-programs '((c++-mode c-mode) "clangd"))
(add-hook 'c-mode-hook 'eglot-ensure)
(add-hook 'c++-mode-hook 'eglot-ensure)
(setq eglot-ignored-server-capabilities '(:inlayHintProvider))

;; go mode specific
(defun project-find-go-module (dir)
  (when-let ((root (locate-dominating-file dir "go.mod")))
    (cons 'go-module root)))
(cl-defmethod project-root ((project (head go-module)))
  (cdr project))
(add-hook 'project-find-functions #'project-find-go-module)

(load "~/.emacs.shadow/shadow-rc.el" t)

(use-package elpy
  :ensure t
  :init
  (elpy-enable))

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
compilation-error-regexp-alist-alist
(add-to-list 'compilation-error-regexp-alist
             '("\\([a-zA-Z0-9\\.]+\\)(\\([0-9]+\\)\\(,\\([0-9]+\\)\\)?) \\(Warning:\\)?"
               1 2 (4) (5)))

(defun my-yaml-highlights ()
  "Custom highlights for YAML mode only."
  (face-remap-add-relative 'font-lock-variable-name-face '(:foreground "cyan"))
  (face-remap-add-relative 'font-lock-constant-face '(:foreground "cyan")))
(add-hook 'yaml-mode-hook #'my-yaml-highlights)

(custom-set-faces
 '(default ((t (:background "#000000" :foreground "#ffffff"))))
 '(yaml-tab-face ((t (:foreground "cyan"))))
 '(line-number ((t (:foreground "#5c6370"))))
 '(line-number-current-line ((t (:foreground "#a83264" :weight bold))))
 '(magit-diff-removed ((t (:background "#3d0000" :foreground "#ff8888"))))
 '(magit-diff-removed-highlight ((t (:background "#550000" :foreground "#ffaaaa"))))
 '(magit-diff-added ((t (:background "#002200" :foreground "#88ff88"))))
 '(magit-diff-added-highlight ((t (:background "#004400" :foreground "#aaffaa"))))
 )

(setq display-line-numbers-type 'relative)
(setq elpy-rpc-virtualenv-path "~/.dev")

(rc/require 'pdf-tools)
(setq pdf-info-restart-process-p t)
(pdf-tools-install t)
(pdf-loader-install)
(add-hook 'pdf-view-mode-hook (lambda () (display-line-numbers-mode -1)))

(load-file custom-file)
