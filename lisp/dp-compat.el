;;;
;;; $Id: dp-compat.el,v 1.5 2001/12/31 08:30:12 davep Exp $
;;;
;;; Load the correct set of my compatibility functions, based upon the
;;; current platform.
;;;

;;
;; load up the proper set of compat cruft.
;;
(if (dp-xemacs-p)
    (load "dp-xemacs-fsf-compat.el")
  (load "dp-fsf-fsf-compat.el"))

;;;
;;;
;;;
(provide 'dp-compat)
