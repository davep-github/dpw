(add-to-list 'load-path (expand-file-name "~davep/lisp/contrib"))
(add-to-list 'load-path default-directory)
(require 'dp-macros)
(defun* dp-define-my-map-prefixes (&optional (map global-map))
  (define-key map "\C-cd" 'dp-kb-prefix)
  ;; (I *really*   need  to get   my  laptop's kb  fixed).  Add    C-xC-d as an
  ;; alternative  dp-* prefix.  It clobbers  `list-directory',  but I never use
  ;; it,  and since dired is standard,  it should  never clobber anything else.
  ;; Switch to it in general?
  (define-key map "\C-x\C-d" 'dp-kb-prefix))
(provide 'dp-deps)
