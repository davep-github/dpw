;;
;; stuff ganked from other places that is no longer needed but that might
;; be useful
;;

(defun dp-mk-alist (l)
  (message "l1>%s<" l)
  (let ((cdrl (cdr l)))
    (cons (car l)
	  (if (listp cdrl)
	    cdrl
	  (list cdrl)))))

(defun dp-mk-alists(l)
  ;;(message "l0>%s<" l)
  (mapcar 'dp-mk-alist l))

(defun f1 (a b c)
  (interactive)
  (let ((x (dp-mk-alists (list (cons "a" a) (cons "b" b) (cons "c" c)))))
    (setq globx x)))



(defun dp-map-addrs-to-fcc ()
  (interactive)
  (let (who-to fcc-folder)
    (save-excursion
      ;; pick an fcc folder based on the to: address
      (goto-char (point-min))
      ;; grab the to: addr
      (if (not (re-search-forward "^[tT]o:\\s-*\\(.*\\)$" nil t))
	  (error "No To: field: cannot autoset fcc"))
      (setq who-to (buffer-substring (match-beginning 1) (match-end 1)))
      (setq fcc-folder (scan-re-list who-to dp-fcc-alist))
      ;;(message (format "who-to>%s<, fcc-folder>%s<" who-to fcc-folder))
      ;; replace the existing fcc line
      (if fcc-folder
	  (progn
	    (goto-char (point-min))
	    (if (re-search-forward "^[fF]cc:.*$" nil t)
		(replace-match (concat "Fcc: " fcc-folder))
	      (if (re-search-forward "^--------$" nil t)
		  (progn
		    (beginning-of-line)
		    (insert (concat "Fcc: " fcc-folder "\n")))
		(message "Cannot find Fcc: field or header delimitter.")))))
      )))

(defun dp-gen-unique-delimitter (text)
  "Generate a delimitter that definitely does not match any complete
line within text.  Text is a bunch of lines delimitted by newlines."
  (interactive)
  (let ((lines (split-string text "\n"))
	(i 0))
    (mapconcat
     (lambda (s)
       (let* ((slen (length s))
	      (ch (cond
		   ;; if len(delim) > len(s) it cannot match
		   ((> i slen) nil)	
		   ;; if len(delim) == len(s) then extend delim.  Then we'll
		   ;; be guaranteed to not match
		   ((= i slen) t)
		   ;; if len(delim) < len(s) grab char just beyond delim's
		   ;; end. We'll add a char that is not this char to ensure
		   ;; a non-match
		   (t (substring s i (1+ i))))))
	 ;; (message "i: %d, slen: %d, ch>%s<" i slen ch)
	 (if (not ch)
	     ""				; leave delim as is
	   (setq i (1+ i))		; we're adding to delim
	   (if (eq ch t)		; extend delim
	       "+"
	     (if (string= ch "x") "X" "x"))))) ; add non-matching char
       lines
       "")))

(if (not (in-windwoes))
    (progn
      ;; try to load more featureful gnuserv
      ;; it will point server-start at gnuserv-start
      (condition-case nil
	  (load "gnuserv"))
      (server-start)
      (setq gnuserv-frame (car (frame-list)))) ;use one frame for all files.
  (require 'gnuserv)
  (gnuserv-start)
  (setq gnuserv-frame (car (frame-list))))

;;
;; IDEA: have this marker contain a "real" marker.  Use the
;; IDEA: full file name with the marker.
(defun dp-point-marker ()
  "Make a marker from point with full path name."
  ;; temp buffs don't have file names.  
  ;; IDEA save BUFFER type if file name is not available.
  ;; use buffer-p later?
   (list (point) 
	 (if (buffer-file-name)
	     (buffer-file-name)
	   (current-buffer))))

(defun dp-marker-pos (marker)
  "Return position from marker."
  (car marker))
(defun dp-marker-file (marker)
  "Return file from marker."
  (nth 1 marker))
(defun dp-marker-tagname (marker)
  "Return tagname from marker."
  (nth 2 marker))

(defun dp-goto-dp-marker (marker)
  (let ((file (dp-marker-file marker))
	(pos  (dp-marker-pos  marker)))
    (if (bufferp file)
	(switch-to-buffer file)
      (find-file file))
    (goto-char pos)))

(defvar dp-tag-stack nil
  "Stack of return locations from going to tags.")

(defun dp-tag-clear-stack ()
  "Clear the stack."
  (interactive)
  (setq dp-tag-stack nil))

(defun dp-pop-tag ()
  "Pop back to where we were before we went to the latest tag."
  (interactive)
  (if dp-tag-stack
      (let ((marker (car dp-tag-stack)))
	(setq dp-tag-stack (cdr dp-tag-stack))
	(dp-goto-dp-marker marker))
    (message "No tag history.")))

;;
;; FE: update to add info so that we know if we loaded this file in
;; FE: going to it so we can exit it when we leave it.
;; -- hard to do since find-tag does the work.
(defun dp-push-tag ()
  "Push file location, then goto tag."
  (interactive)
  (let ((my-mark (dp-point-marker)))
    (call-interactively 'find-tag)
    ;; push address *after* find tag since it seems to throw
    ;; an exception rather than return an error if the tag
    ;; isn't found
    ;; only push marker if the file part is OK. temp buffers don't
    ;; have associated file names.  I'll need to work this out later.
    (if (dp-marker-file my-mark)
	(setq dp-tag-stack 
	      (cons (append my-mark (list (car find-tag-history))) 
		    dp-tag-stack)))))

(defun dp-tag-trace (&optional files-too)
  "Print a formatted trace of the tag history."
  (interactive "P")
  (message "ft>%s<" files-too)
  (switch-to-buffer (get-buffer-create "*dp-tag-trace*"))
  (goto-char (point-max))
  (let ((tag-list (reverse dp-tag-stack))
	(indenter "")
	(marker))
    (while tag-list
      (setq marker (car tag-list))
      (setq tag-list (cdr tag-list))
      (insert (concat 
	       indenter 
	       (dp-marker-tagname marker) 
	       (if files-too
		   (concat " <" (dp-marker-file marker) ">")
		 "")
	       "\n"))
      (setq indenter (concat "  " indenter)))))

(defcustom dp-isearch-bm "issbm"
  "*Name of isearch bookmark.
It is set when using isearch-* commands."
  :group 'dp-vars
  :type 'string)

(defcustom dp-isearch-bm "issbm*"
  "*Name of isearch bookmark.
It is set when using isearch-* commands."
  :group 'dp-vars
  :type 'string)

(defcustom dp-func-menu-bm "fgbm*"
  "*Name of func-menu goto function bookmark.
It is set when using `fg' to find an in-file function def."
  :group 'dp-vars
  :type 'string)

(defcustom dp-top-bottom-bm "tbbm*"
  "*Name of goto file top/bottom bookmark."
It is set when using `dp-beginning-of-buffer' or `dp-end-of-buffer'."
  :group 'dp-vars
  :type 'string)

(defcustom dp-goto-line-bm "glbm*"
  "*Name of goto line bookmark."
It is set when using `dp-goto-line'."
  :group 'dp-vars
  :type 'string)

(defun dp-set-go-back-bm (&optional bm-name set-gbbm)
  "Set the `go back' book mark.  
This is useful for setting whenever we run a command which will move
us from a point to which we may wish to return.  E.g. save the start
of an i-search, `dp-beginning-of-buffer', `dp-end-of-buffer', etc.  If
BM-NAME is given, make a bookmark of that name.  If SET-GBBM is true,
make a bookmark called `gbbm*' (go back bookmark).  Push location onto
the buffer-local `dp-go-back-stack'."
  (interactive)
  (if bm-name
      (dp-set-or-goto-bm bm-name t))
  (if set-gbbm
      (dp-set-or-goto-bm "gbbm*" t))
  (dp-push-go-back))

