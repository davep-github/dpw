(dmessage "eval-ing dp-cal.el...")

(defun dp-calendar-after-load-hook ()
  "Set up calendar mode with my preferences."
  (interactive)
  (if (dp-xemacs-p)
      (setq mark-diary-entries-in-calendar t)
    ;; flag? Flag? FLAG?  WTFUWT? Methinks they misspelled "-p".
    (setq calendar-mark-diary-entries-flag t))
  (add-hook 'calendar-today-visible-hook 'calendar-mark-today)
  (add-hook 'calendar-move-hook 'calendar-update-mode-line)
  (add-hook 'calendar-move-hook (lambda () (diary-view-entries 1)))

  ;; define-key is the recommended method vs local-set-key.
  (define-key calendar-mode-map [(meta left)] 'calendar-backward-month)
  (define-key calendar-mode-map [(meta right)] 'calendar-forward-month)
  (define-key calendar-mode-map [(control left)] 'calendar-backward-week)
  (define-key calendar-mode-map [(control right)] 'calendar-forward-week)
  (define-key calendar-mode-map [(meta ?a)] 'calendar-set-mark)
  (define-key calendar-mode-map [(meta ?d)] 'dp-appt-initialize-on)
  (define-key calendar-mode-map [(meta ?i)] 'dp-appt-initialize-on)
  (define-key calendar-mode-map [return] 'diary-view-entries)
  (define-key calendar-mode-map [(control meta a)] 'dp-appt-initialize-on)
  )

(defun dp-calendar-mode-hook ()
  (setq show-trailing-whitespace nil))

(defalias 'cal 'calendar)

;; fancy display is *REQUIRED* to make included files work.
(add-hook 'diary-display-hook 'fancy-diary-display)
(add-hook 'list-diary-entries-hook 'include-other-diary-files)
;; @todo XXX Alias one to the other.
(if (dp-xemacs-p)
    (add-hook 'mark-diary-entries-hook 'mark-included-diary-files)
  (add-hook 'mark-diary-entries-hook 'diary-mark-included-diary-files))
(add-hook 'appt-make-list-hook 'appt-included-diary-entries)

;; want sort to run after everything else
(add-hook 'list-diary-entries-hook 'sort-diary-entries 'APPEND)
(add-hook 'calendar-mode-hook 'dp-calendar-mode-hook)

(with-eval-after-load "calendar"
  (dp-calendar-after-load-hook))

(require 'calendar)
(require 'appt)

(defun dp-define-diary-keys ()
  (interactive)
  (dp-define-buffer-local-keys '("\C-c\C-c" dp-complete-diary-edit
                                 "\C-x#" dp-complete-diary-edit
				 [(meta ?-)] dp-bury-or-kill-buffer
				 [tab] tab-to-tab-stop
				 )
			       nil nil nil "dddfk"))

(defun dp-diary-mode-hook ()
  (interactive)
  (dp-define-diary-keys)
  (setq tab-stop-list (list 2 tab-width (* 2 tab-width))))

(add-hook 'diary-mode-hook 'dp-diary-mode-hook)

(defun dp-complete-diary-edit (&optional exit-too-p)
  "Finish editing the diary, exit and check for new appointments."
  (interactive)
  (when (buffer-modified-p)
    (save-buffer))
  (dp-appt-initialize-on)
  (if exit-too-p
      (when
          (call-interactively (key-binding [(meta ?-)])))
    (bury-buffer)))

(defadvice exit-calendar (before dp-exit-calendar activate)
  "Check for new appointments before exiting."
  (dp-appt-initialize-on))

(add-hook 'diary-hook 'dp-diary-hook)
(defvar dp-diary-hook-active-p nil
  "Provide exclusive access to appt initialization.")
(defun dp-diary-hook ()
  "Setup diary mode my way."
  (interactive)
  ;Make sure any entries are activated.  This by itself is not enough to
  ;ensure that new appointments are activated, since it is called BEFORE
  ;changes to the diary.  However it may catch some oversights.
  ;In the calendar, for convenience, M-d is defined as `dp-appt-initialize-on'.
  (unless dp-diary-hook-active-p
    (setq dp-diary-hook-active-p t)
    (dp-appt-initialize-on)
    (setq dp-diary-hook-active-p nil)))
;
; dp-appt-initialize loads the diary file, so this doesn't quite work.
;(defun dp-diary-kill-buffer-hook ()
;  (if (string= (expand-file-name (buffer-file-name))
;               (expand-file-name (dp-find-diary-file)))
;      (dp-appt-initialize)))
;(add-hook 'kill-buffer-hook 'dp-diary-kill-buffer-hook)

(autoload 'cal-tex-list-diary-entries "cal-tex"
  "Generate a list of all diary-entries from absolute date D1 to D2." nil)
  
(defmacro dp-define-date-function (name docstring &rest body)
  "Macro to generate functions which take convenient date args."
  (unless (stringp docstring)
    (setq body (cons docstring body))
    (setq docstring "Lazy bastard provided no doc."))
  `(defun ,name (&optional start-month end-month start-year 
			   end-year)
     ,docstring
     (interactive)
     (unless start-month
       (setq start-month (dp-current-month)))
     (unless end-month
       (setq end-month start-month))
     (unless start-year
       (setq start-year (dp-current-year)))
     (unless end-year
       (setq end-year start-year))
     ,@body
     ))
(put 'dp-define-date-function 'lisp-indent-hook 1)

(dp-define-date-function dp-get-diary-entries
  "Based on code in cal-tex.el"
  (cal-tex-list-diary-entries
   (calendar-absolute-from-gregorian (list start-month 1 start-year))
   (calendar-absolute-from-gregorian 
    (list end-month 
	  (calendar-last-day-of-month end-month end-year) end-year))))

(dp-define-date-function dp-diary-entries-to-pcal
  "Convert diary entries to pcal entries."
  (let ((appts (dp-get-diary-entries start-month end-month 
				     start-year end-year))
	(buf-name (generate-new-buffer-name "*pcal-output*")))
    (switch-to-buffer buf-name)
    (dp-erase-buffer)
    (dolist (diary-entry appts)
      (let ((date (third diary-entry))
	    (appt (second diary-entry)))
	;(dmessage "date>%s<, appt>%s<" date appt)
	(string-match "\\s-*\\(.*\\)" appt)
	(setq appt (match-string 1 appt))
	(insert (format "%s\t%s\n" date appt))))))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

(defvar appt-frame-defaults nil)
(defvaralias 'appt-screen-defaults 'appt-frame-defaults)

(defun appt-remove-appt (&optional appt)
  (interactive)
  (unless appt
    (setq appt appt-frame-appt))
  (when (member appt appt-time-msg-list)
    (setq appt-time-msg-list (delete appt appt-time-msg-list))))

(defun appt-complete-appt ()
  (interactive)
  (appt-remove-appt)
  (delete-frame appt-disp-frame)
  (setq appt-disp-frame nil
        appt-frame-appt nil))

(defvar appt-disp-frame nil
  "If non-nil, frame to display appointments in.")
(defvaralias 'appt-disp-screen 'appt-disp-frame)

(defvar appt-frame-appt nil
  "Last alarm announced in this frame/buffer.")
(make-variable-buffer-local 'appt-frame-appt)

(defun appt-frame-announce (min-to-app appt)
  "Set appt-announce-method to the name of this function to cause appointment 
notifications to be given via messages in a pop-up frame."
  (let ()
    (save-excursion
      (set-buffer (get-buffer-create appt-buffer-name))
      (dp-erase-buffer)
      ;; set the mode-line of the pop-up window
      (setq modeline-format 
            (concat "-------------------- Appointment "
                    (if (eq min-to-app 0)
                        "NOW"
                      (concat "in " (format "%s" min-to-app)
                              (if (eq min-to-app 1) " minute" " minutes")))
                    ". ("
                    (let ((h (string-to-int
                              (substring (current-time-string) 11 13))))
                      (concat (if (> h 12) (format "%s" (- h 12))
                                (format "%s" h)) ":"
                                (substring (current-time-string) 14 16)
                                (if (< h 12) "am" "pm")))
                    ") %-"))
      (insert (car (cdr appt)))
      (let ((kmap (copy-keymap (car (current-keymaps)))))
        (define-key kmap "\C-c\C-c" 'appt-complete-appt)
        (define-key kmap "q" 'delete-frame)
	;; (message "appt-frame-announce: %s" kmap)
        (use-local-map kmap))
      (setq appt-frame-appt appt)       ;record current appt for deletion later
      (let ((height (max 10 (min 20 (+ 2 (count-lines (point-min)
                                                      (point-max)))))))
        ;; If we already have a frame constructed, use it. If not, or it has
        ;; been deleted, then make a new one
        (if (and appt-disp-frame (frame-live-p appt-disp-frame))
            (let ((s (selected-frame)))
              (select-frame appt-disp-frame)
              (make-frame-visible appt-disp-frame)
              (set-frame-height appt-disp-frame height)
              (sit-for 0)
              (select-frame s))
          (progn
            (setq appt-disp-frame (make-frame))
            (set-frame-height appt-disp-frame height)
            )
          )
        ;; make the buffer visible in the frame 
        ;; and make the frame visible
        (let ((pop-up-windows nil))
          (pop-to-buffer (get-buffer appt-buffer-name) 
                         nil 
                         appt-disp-frame)
          (make-frame-visible appt-disp-frame))
        )
      )
    )
  )

;;;
;;; Being reworked...
;; (defstruct 
;;   (dp-split-time-string-struct
;;    (:constructor dp-cons-split-time-struct (day-name-tla 
;;                                             month-name-tla 
;;                                             day-of-month 
;;                                             hrs mins secs year)))
;;   day-name-tla
;;   month-name-tla
;;   day-of-month
;;   hrs
;;   mins
;;   secs
;;   year)

;; (defun* dp-split-time-string (&optional (time-string (current-time-string)))
;;   (interactive)
;;   (when (string-match
;;          (concat
;;           ;;       Day Name TLA    Mon(TLA)        Day'o'Month
;;           "^\\s-*\\(\\S-+\\)\\s-+\\(\\S-+\\)\\s-+\\([0-3]?[0-9]\\)\\s-+"
;;           ;; Hrs          Mins         Secs             Yee'ah.
;;           "\\([0-9]+\\):\\([0-9]+\\):\\([0-9]+\\)\\s-+\\([0-9]+\\)$")
;;          time-string)
;;     (loop for x from 1 to 7
;;            collect (match-string x time-string))))

;; (defun* dp-mk-split-time-struct (&optional (time-string (current-time-string)))
;;   (apply 'dp-cons-split-time-struct (dp-split-time-string)))

;; (defun* dp-mk-appt-time (&optional 
;;                          time-string (current-time-string) ts-set-p)
;;   (let ((ts (dp-mk-split-time-struct)))
;;     (format "%s:%s" 
;;             (dp-split-time-string-struct-hrs ts)
;;             (dp-split-time-string-struct-mins ts))))

;; (defvar dp-read-simple-appt-time-hist '()
;;   "The list of appointment times.")

;; (defun* dp-read-simple-appt-time (&optional
;;                                   (time-string (current-time-string) ts-set-p)
;;                                   prompt)
;;   (let ((ts (dp-mk-appt-time time-string)))
;;     (read-from-minibuffer 
;;      (or prompt
;;          (format
;;           "Initial appt time (HH:MM[am|pm]) [default(now): %s]: " 
;;           ts))
;;      nil nil nil 
;;      'dp-read-simple-appt-time-hist
;;      nil
;;      ts)))

;; (defun* dp-get-appt-time (&optional 
;;                           (time-string (current-time-string) ts-set-p))
;;   (interactive (list (dp-read-simple-appt-time)))
;;   (if (interactive-p)
;;       time-string
;;     (let ((ts (dp-mk-split-time-struct)))
;;       (format "%s:%s" 
;;               (dp-split-time-string-struct-hrs ts)
;;               (dp-split-time-string-struct-mins ts)))))

;; (defun dp-read-add-periodic-appt-params ()
;;   (list (read-from-minibuffer "Message: ")
;;         (read-number "Interval in hours (can be fractional): ")
;;         :time-of-first-appt (dp-read-simple-appt-time)
;;         :num (if current-prefix-arg
;;                  (prefix-numeric-value current-prefix-arg)
;;                (read-number "Number of appts [default: 4]: " t "4"))
;;         :msg-fmt-args nil))

;; (defun* dp-add-periodic-appt (msg-fmt period 
;;                                &key 
;;                                (time-of-first-appt (dp-mk-appt-time)) 
;;                                (num 4 num-set-p)
;;                                (msg-fmt-args nil))
;;   (interactive (dp-read-add-periodic-appt-params))
;;   (dmessage 
;;    "msg-fmt: %s, period: %s, time-of-first-appt: %s, num: %s, msg-fmt-args: %s"
;;    msg-fmt period time-of-first-appt num msg-fmt-args)
;;   (loop for x to (1- num)
;;     with first-appt-time = (cond
;;                             ((stringp time-of-first-appt)
;;                              (date-to-time time-of-first-appt))
;;                             ((null time-of-first-appt) (current-time))
;;                             (t time-of-first-appt))
;;     with delta = 0 do
;;     (appt-add (dp-appt-time-hours-from (* x period) first-appt-time)
;;               (apply 'format (format "%s [periodic]" msg-fmt) msg-fmt-args)))
;;   appt-time-msg-list)

;; (defun dp-neurontin-appts (start-time)
;;   (interactive (list (dp-read-simple-appt-time)))
;;   (dp-add-periodic-appt "Neurontin" 4.0 :num 4 :time-of-first-appt start-time))

;;;
;;;
;;;
(dmessage "eval-ing dp-cal.el done.")
(provide 'dp-cal)
