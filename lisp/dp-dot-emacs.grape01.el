(defconst dp-sfh-height 66)
(dmessage "Find better font")
(defconst dp-2w-frame-width 166)
(setq visible-bell nil)
;; For some reason, putty is getting/generating and passing on garbage
;; input. For XEmacs in a VNC session tunneled to by putty, the result is a
;; spurious f15. So, to make the bell STFU, I'll grab it and do nada.
(global-set-key [f15] (kb-lambda ()))
;; The keys can come at any time, say between the time I press Alt and ?w.
;; so...

(require 'dp-dot-emacs.intel.el)
(provide 'dp-dot-emacs.grape01.el)
