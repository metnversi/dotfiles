(require 'package)
(add-to-list 'package-archives
                         '("melpa" . "https://melpa.org/packages/") t)

;; Initialize the package system if it's not already done
(unless (bound-and-true-p package--initialized) ; Don't do this if it's already done
  (setq package-enable-at-startup nil) ; Prevent double loading of libraries
  (package-initialize))
(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
    (package-install 'use-package))
(eval-and-compile
  (setq use-package-always-ensure t))
(custom-set-variables
 '(package-selected-packages
   '(avy dracula-theme use-package smex paredit org-cliplink multiple-cursors magit ido-completing-read+ helm haskell-mode gruber-darker-theme dash-functional)))
(custom-set-faces)

;;remove welcome screen and menu bar
(setq inhibit-startup-screen t)
(menu-bar-mode -1)

(setq x-select-enable-clipboard t)
(setq x-select-enable-primary t)
(setq save-interprogram-paste-before-kill t)
(setq yank-pop-change-selection t)
;;line number green
(set-face-attribute 'line-number-current-line nil
                    :foreground "green")
;; Install and configure evil
(use-package evil
  :init
  (setq evil-want-integration t) ;; This is optional since it's already set to t by default.
  (setq evil-want-keybinding nil)
  :config
  (evil-mode 1))

;; Install and configure helm, for auto suggest finding file.
(use-package helm
  :init
  (setq helm-mode-fuzzy-match t
    helm-completion-in-region-fuzzy-match t)
  :bind (("M-x" . helm-M-x)
     ("C-x r b" . helm-filtered-bookmarks)
     ("C-x C-f" . helm-find-files))
  :config
  (helm-mode 1))

;; Install and configure evil-collection
;; for vim mode, switch using ESC key :)
(use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package dracula-theme
    :ensure t
    :config
    (load-theme 'dracula t))
(use-package avy
    :ensure t
    :bind ("M-g" . avy-goto-line))

(setq-default display-line-numbers 'visual)
(setq-default display-line-numbers-widen t)
(setq display-line-numbers-type 'relative)

(defun jump-relative (line)
    "Jump to a line relative to the current line."
    (interactive "nLine offset: ")
    (forward-line line))
(global-set-key (kbd "C-c j") 'jump-relative)

(dotimes (i 10)
    (global-set-key (kbd (format "C-q %d" i)) (lambda () (interactive) (forward-line (- i)))))
(dotimes (i 10)
    (global-set-key (kbd (format "C-q -%d" i)) (lambda () (interactive) (forward-line i))))

