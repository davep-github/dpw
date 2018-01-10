;;;
;;; my kind of bookmark.
;;;

(defstruct dp-bm
  (id nil)
  (marker nil)
  (plist)
  (help-extent))

(defalias 'dp-bm-name 'dp-bm-id)

(defun dp-bm-get-extent ()
  (if (dp-extent-with-property-exists 'dp-bm-extent-p)
      
  ))

;(defun* dp-bm-help-extent-p ((pos (point))
;  "Does a bookmark help extent exist @ POS?"
(dp-defwriteme dp-bm-help-extent-p (pos)
  "Does a bookmark help extent exist @ POS?")
;  
(defun dp-bm-process-plist (bm)
  "Process BM's plist; perform any actions indicated."
  (dmessage "finish me!!!")
  bm)

;(defun dp-bm-process-plist (bm)
;  "Process properities in the BM's plist"
;  (let ((plist (dp-bm-plist bm))
;        thither)
;    (loop for (prop val) in (dp-bm-plist bm)
;      do (let (bm-extent)
;           (if (functionp val)
;               (funcall val)
;             (case prop
;               (add-help (and val
;                              (dp-do-thither 
;				(dp-bm-marker bm) 
;                                thither
;                                (if (dp-extent-with-property-exists)
;                                    (dp-
;                         
;                        )
;      )
;    bm)
;)
(defun* dp-make-bookmark (id marker 
                          &optional plist (add-help-p t) (colorize-line-p t))
  "Make a bookmark.  NB!  This is NOT an emacs style bookmark!
This makes a slick-like bookmark on a line in a file.  There is a bookmark
list per buffer.
@todo we want to change this to a struct, and this is named compatibly."
;;CO;   (list id marker plist)
  (dp-plist-put plist
                'add-help-p add-help-p 
                'colorize-line-p colorize-line-p)
  (dp-bm-process-plist (make-dp-bm :id id :marker marker :plist plist)))

;; bm2
(defun dp-nuke-bookmarks ()
  (interactive)
  (setq dp-bm-list nil))

(dp-deflocal dp-bm-list nil
  "Bookmark list. 
ALIST of bookmarks, each entry is (bookmark-name . marker).  We use a
marker even tho the list is buffer local so that our bookmarks move
around with edited text.")

(defvar dp-bm-ring-ptr nil
  "Ring pointer into bm list.")
(make-variable-buffer-local 'dp-bm-ring-ptr)

(defun dp-bm-names (&optional sorted)
  "Return a list of all bm names."
  (let ((names (mapcar 'dp-bm-id dp-bm-list)))
    (if sorted
	(sort names 'string-lessp))
      names))

;;Replaced with defstruct version; (defun dp-bm-name (bm)
;;Replaced with defstruct version;   (car bm))

;;Replaced with defstruct version; (defun dp-bm-marker (bm)
;;Replaced with defstruct version;   (cadr bm))

;;Replaced with defstruct version; (defun dp-bm-plist (bm)
;;Replaced with defstruct version;   (caddr bm))

(defun dp-bm-prop-put (bm prop val &optional plist)
  (setf (dp-bm-plist bm)
        (plist-put (or plist (dp-bm-plist bm)) prop val)))

(defun dp-bm-prop-get (bm prop &optional plist)
  (plist-get (or plist (dp-bm-plist bm)) prop))

(defun dp-bm-has-prop-p (bm prop prop-val)
  (equal prop-val (dp-bm-prop-get bm prop)))

(defun dp-bm-embedded-p (bm &optional plist)
  (dp-bm-prop-get bm 'embedded-p plist))

(defun bm-list-sans-prop (bm-list prop prop-val)
  (loop for bm in bm-list
    unless (dp-bm-has-prop-p bm prop prop-val)
    collect bm))

(defun dp-bm-pos (bm)
  (marker-position (dp-bm-marker bm)))

(defun dp-goto-bm (bm)
  (goto-char (dp-bm-pos bm)))

;;pre-defstruct; (defun dp-bm-find (id)
;;pre-defstruct;   (assoc id dp-bm-list))

(defun dp-bm-find (bm-id)
  (car
   (member-if (function
               (lambda (bm-list-item)
                 (equal bm-id
                        (dp-bm-id bm-list-item))))
              dp-bm-list)))

(defun dp-bm-member (id)
  "Return the sublist beginning with the id's bookmark."
  (member* id dp-bm-list :key 'dp-bm-id :test 'equal))

(defun dp-bm-copy (bm)
  (copy-dp-bm bm))                      ; `defstruct's version.

(defun dp-bm-equal (bm name marker plist)
  (and (string= (dp-bm-id bm) name)
       (equal (dp-bm-marker bm) marker)
       (plists-equal (dp-bm-plist bm) plist)))

(defun dp-add-to-bm-list (bm-num marker &optional plist)
  (let ((bm (dp-make-bookmark bm-num marker plist)))
    (setq dp-bm-list (cons bm dp-bm-list))
    bm))

(defun dp-scan-for-embedded-bookmarks (&optional from-point-p verbose-p)
  "Scan for all strings of the form <:bookmark-name:>.
Add each bookmark-name to the list of bookmarks."
  (interactive "P")
  (save-excursion
    (unless from-point-p
      (goto-char (point-min)))
    (while (re-search-forward (concat "\\(<:<::>\\)"
                                      "\\|"
                                      "\\(<:\\s-*\\(.*?\\)\\s-*:>\\)")
                              nil t)
      (setq dp-debug-xxx (dp-all-match-strings-string))
      (if (match-string 1)
          (dp-set-or-goto-bm 
           (buffer-substring (line-beginning-position)
                             (line-end-position))
           :reset t
           :plist '(embedded-p t)
           :bm-kind "embedded-line"
           :bm-marker (dp-mk-marker 
                       (line-beginning-position)))
        (loop for match-string in (save-match-data
                         (split-string (match-string 2) "|")) 
          do
          (dp-set-or-goto-bm match-string 
                             :reset t
                             :plist '(embedded-p t)
                             :bm-kind "embedded-text"
                             :quiet-p (not verbose-p)
                             :bm-marker (dp-mk-marker (match-beginning 0))))))))

(defun* dp-bm-list-filter-embedded (&optional (bm-list dp-bm-list))
  (delq nil (mapcar (function 
                     (lambda (bm)
                       (if (dp-bm-embedded-p bm)
                           nil
                         bm)))
                    bm-list)))

(defun* dp-mk-bm-completion-list (&key ignore-embedded-bookmarks-p 
                                  from-point-p
                                  (quote t)
                                  (bm-list dp-bm-list))
  (unless ignore-embedded-bookmarks-p
    (dp-scan-for-embedded-bookmarks from-point-p))
  (setq quote (if quote "'" ""))
  (mapcar (function (lambda (bm)
                      (cons (format "%s%s" quote (dp-bm-name bm))
                            bm)))
          bm-list))

(defun* dp-bm-rebuild-completion-list (&key ignore-embedded-bookmarks-p 
                                       from-point-p
                                       (quote nil)
                                       (bm-list dp-bm-list))
  (dp-mk-bm-completion-list 
   :ignore-embedded-bookmarks-p ignore-embedded-bookmarks-p 
   :from-point-p from-point-p
   :quote quote))

  
(defvar dp-get-bm-interactive-history '()
  "A variable by any other name...")

; (defun* dp-add-to-bm-history (bm-name &key save-empty-p)
;   (interactive "sbm name: ")
;   (unless (equal (car-safe dp-get-bm-interactive-history) bm-name)
;     (when (or save-empty-p
;               (not (string= "")))
;       (setq dp-get-bm-interactive-history 
;             (cons bm-name dp-get-bm-interactive-history)))))

(defun* dp-add-to-history (hist-sym string &key allow-dupes-p pred pred-args
                           remove-empty-p)
  "Add to a history type list.  I.e. don't dupe the 1st item if desired.
Calling it `dp-add-to-history-if-car-not=' is a bit too much.  Even for me."
  (unless (stringp string)
    (setq string (format "%s" string)))
  (let ((hist (symbol-value hist-sym)))
    (when (and remove-empty-p
               (string= (car hist) ""))
      (set hist-sym (cdr hist))
      (setq hist (symbol-value hist-sym)))
    (unless (or (and (not allow-dupes-p)
                     (string= (car hist) string))
                ;; Allow just giving pred-args to mean to `and' the values
                ;; together so simple vars can be passed.  e.g. (stupid ex):
                ;; (dp-add-to-history 'h :pred-args (list h add-to-h-p))
                ;; Will result in h being modified if it is non-nil and the
                ;; flag add-to-h-p is non-nil.
                (and (or pred
                         ;; pred is nil... set pred to `and' if pred-args.
                         ;;
                         (and pred-args
                              ;; pred nil, pred-args --> `and' all of the args
                              (setq pred 'and)
                              nil       ; So we fall thru to the apply below.
                              ))
                     (not (apply pred hist-sym string pred-args))))
      (set hist-sym (cons string hist)))))

(defun* dp-get-bm-interactive (prompt &key completions
                               (add-to-history-p t)
                               (toss-empty-p t))
  ;;completing-read don't like buffer locals.
  (let* ((bubba dp-get-bm-interactive-history)
         (hist (or (and add-to-history-p 'bubba)
                   t))                  ;t says don't record.
         (ret (list (completing-read (or prompt "bm id: ") 
                                     (or completions
                                         (dp-mk-bm-completion-list))
                                     nil nil nil hist)
                    current-prefix-arg))
         (bm (car ret)))
    ;; The reason that the original value of dp-get-bm-interactive-history
    ;; isn't changed by `completing-read' is that the new item is added by
    ;; something like (setq history-sym (cons new-item (symbol-val
    ;; history-sym)) which doesn't modify the original list since the car is
    ;; modified and assigned to a different variable effective making a new
    ;; list.
    (and add-to-history-p
         (not (and toss-empty-p
                   (string= "" (car-safe bubba))))
         (setq dp-get-bm-interactive-history bubba))
    ret))

(defun dp-get-bm-interactive-for-get-or-set (&rest rest)
  (let ((ret (apply 'dp-get-bm-interactive rest)))
    (list (car ret)
          :reset (cadr ret))))
(defun dp-pos-str (pos)
    (format "Line=%d, point=%d" (line-number pos) pos))

(defun dp-bm-pos-str (bm)
    (dp-pos-str (dp-bm-pos bm)))

(defvar dp-last-bm nil
  "Last bm that we set (?? or got??).")

(defun dp-bm-update (bm bm-name marker bm-props 
                     &optional bm-list force-update-p)
  (if (or force-update-p 
            (not (dp-bm-equal bm bm-name marker bm-props)))
      (setcar (dp-bm-member bm-name) (dp-make-bookmark bm-name marker bm-props))
    nil))                               ; Returns nil if no update was done.
  
(defun* dp-set-or-goto-bm (bm-name
                           &key reset action-if-non-existent 
                           (plist nil)
                           (colorize-p t)
                           (verbose-p t)
                           bm-kind
                           quiet-p
                           (highlight-line-p nil)
                           (bm-marker nil bm-marker-passed-p))
  "Set or goto a bookmark.
If the BM-NAME is in the list, goto it, otherwise, 
set the bookmark to point.
If RESET is t, then set the bookmark location to point.
If RESET is nil, then use existence of prefix arg as truth value of reset.
If RESET is other, then use (not existence of prefix arg) as truth value 
of reset." 
  (interactive (dp-get-bm-interactive-for-get-or-set "_bm name: "))
  ;;(dp-add-to-bm-history bm-name)

  ;;(message (format "bm-name>%s<, reset>%s<, cpa>%s<" bm-name reset
  ;;		   current-prefix-arg))

  (if (not reset)
      (setq reset current-prefix-arg)
    (unless (equal reset t)
      (setq reset (not current-prefix-arg))))

  ;;(message (format "bm-name>%s<, reset>%s<, cpa>%s<" bm-name reset 
  ;;		   current-prefix-arg))

  ;; stringify name
  (setq bm-name (format "%s" bm-name))
  
  (save-match-data
    ;; `dp-goto-line' uses '<nnn> to mean bookmark # <nnn>. 
    (string-match "^\\('*\\)?\\(.*\\)$" bm-name)
    (setq bm-name (match-string 2 bm-name)))
  (setq this-command 'dp-set-or-goto-bm)
  (let* ((bm (dp-bm-find bm-name))
         (bm-msg (format "%sbm `%s'" 
                         (if bm-kind
                             (concat bm-kind " ")
                           "")
                         bm-name))
         (status-msg "")
	 (entre-line (line-number (point)))
         (bm-ro-p (and bm (dp-bm-prop-get bm 'bm-ro-p))))
    (when (and bm
               (eq last-command 'dp-set-or-goto-bm)
               (equal (dp-bm-id dp-last-bm) bm-name))
      ;; Doubled bm command ==> toggle bm-ro-p
      (when (or  (not dp-ask-to-change-bm-protect-status-p)
                 (y-or-n-p (if bm-ro-p "Unprotect bm? " "Protect bm? ")))
        (setq bm-ro-p (not bm-ro-p))
        (dp-bm-prop-put bm 'bm-ro-p bm-ro-p))
      (message "bm %s's state is now %s" bm-name 
               (if (dp-bm-prop-get bm 'bm-ro-p) "READ ONLY" "Writable"))
      (return-from dp-set-or-goto-bm))
    
    (setq this-command 'dp-set-or-goto-bm)
    
    (if (and bm (not reset))
	;; existing bm and no reset requested, go to it.
	(let ((pos (dp-bm-pos bm))
              old-bm)
	  ;; (message (format "going to %d" pos))
	  (setq status-msg 
                (concat status-msg (format 
                                    "Went %s to %s, from Line=%s to %s"
                                    (cond
                                     ((< pos (point)) "back")
                                     ((> pos (point)) "forward")
                                     ((= pos (point)) "Nowhere")
                                     (t "Who knows where?"))
                                    bm-msg
				    entre-line
				    (dp-bm-pos-str bm))))
	  (dp-push-go-back "dp-set-or-goto-bm")
	  (goto-char pos)
	  (dp-set-zmacs-region-stays t))

      ;; non-existent bm or reset is requested.
      ;; either way, set the bm to point
      ;; Unless the bm is currently ro
      (when bm-ro-p
        (ding)
        (if (y-or-n-p (format "bm %s is READ ONLY.  Set it anyway? " bm-name))
            (dp-bm-prop-put bm 'bm-ro-p nil)
        ;; Set like this so we don't go into protect mode if we immediately
        ;; choose to goto the protected bm.
        (setq this-command nil)
        (message "not moving bm %s" bm-name)
        (return-from dp-set-or-goto-bm)))

      (setq-ifnil bm-marker (point-marker))
      (if bm
	  ;; bm exists, change its location
          (progn
            (setq old-bm (dp-bm-copy bm))
            (when (dp-bm-update bm bm-name bm-marker plist)
              (setq status-msg
                    (if (equal (dp-bm-pos-str old-bm)
                               (dp-pos-str 
                                     (marker-position bm-marker)))
                        nil
                    (concat status-msg 
                            (format "moving %s from %s *to* %s"
                                    bm-msg
                                    (dp-bm-pos-str old-bm)
                                    (dp-pos-str 
                                     (marker-position bm-marker))))))))
	;; otherwise, possibly make a new one
        (if (or (eq action-if-non-existent 'nop)
                (and (eq action-if-non-existent 'ask)
                     (not (y-or-n-p 
                           (format "No such bm (%s); create it? " bm-name)))))
            (setq status-msg (format "%s***ignoring non-existent %s " 
                                     status-msg bm-msg))
          (when highlight-line-p
            (dp-colorize-region (if (eq highlight-line-p t)
                                    nil
                                  highlight-line-p)))
          (setq bm (dp-add-to-bm-list bm-name bm-marker plist)
                status-msg (concat status-msg (format "created %s at "
                                                      bm-msg)))
          (setq status-msg (concat status-msg (dp-bm-pos-str bm)))))
      
;       (message (format "set bm %s to %d" bm-name 
;                        (marker-position bm-marker)))
      )
    (setq dp-last-bm bm)
    (when (and status-msg
               (not quiet-p))
      (message "%s" status-msg))))
(put 'dp-set-or-goto-bm isearch-continues t)


(defalias 'gb 'dp-set-or-goto-bm)

(defsubst gbh (name &optional color)
  (interactive (dp-get-bm-interactive 
                "Highlighted bm: "
                :completions (dp-bm-rebuild-completion-list)))
  (dp-set-or-goto-bm name 
                     :reset nil 
                     :action-if-non-existent 'set 
                     :highlight-line-p (or color t)))

(defun dp-bm-list-clear ()
  "Clear the bookmark list.
Make 'em all point nowhere so we don't continue to update 'em 
until they get gc'd."
  (interactive)
  (let (bm)
    (while dp-bm-list
      (setq bm (car dp-bm-list)
	    dp-bm-list (cdr dp-bm-list))
      ;;@todo XXX Add code to unhiglight lines.
      (set-marker (dp-bm-marker bm) nil)))
  (setq dp-bm-list nil))

(provide 'dp-bookmarks)
