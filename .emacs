(require 'package)
(add-to-list 'package-archives
                         '("melpa" . "https://melpa.org/packages/") t)

;; Initialize the package system if it's not already done
(unless (bound-and-true-p package--initialized) 
  (setq package-enable-at-startup nil) 
  (package-initialize))

(unless package-archive-contents
  (package-refresh-contents))

(unless (package-installed-p 'use-package)
    (package-install 'use-package))

(eval-and-compile
  (setq use-package-always-ensure t))


;;remove welcome screen and menu bar
(setq inhibit-startup-screen t)
(menu-bar-mode -1)
(tool-bar-mode -1)

(setq x-select-enable-clipboard t)
(setq x-select-enable-primary t)
(setq save-interprogram-paste-before-kill t)
(setq yank-pop-change-selection t)

;; Enable ido mode
(setq ido-enable-flex-matching t)
(setq ido-everywhere t)
(ido-mode 1)

;;line number green
(set-face-attribute 'line-number-current-line nil
                    :foreground "green")


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

;; Enable electric pair mode
(electric-pair-mode 1)
;; Bind C-= to zoom in
(global-set-key (kbd "C-=") 'text-scale-increase)

;; Bind C-- to zoom out
(global-set-key (kbd "C--") 'text-scale-decrease)

(add-hook 'prog-mode-hook #'hs-minor-mode)
;; helm
;;(rc/require 'helm 'helm-cmd-t 'helm-git-grep 'helm-ls-git)

;;(setq helm-ff-transformer-show-only-basename nil)

;;(global-set-key (kbd "C-c h t") 'helm-cmd-t)
;;(global-set-key (kbd "C-c h g g") 'helm-git-grep)
;;(global-set-key (kbd "C-c h g l") 'helm-ls-git-ls)
;;(global-set-key (kbd "C-c h f") 'helm-find)
;;(global-set-key (kbd "C-c h a") 'helm-org-agenda-files-headings)
;;(global-set-key (kbd "C-c h r") 'helm-recentf)

;
;; Install and configure evil-collection
;; for vim mode, switch using ESC key :)
 (use-package evil-collection
  :after evil
  :config
  (evil-collection-init))

(use-package dracula-theme
  :ensure t
  :config
  (load-theme 'dracula t)
  (run-with-idle-timer
   0 nil
   (lambda () (custom-theme-set-faces
               'dracula
               `(default ((t (:background "black"))))))))



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

(global-set-key (kbd "<f5>") '(lambda () (interactive) (revert-buffer nil t t)))


(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(avy dracula-theme use-package smex paredit org-cliplink multiple-cursors magit ido-completing-read+ helm haskell-mode gruber-darker-theme dash-functional)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )
