;;;
;;; $Id: dp-colorize-ifdefs.el,v 1.14 2003/06/16 07:30:08 davep Exp $
;;;
;;; Colorizing ifdef support
;;;

(defun dp-gen-cpp-cond-regexp (keyword-list)
  (concat "^#\\s-*\\("
	  (regexp-opt keyword-list)
	  "\\)"))
  
(defvar dp-cpp-cond-regexp 
  (dp-gen-cpp-cond-regexp '("if" "ifdef" "ifndef" "else" "elif" "endif"))
  "Regexp to recognize all cpp conditionals.")

(defvar dp-cpp-endif "^#\\s-*endif"
  "Regexp to recognize endif.")

(defvar dp-cpp-if 
  (dp-gen-cpp-cond-regexp '("if" "ifdef" "ifndef"))
  "Regexp to recognize ifxxx conditionals.")
	  
(defvar dp-colorize-ifdefs-colors
  '(dp-cifdef-face0 dp-cifdef-face1 dp-cifdef-face2 dp-cifdef-face3
		    dp-cifdef-face4 dp-cifdef-face5 dp-cifdef-face6)
  "List of faces to cycle thru when colorizing cpp conditionals.")

(defun dp-get-next-cpp-cond ()
  "Find and return the next cpp conditional statement"
  (save-match-data
    (re-search-forward dp-cpp-cond-regexp)
    (match-string 0)))

(defvar dp-colorize-ifdefs-ret nil)
(defun dp-colorize-ifdefs0 (colors-in &optional colorize-nested)
  "Colorize parts of ifdef."
  (let (regions 
	(colors colors-in)
	color start cpp-cond region 
	sub-colors0 sub-colors
	dont-rot-colors
	end-pos)
    (beginning-of-line)
    (setq start (point))
    (save-excursion
      (dp-find-matching-paren)
      (setq end-pos (point)))

    (setq color (car colors))
    (setq sub-colors (dp-rotate-and-delq colors-in color))

    (save-excursion
      ;; get what should be an ifxxx ??? assert this ???
      (setq cpp-cond (dp-get-next-cpp-cond))
      ;;(dmessage "cpp-cond>%s<" cpp-cond)
      (while (< (point) end-pos)
	(setq cpp-cond (dp-get-next-cpp-cond))
	;;(dmessage "cpp-cond>%s<, pt>%s<, col>%s<" cpp-cond (point) color)
	(if (and (not colorize-nested)
		 (string-match dp-cpp-if cpp-cond))
	    (progn
	      ;; a nested ifxxx sequence, recursively color it
	      ;;  with a list of colors excluding the current
	      ;;  color.
	      ;; This ensures there will not be any two identicaly
	      ;;  colored adjacent regions.
	      ;; It also ensures that the enclosing region all has the 
	      ;;  same color
	      ;;(dmessage "sub-colors>%s<" sub-colors)
	      (setq colors 
		    (dp-colorize-ifdefs0 sub-colors colorize-nested))
	      ;; rotate our color list so that the first color in
	      ;; the returned list is first.
	      (setq colors (dp-rotate-to colors-in (car colors))
		    dont-rot-colors t)
	      
	      ;;(dmessage "rec colors>%s<" colors)
	      (beginning-of-line)
	      (hif-ifdef-to-endif)
	      (end-of-line)
	      (setq sub-colors (dp-list-rot sub-colors))
	      )
	  ;; not an ifxxx, terminate current extent
	  (let ((estart start)
		eend)
	    (if (string-match dp-cpp-endif cpp-cond)
		(progn
		  (end-of-line)
		  (forward-char)
		  (setq eend (point))
		  (setq start (point)))
	      (beginning-of-line)
	      (setq eend (point)
		    start (point))
	      (end-of-line)
	      (forward-char))
	    ;; (dp-make-extent start (point) 'dp-cifdef 'face color)
	    (setq dp-colorize-ifdefs-ret 
		  (cons (list estart eend color) dp-colorize-ifdefs-ret)))
	  ;;(dmessage "mkext: s>%s<, end>%s<, col>%s<" start (point) color)

	  (if dont-rot-colors
	      (setq dont-rot-colors nil)
	    (setq colors (dp-list-rot colors)))
	  (setq color (car colors))
	  (setq sub-colors (dp-rotate-and-delq colors-in color)))))
    colors))

;;;###autoload
(defun dp-uncolorize-ifdefs (&optional begin end)
  (interactive "r")
  (dp-delete-extents (or begin
                         (point-min))
                     (or end 
                         (point-max)) 
                     'dp-cifdef))

;;;###autoload
(defun dp-colorize-ifdefs (&optional colorize-nested)
  "Colorize parts of ifdef."
  (interactive "P")
  ;; remove any existing colorization
  (dp-uncolorize-ifdefs)
  (dp-delete-extents (point-min) (point-max) 'dp-cifdef)
  (setq dp-colorize-ifdefs-ret nil)

  (dp-colorize-ifdefs0 dp-colorize-ifdefs-colors colorize-nested)
  ;;(dmessage "ret0>%s<" dp-colorize-ifdefs-ret)
  (setq dp-colorize-ifdefs-ret (nreverse dp-colorize-ifdefs-ret))
  ;;(dmessage "ret1>%s<" dp-colorize-ifdefs-ret)
  (let ((extent-num 0))
    (dolist (ext dp-colorize-ifdefs-ret)
      (progn
;;         (dp-make-extent (nth 0 ext) (nth 1 ext) 
;;                         'dp-cifdef
;;                         ;; A common property for all of my colorized regions.
;;                         'dp-colorized-p t
;;                         'dp-extent-num extent-num
;;                         'face (nth 2 ext))
        (dp-colorize-region (nth 2 ext) (nth 0 ext) (nth 1 ext)
                            nil nil
                            'dp-extent-num extent-num)
        (incf extent-num)))))
;;;
;;;
;;;
(provide 'dp-colorize-ifdefs)
