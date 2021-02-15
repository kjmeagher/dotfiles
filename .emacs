
(add-to-list 'load-path "~/.emacs.d/lisp/")
(require 'meson-mode)
(require 'highlight-chars)	
(add-hook 'font-lock-mode-hook 'hc-highlight-tabs)
(setq column-number-mode t)
(global-set-key (kbd "C-x C-b") 'bs-show)
(setq-default indent-tabs-mode nil)

(set-face-attribute 'default nil :family "Hack" :height 145 :weight 'normal)
(load-theme 'manoj-dark)
