;;
;; Set up the dictionary interface for emacs.
;; We may want to load this from dpmacs
;; The autoloads are already done by xemacs' auto-autoload
;;  in the package system.  yea packages.
;;

;;;###autoload
(defun dp-dictionary-mode-hook ()
  (local-set-key [(shift tab)] 'dictionary-prev-link)
  (local-set-key [(iso-left-tab)] 'dictionary-prev-link))

(require 'dictionary)

;;;###autoload


;;;###autoload
(dp-defaliases 'dds 'dictionary-search)
;;;###autoload
(dp-defaliases 'ddl 'ddlud 'dlu 'dld 'dictionary-lookup-definition)
(add-hook 'dictionary-mode-hook 'dp-dictionary-mode-hook)

(provide 'dp-dict)

