(require 'package)
(add-to-list 'package-archives
                         '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)
(unless package-archive-contents
    (package-refresh-contents))
(unless (package-installed-p 'use-package)
    (package-install 'use-package))
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
(set-face-attribute 'line-number-current-line nil
                    :foreground "green")

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

