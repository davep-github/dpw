;;
;; Set up the dictionary interface for emacs.
;; We may want to load this from dpmacs
;; The autoloads are already done by xemacs' auto-autoload
;;  in the package system.  yea packages.
;;

(defun dp-dictionary-mode-hook ()
  (local-set-key [(shift tab)] 'dictionary-prev-link)
  (local-set-key [(iso-left-tab)] 'dictionary-prev-link))

(require 'dictionary)

(defalias 'dsd 'dictionary-search)
(defalias 'dld 'dictionary-lookup-definition)
(add-hook 'dictionary-mode-hook 'dp-dictionary-mode-hook)

