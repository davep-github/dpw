;;;
;;; $Id: dp-fsf-fsf-compat.el,v 1.5 2001/12/27 08:30:14 davep Exp $
;;;
;;; Compatibility functions when running fsf emacs.
;;;
(defsubst dp-mark-active-p ()
  mark-active)

(defsubst dp-deactivate-mark ()
  (deactivate-mark))

(defsubst dp-set-mark (pos)
  (set-mark pos))

(defsubst dp-fill-keymap (map filler)
  "Fill a keymap MAP with a given item, FILLER."
  `(fillarray (car (cdr map)) filler))

(defmacro dp-set-zmacs-region-stays (arg)
  ())
