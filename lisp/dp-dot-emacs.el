;;;
;;; XEmacs backwards compatibility file
;;; $Id: dp-dot-emacs.el,v 1.22 2002/06/24 07:30:12 davep Exp $ 
;;;  ~/.emacs --> dp-dot-emacs.el (this file)
;;;
(message "in dp-dot-emacs.el")
(setq user-init-file
      (expand-file-name "init.el"
			(expand-file-name ".xemacs" "~")))
(setq custom-file
      (expand-file-name "custom.el"
			(expand-file-name ".xemacs" "~")))

(load-file user-init-file)
(dmessage "post user-init-file: tramp-auto-save-directory>%s<" tramp-auto-save-directory)

(load-file custom-file)
(dmessage "post custom-file: tramp-auto-save-directory>%s<" tramp-auto-save-directory)

