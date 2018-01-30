;;;
;;; $Id: dp-xemacs-late.el,v 1.30 2005/06/13 08:20:07 davep Exp $
;;;
;;; xemacs specific stuff best done late in the
;;; init process.  dpmisc is loaded and available.
;;;

(setq tag-table-alist
      '(("/usr/local/lib/xemacs.*/" . "/usr/bree/src/xemacs/current/")
	("/usr/include/g\\+\\+" . "/usr/include/g\\+\\+/")
	("/usr/include" . "/usr/include/")
	(dp-lisp-dir . dp-lisp-dir)))

;;
;; set up a titlebar format.  Various window things will look for this in
;; order to jump to the main emacs window.
(defconst dp-frame-title-format (format "%%S@%s: %%f" (dp-short-hostname))
  "*Base frame title format.")

;;(setq frame-title-format (concat "[No SB] " dp-frame-title-format))

;; ftp.[ca|us].xemacs.org are faster.
;; ca --> /pub/Mirror/xemacs/packages   (@ ualberta)
;; us --> 
(setq package-get-remote '("ftp.ca.xemacs.org" "pub/Mirror/xemacs/packages"))
;;(setq package-get-remote '(("ftp.xemacs.org" "pub/xemacs/packages")))

;;
;; controls fontification in pcl-cvs buffer.
(setq cvs-highlight t)

;;
;; func menu stuff
(when (dp-optionally-require 'func-menu)
  ;;(define-key global-map 'f8 'function-menu)
  ;;(add-hook 'find-file-hooks 'fume-add-menubar-entry)
  (define-key global-map "\C-cfl" 'fume-list-functions)
  (define-key global-map "\C-cfg" 'fume-prompt-function-goto)
  ;; (define-key global-map '(shift button3) 'mouse-function-menu)
  ;; (define-key global-map '(meta  button1) 'fume-mouse-function-goto)
  (setq-default fume-display-in-modeline-p nil)
  (defalias 'funcs 'fume-list-functions)
  (defalias 'fl 'fume-list-functions)
  (defun fg ()
    (interactive)
    (dp-push-go-back "fume goto function")
    (fume-rescan-buffer) 
    (call-interactively 'fume-prompt-function-goto)))

;;
;;
(autoload 'resize-minibuffer-mode "rsz-minibuf" nil t)
(resize-minibuffer-mode)
(setq resize-minibuffer-window-exactly t)  ; experimenting 2010-06-16T12:31:57

;;; ********************
;;; Load a partial-completion mechanism, which makes minibuffer completion
;;; search multiple words instead of just prefixes; for example, the command
;;; `M-x byte-compile-and-load-file RET' can be abbreviated as `M-x b-c-a RET'
;;; because there are no other commands whose first three words begin with
;;; the letters `b', `c', and `a' respectively.
;;; (copped from sample.init.el)
;;;
;;;(load-library "completer")
;;; never really used it, plus it breaks ./x/y/z (cannot use .) in
;;; shell buffers (at least)
;;; plus it is from a minion of satan (xxx@microsoft.com)

;;;
;;; support for end of file glyphs...
;;;
(defvar dp-buffer-endicator-extent nil
  "The extent used to indicate EOF.")
(make-variable-buffer-local 'dp-buffer-endicator-extent)

(dp-deflocal dp-buffer-endicator-extent-keymap nil
  "Add this keymap to the endicator extent as a way to get a most local keymap.")

(defface dp-default-endicator-face
  '((((class color) (background light)) 
     (:background "lavender")
     (:foreground "lightblue")))
  "Face for buffer endicator glyph."
  :group 'faces
  :group 'dp-vars)


(defvar dp-endicator-face 'dp-default-endicator-face)

;;;
;;; may want to bag this...  it makes displaying the last page of a
;;; file noticably slower.
;;; Partially bagged: the default is now a text glyph.
;;;
(defun dp-add-buffer-endicator2 (&optional glyph-spec file)
  "Add a glyph to denote EOF.
Copped from the XEmacs FAQ."
  (interactive)
  (let* ((ext (make-extent (point-min) (point-max)))
         (spec (cond
                (glyph-spec glyph-spec)
                (file `[xpm :file ,file])
                ;;default
               (t [string :data "[EOF]"])))
         (glyph (make-glyph `( ,spec))))
    (set-extent-property ext 'start-closed t)
    (set-extent-property ext 'end-closed t)
    (set-extent-property ext 'detachable nil)
    (set-extent-property ext 'dp-buffer-endicator-extent t) ; tag for identification
    (when dp-endicator-face
      (set-glyph-face glyph dp-endicator-face))
    (when dp-buffer-endicator-extent-keymap
      (set-extent-property ext 'keymap dp-buffer-endicator-extent-keymap))
    (set-extent-end-glyph ext glyph)
    (setq dp-buffer-endicator-extent ext)))

(defun dp-buffer-endicator-extent-exists ()
  "Return t if the current buffer already contains an endicator glyph."
  (interactive)
  (dp-extent-with-property-exists 'dp-buffer-endicator-extent))

(defun dp-add-buffer-endicator (&optional image-spec file)
  (interactive)
  (unless (dp-buffer-endicator-extent-exists)
    (dp-add-buffer-endicator2 image-spec file)))

(defvar dp-default-endicator-spec nil
  "Arbitrary image specifier for any kind of image.")

(defun dp-add-default-buffer-endicator ()
  (interactive)
  (dp-add-buffer-endicator dp-default-endicator-spec 
                           dp-default-endicator-xpm-file))

(defun dp-add-chuckie-endicator ()
  (interactive)
  (dp-add-buffer-endicator '[xpm :data "\
/* XPM */
static char * chuck_xpm[] = {
\"25 28 12 1\",
\" 	s None	c None\",
\".	c #FFFF65956595\",
\"X	c #CF3C30C230C2\",
\"o	c #820700000000\",
\"O	c black\",
\"+	c #659565956595\",
\"@	c #CF3CCF3C6595\",
\"#	c white\",
\"$	c #c0c0c0\",
\"%	c grey\",
\"&	c #30C265959A69\",
\"*	c blue\",
\"                         \",
\"        .X      .        \",
\"       .X       .o       \",
\"      ..Xo.OO   XXo      \",
\"      .X.XXXooOXXXO      \",
\"      .X+X@XXooXXOO      \",
\"      XX#$$XXooOOO       \",
\"      %O@O#XXOOOO        \",
\"      .OoO#XXoOO         \",
\"   @ O..O$$XXooO         \",
\"  @ @O.XXXXXoOOO         \",
\" @ @@XoX..XOooO          \",
\"  @@@XXXOOOooO           \",
\"    oX+XXOOooo           \",
\"     +@O@XXXXo           \",
\"     o.Oo.@oO+           \",
\"      ooO..@oO           \",
\"        O+oOOOo       Oo \",
\"        .OoOooO        o \",
\"        ..XXooOOo    ooo \",
\"       ..o.+XooOOooOoo   \",
\"      O.oO  XXoOO+       \",
\" ##@O@OOOO    OoO+O      \",
\" $#&&&&o*+    &*+O       \",
\"    &&*Oo&  ##&+O&       \",
\"     &&+&&%#%&&&&+       \",
\"          %&&&*+         \",
\"                         \"};"
                                ]))

; (setq grep-find-command 
;       (replace-in-string grep-find-command "-e" "" 'literal-true))


;; nice in general and needed for appointment stuff
(display-time)

(defun mail-beep (&optional on-off)
  "Control mail arrival beep.  
Toggles state with ON-OFF 0 or 1 or interactively w/no argument.
Turn on  if on-off > 1 (e.g. One C-u interactively)
Turn off if on-off < 0 (e.g. C-u - interactively)"
  (interactive "p")
  (let ((hook-n-msg (if (> on-off 1)
			'(add-hook . "on")
		      (if (< on-off 0)
			  '(remove-hook . "off")
			;; toggle
			(if (memq 'dp-display-time-hook display-time-hook)
			    '(remove-hook . "off")
			  '(add-hook . "on"))))))
    (message "Mail beep is %s" (cdr hook-n-msg))
    (funcall (car hook-n-msg) 'display-time-hook 'dp-display-time-hook)))

(defun mail-beep-on ()
  "Turn mail beep on.  See also `mail-beep'."
  (interactive)
  (mail-beep 4))

(defun mail-beep-off ()
  "Turn mail beep off.  See also `mail-beep'."
  (interactive)
  (mail-beep -1))

;; turn off the ridiculous load meter
(setq display-time-form-list '(date time mail))			
;; pending-delete-mode causes typed text to replace a selection,
;; rather than append -- standard behavior under all window systems
;; nowadays. (copped from sample.init.el)
(when (fboundp 'pending-delete-mode)
  (pending-delete-mode 1)
  ;; kill the modeline display this mode
  (setq pending-delete-modeline-string " pD"))

(dmessage "xem-late: pre-command-hook>%s<" pre-command-hook)

;; @todo is this xemacs specific?
(setq-default
 modeline-format
 (list
  ""
  (if (boundp 'modeline-coding-system) 
      (cons 'modeline-coding-system-extent modeline-coding-system)
    (if (boundp 'modeline-multibyte-status) 
	'modeline-multibyte-status 
      ""))

  (cons modeline-modified-extent 'modeline-modified)
  (cons modeline-buffer-id-extent
	(list (cons modeline-buffer-id-left-extent
		    (cons 10 (list
			      (list 'line-number-mode "L%l")
			      (list 'column-number-mode " C%c"))))
	      " "
	      (list 24 (list modeline-buffer-id-right-extent "%b"))))
  " "
  'global-mode-string
  " %[("
  (cons modeline-minor-mode-extent
	(list "" 'mode-name 'minor-mode-alist))
  (cons modeline-narrowed-extent "%n")
  'modeline-process
  ")%]----"
  "%-"
  ))

(require 'executable)  ;; in XEmacs' sh-script package

;; set up speedbar to use exuberant ctags
;; if it is in our path
(let ((extags-bin (executable-find "exctags")))
  (when extags-bin
    (setq speedbar-fetch-etags-command extags-bin
	  speedbar-fetch-etags-arguments '("-f" "-"))))

(defun dp-setup-invisible-glyph (&optional file color)
  "Set up the glyph to use to indicate invisible text."
  (if (featurep 'xpm)
      (if file
          `[xpm :file ,file]
        `[xpm :data ,(format "\
/* XPM */
static char * delete_xpm[] = {
/* width height num_colors chars_per_pixel */
\"33 14 3 1\",
/* colors */
\" 	c white\",
\".	c none\",
\"X	c %s\",
/* pixels */
/*1...5....0....5....0....5....0...*/
\".................................\",
\".....XX ......XX ................\",
\".....XXXX....XX .................\",
\".......XXX .X ...................\",
\"........XXXXX ...................\",
\".........XXX ....................\",
\"........XXXXX ...................\",
\".......XXX .XX ..................\",
\"......XXX ...XX .................\",
\".....XXX .....X .................\",
\".....XXX ......X ..XXX..XXX..XXX.\",
\"......X ............XXX..XXX..XXX\",
\"................X ...X ...X ...X \",
\".................................\"}  ;" (or color "red"))
          ])
    (dp-ding-and-message "xpm not supported.")))

;;when did the name change? (defun dp-setup-invisible-glyph (&optional file color)
;;when did the name change?   (if (featurep 'xpm)
;;when did the name change?       ;; chuck is too tall, and can be very annoying.  So default is now a simple
;;when did the name change?       ;; string: [EOF].
;;when did the name change?       (add-hook 'find-file-hooks 'dp-add-default-buffer-endicator)
;;when did the name change?     (let ((file (expand-file-name "recycle2.xpm" data-directory)))
;;when did the name change?       (if (condition-case nil
;;when did the name change? 	      ;; check to make sure we can use the pointer.
;;when did the name change? 	      (make-image-instance file nil
;;when did the name change? 				   '(pointer))
;;when did the name change? 	    (error nil))		; returns nil if an error occurred.
;;when did the name change? 	  (set-glyph-image gc-pointer-glyph file)))))

(add-hook 'gdb-mode-hook (function (lambda () (require 'gdb-highlight))))

;;;
;;;
;;;
(provide 'dp-xemacs-late)
