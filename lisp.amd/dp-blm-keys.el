;;;
;;; Manage buffer local keys.
;;; One way really, really sucks.

;;;
;;; This stuff is *way* better, but it requires my C code hack.

(defun dp-buffer-local-keymaps-p ()
  t)

(defvar dp-relevant-keymaps-at-flag 'at
  "We use this to ensure that our buffer spanning, keymap containing, 
singing and dancing extent is found when point is `point-min' ... `point-max'
+ 1 so we can have our key bindings be the localist.")

(defun dp-v2-buffer-local-keymaps-p ()
  ;; This variable only exists if my patch is present (see above)
  (boundp 'relevant-keymaps-at-flag))

;; This variable is only defined when my C code hack is present.
(if (dp-v2-buffer-local-keymaps-p)
    (progn
;;;       (dmessage "Whoot! New buffer local key code.")
      (make-variable-buffer-local 'relevant-keymaps-at-flag)
      (setq relevant-keymaps-at-flag dp-relevant-keymaps-at-flag)

      (defvar dp-buffer-local-keymap-extent-id 'dp-buffer-local-keymap-extent
        "Identification property on our buffer local keymap extents.")

      (defun dp-blm-key-defined-p (key &optional keymap)
        (and (setq-ifnil keymap (dp-blm-get-keymap))
             (lookup-key keymap key)))
      
      (defun dp-mk-spanning-extent (id-prop &rest props)
        "Make a buffer spanning extent."
        (apply 'dp-make-extent (point-min) (point-max)
               (or id-prop
                   'dp-spanning-extent)
               'start-closed t 'end-closed t 'detachable nil props))
      
      (defun dp-blm-mk-extent (&optional keymap)
        (let ((ext (dp-mk-spanning-extent dp-buffer-local-keymap-extent-id
                                          dp-buffer-local-keymap-extent-id t
                                          'keymap keymap)))
          ;; Seems to want ext 2nd? In spite of doc.
          ;; (wrong-type-argument extentp <nnn>)
          ;; extent-property(<nnn> dp-backup-keymap)
          (set-extent-priority ext -99)
          ;;(dmessage "pri of %s: %s" ext (extent-priority ext))
          ext))
      
      (defun dp-blm-get-extent ()
        (car (dp-extents-at-with-prop dp-buffer-local-keymap-extent-id
                                      '(unused . t))))

      (defun dp-blm-delete-extent ()
        (interactive)
        (let ((e (dp-blm-get-extent)))
          (if e
              (delete-extent e)
            (message "No blm extent at point[%s]." (point)))))
      
      (defun* dp-blm-get-keymap (&key extent map-id creat-p)
        (when creat-p
          (dp-blm-init-buffer))
        (when (setq-ifnil extent (dp-blm-get-extent))
          (extent-property extent (or map-id 'keymap))))
          
      (defun dp-blm-init-buffer (&optional keymap)
        (setq relevant-keymaps-at-flag dp-relevant-keymaps-at-flag)
        (let ((ext (or (dp-blm-get-extent)
                       (dp-blm-mk-extent 
                        (or keymap 
                            (make-sparse-keymap "dp buffer local keymap"))))))
          (unless (extent-property ext 'dp-backup-keymap)
            (set-extent-property ext 'dp-backup-keymap 
                                 (make-sparse-keymap "dp backup keymap")))
          (list (extent-property ext 'keymap)
                (extent-property ext 'dp-backup-keymap))))
      
      (defun dp-define-buffer-local-keys (keys &optional keymap buffer
					       protect-bindings-p name)
        "Define a list of keys to be as buffer local as possible.  
E.g. so that nothing can override them. 
KEYS is list: \(key def key def...\). 
BUFFER says which buffer to use, nil --> current buffer. 
PROTECT-BINDINGS-P controls if bindings can be overridden by this function."
        
        (with-current-buffer (or buffer (current-buffer))
          (let* ((maps (dp-blm-init-buffer))
                 (keymap (car maps))
                 msg                    ;!<@todo remove 
                 (backup-map (cadr maps)))
            (loop for (key def) on keys by 'cddr do
              (setq msg (format "blm; buf: %S, key: %S, def: %S" (buffer-name) 
                                key def))
              ;; Backup the original map.
              (unless (lookup-key backup-map key)
                (setq msg (concat msg "; adding to backup map"))
                ;; Only save the original binding.
                (define-key backup-map key def))
              (when (or (not (lookup-key keymap key))
                        (memq protect-bindings-p (list nil 'over-write)))
                (setq msg (concat msg "; adding to extent keymap"))
                (define-key keymap key def))
;;;               (dmessage (concat msg "!"))
              ))))
      
      )                                 ; 'tis away away up there.
  
  ;; ELSE
  (warn "You're stuck with the old and icky buffer local key junk.")
  (dp-deflocal dp-blm-extent nil
    "A buffer-wide extent to hold a very local keymap")
  
  (dp-deflocal dp-blm-map nil
    "A very local keymap.")
  
  (dp-deflocal dp-blm-map-method 'dp-blm-map-uses-minor-mode-map
    "How do we want to implement our buffer local keymaps?")
  
  (dp-deflocal dp-blm-minor-mode-v nil
    "Is our buffer local keymap minor mode active?")
  
  (dp-deflocal dp-blm-minor-mode-sym nil
    "Is our buffer local keymap minor mode active?")
  
  (dp-deflocal dp-blm-minor-mode-map-key nil
    "Holds a copy of the cons TOGGLE, KEYMAP of our minor mode.")
  
  (dp-deflocal dp-blm-minor-mode-key nil
    "Holds a copy of the list TOGGLE, MODELINE-STR of our minor mode.")
  
  (defun dp-blm-map-is-blm-p (keymap)
    "Return non-nil if KEYMAP is the current buffer local map."
    (and dp-blm-map
         (eq dp-blm-map keymap)))
  
  (defun dp-blm-extent-p (&optional buffer)
    (local-variable-p 'dp-blm-extent (or buffer (current-buffer))))
  
  (defun dp-blm-extent-map (&optional buffer)
    (and (dp-blm-map-extent-p buffer)
         (extent-property dp-local-keymap-extent 'keymap)))
  
  (defun dp-blm-current-local-map ()
    "Get map for use with `set-local-map'."
    (copy-keymap (car (current-keymaps))))
  
  (defun dp-blm-get-extent-map ()
    (if dp-blm-extent
        (extent-property dp-blm-extent 'keymap)))
  
  (defun dp-blm-get-minor-mode-map ()
    (when (and dp-blm-minor-mode-sym
               (symbol-value dp-blm-minor-mode-sym))
      (cdr-safe (assoc dp-blm-minor-mode-sym minor-mode-map-alist))))
  
  (defvar dp-blm-map-info
    '((dp-blm-map-uses-use-local-map . '(copy-p t))
      (dp-blm-map-uses-extent . '(copy-p nil))
      (dp-blm-map-uses-minor-mode-map . '(copy-p nil))
      (nil dp-blm-get-minor-mode-map . '(copy-p nil)))
    "List which tells us extra info about how to handle each map.")
  
  (defun dp-blm-copymap-p (&optional method)
    (plist-get (cdr (assoc (or method dp-blm-map-method) dp-blm-map-info))
               copy-p))
  
  (defvar dp-blm-map-gettor-alist 
    '((dp-blm-map-uses-use-local-map . dp-blm-current-local-map)
      (dp-blm-map-uses-extent . dp-blm-get-extent-map)
      (dp-blm-map-uses-minor-mode-map . dp-blm-get-minor-mode-map)
      (nil . dp-blm-get-minor-mode-map))
    "List which tells us how to get our buffer local key map.")
  
  (defvar dp-blm-modeline-string " BLm"
    "Mode line string to show our \"minor mode\" is active.")
  
  (defun dp-blm-get-map ()
    "Returns CONS: (keymap . settor-function).
KEYMAP may be a symbol, in which case it is KEYMAP* keymap;"
    (if dp-blm-map
        dp-blm-map
      (funcall (cdr (assoc dp-blm-map-method dp-blm-map-gettor-alist)))))
  
  (defun dp-blm-use-local-map (new-map &rest rest)
    (use-local-map new-map))
  
  (defun dp-blm-minor-mode-already-added-p ()
    (member dp-blm-minor-mode-key minor-mode-alist))
  
  ;; new-map old-map keymap buffer copy-p rest))))
  (defun dp-blm-set-minor-mode-map (new-map old-map &rest rest)
    (unless (dp-blm-minor-mode-already-added-p)
      (setq dp-blm-minor-mode-sym (dp-gentemp-uninterned "dp-blm-minor-mode-")
            new-map (or new-map dp-blm-keymap)
            dp-blm-minor-mode-map-key (cons dp-blm-minor-mode-sym new-map)
            dp-blm-minor-mode-key (list 
                                   dp-blm-minor-mode-sym dp-blm-modeline-string))
      (set dp-blm-minor-mode-sym nil)
      (make-local-variable dp-blm-minor-mode-sym)
      (set dp-blm-minor-mode-sym t)
      (add-minor-mode dp-blm-minor-mode-sym dp-blm-modeline-string new-map)
      (add-hook 'kill-buffer-hook 'dp-remove-minor-mode nil t)))
  
  (defun dp-remove-minor-mode (&optional mmma-cons mma-el)
    "Remove the minor mode which is EQUAL to mm-cons.
The default is `dp-blm-minor-mode-map-key', that which raised the need for
this function."
    (setq minor-mode-map-alist (delete (or mmma-cons dp-blm-minor-mode-map-key)
                                       minor-mode-map-alist)
          minor-mode-alist (delete (or mma-el dp-blm-minor-mode-key)
                                   minor-mode-alist)))
  
  (defun dp-blm-kill-buffer-hook ()
    "Clean up the goop used to support a private map per buffer.
Needed since buffer wide extent keymaps aren't consulted AT EOF.
Called as a oneshot from a buffer-local hook."
    (dp-remove-minor-mode)
    (setq dp-blm-minor-mode-sym nil)      ;Helps GC?
    )
  
  (defun dp-blm-make-map-extent (&optional overwrite-p)
    (when (or (not dp-blm-map-extent)
              overwrite-p)
      (setq dp-blm-map-extent 
            (dp-make-extent (point-min) (point-max)
                            'dp-blm-map-extent
                            'start-closed t
                            'end-closed t
                            'detachable nil))))
  
  (defun dp-blm-set-extent-map (new-map &rest rest)
    "We don't use REST, but it's there for the ``set map interface.''"
    (unless dp-blm-extent
      (dp-blm-make-map-extent new-map))
    (set-extent-property dp-blm-map-extent 'keymap new-map))
  
  (defvar dp-blm-map-settor-alist 
    '((dp-blm-map-uses-use-local-map . dp-blm-use-local-map)
      (dp-blm-map-uses-extent . dp-blm-set-extent-map)
      (dp-blm-map-uses-minor-mode-map . dp-blm-set-minor-mode-map)
      (nil . dp-blm-set-minor-mode-map))
    "List which tells us how to set our buffer local key map.")
  
  (defun dp-blm-set-map-name (&optional keymap str)
    "Give the KEYMAP (or current local map if nil) to a unique name."
    (setq-ifnil keymap dp-blm-map
                str mode-name)
    (set-keymap-name keymap
                     (dp-serialized-name 
                      (format "dp-blm-map-%s-" mode-name)
                      nil
                      ;; use the string representation of keymap since we don't
                      ;; want to look at the map itself if it's been garbage
                      ;; collected.
                      'keymap: (format "%s" keymap))))
  

;;(defun dp-define-buffer-local-keys (keys &optional keymap buffer protect-bindings-p
;;                                         name)
  (defun dp-define-buffer-local-keys (keys &optional buffer keymap copy-p name
                                      &rest rest)
    "Add keys to a BUFFER's keymap and make keymap the local-map.
If BUFFER is nil, use the current buffer.
KEYS is a list defined thus: \(key command...\).
This is useful if we want to add keys to a buffer without stomping on the
buffer's mode's key map."
    (interactive)
    ;;(dmessage "dp-define-buffer-local-keys: current-buffer: %s, buffer: %s" 
    ;;          (current-buffer) buffer)
    (with-current-buffer (or buffer (current-buffer))
      (let* ((buffer (or buffer (current-buffer)))
             (old-map (or keymap (dp-blm-get-map)))
             (unused (or keymap
                         (and old-map
                              ;;(dmessage "using existing keymap: %s" old-map)
                              )))
             (new-map (dp-define-buffer-local-keys0 
                       keys 
                       ;; If there's no specific map to use, then we need to
                       ;; make one.  If we can stick it into the file spanning
                       ;; extent then there's no need to copy the existing
                       ;; current-local-map.  In this case, we pass t as the
                       ;; map to indicate we want a new map.  The nil will give
                       ;; a copied & modified map.
                       old-map
                       buffer
                       copy-p
                       (and mode-name
                            (or
                             (not dp-blm-map)
                             (and (dp-blm-map-is-blm-p old-map)
                                  (not (keymap-name old-map))))))))
        (setq dp-blm-map new-map)
        (apply (cdr (assoc dp-blm-map-method dp-blm-map-settor-alist))
               new-map old-map keymap buffer copy-p rest))))
  
  (defun dp-define-buffer-local-keys0 (keys &optional keymap buffer copy-p 
                                       name-it-p)
    "Return a key map with KEYS added to it.
KEY is a list of key defs '(key1 def1 key2 def2 ...).
If KEYMAP is non-nil, put keys there.  Otherwise add keys to the most local
current key map.
If BUFFER is non-nil, get the most local key map from BUFFER."
    (interactive)
    (if (and dp-blm-map keymap
             (eq keymap dp-blm-map))
        (setq copy-p nil)
      (setq-ifnil copy-p (dp-blm-copymap-p dp-blm-map-method)))
    
    (save-excursion
      (let ((kmap (cond
                   ((not keymap) (make-sparse-keymap))
                   (copy-p (copy-keymap keymap))
                   ((not dp-blm-map) (make-sparse-keymap))
                   (t keymap))))
        (when name-it-p
          (dp-blm-set-map-name kmap))
        (loop for (key def) on keys by 'cddr 
          do (define-key kmap key def))
        kmap))))


;; More || (and hopefully more re-memorable to me) `local-set-key'
(defalias 'dp-blm-keys 'dp-define-buffer-local-keys)

(provide 'dp-blm-keys)
