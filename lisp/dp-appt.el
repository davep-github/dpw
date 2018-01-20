;;;
;;; My hacks to the appointment (appt.el) stuff.
;;;

(defvar dp-setup-meds-appts-p nil
  "Should the medical appointments be made?")

(defvar dp-appt-creation-hooks '()
  "Hooks to create appts.  Mostly for calculated appts.
When exiting `calendar' I reinit the appts.  This removes all appts and then
creates only those in the diary file.  So we can call these to restore
non-diary-file appts.")

(defun dp-use-v2-appt-stuff-p ()
  (or (bound-and-true-p dp-use-new-appt-code-p)
      (not (fboundp 'appt-frame-announce))))

(defun dp-appt-initialize ()
  "An interactive function for [re]initializing the appointment list."
  (interactive)
  ;; Some substantial (and fatal to me) changes were made 1998 <= yr <= 2007.
  ;; eg, `appt-initialize' is an alias of `appt-activate', but old
  ;; appt-initialize did unconditional activation and took no param.
  ;; This is common and should work in all cases
  (if (dp-use-v2-appt-stuff-p)
      (appt-check t)
    (appt-check))
  (run-hooks 'dp-appt-creation-hooks))

;;(add-hook 'appt-make-list-hook 'dp-appt-initialize)

(dp-deflocal dp-appt-frame-appt nil
  "Appt that lives in this frame.")

(defun dp-appt-remove-appt (&optional appt)
  (interactive)
  (setq-ifnil appt dp-appt-frame-appt)
  (when (memq appt appt-time-msg-list)
    (message "Removed appointment from alarm list.")
    (setq appt-time-msg-list (delq appt appt-time-msg-list)))
  (setq dp-appt-frame-appt nil))

(defun dp-appt-frame-announce (min-to-app appt)
  "Display an appointment notification in a frame.  
This fixes the original function `appt-frame-announce' 
by making it display the buffer containing the appointment 
info in the popped up frame."
  (dmessage "`dp-appt-frame-announce' called")
  (warn "`dp-appt-frame-announce' called")
  (appt-frame-announce min-to-app appt)
  (setq dp-appt-frame-appt appt)
  (let ((pop-up-windows nil))
    (pop-to-buffer (get-buffer-create appt-buffer-name) 
		   nil 
		   appt-disp-frame)
    (make-frame-visible appt-disp-frame)
    (dp-define-buffer-local-keys '("\C-c\C-c" dp-appt-dismiss-appt
                                   "Q" dp-appt-dismiss-appt
                                   "X" dp-appt-dismiss-appt
                                   "C" dp-appt-dismiss-appt)
				 nil nil nil "dafa")))

(defun dp-appt-add-appt (appt)
  (apply 'appt-add appt)
  (apply 'dp-appt-make-v2-appt appt))

(defun dp-add-list-of-appts (appt-list &optional adder)
  "Add each appointment in APPT-LIST to appointments. nil APPT-LIST is OK.
Returns appt-list so it can be squirreled away if needed."
  (setq-ifnil adder 'dp-appt-add-appt)
  (prog1
      (loop for appt in appt-list 
        collect (funcall adder appt))
    (appt-check)))

(defun dp-appt-v1-setup ()
  (defun dp-appt-dismiss-appt ()
    (interactive)
    (dp-appt-remove-appt)
    (delete-frame appt-disp-frame)
    (setq appt-disp-frame nil
          appt-frame-appt nil)
    (message "Deleted appointment's alarm frame(v1).")))

(defun dp-appt-v2-setup ()
  (dp-deflocal dp-appt-expired-appt-buf nil
    "Has the appointment passed w/o being dismissed?")
  (defvar dp-appt-expired-appt-buffer-name 
    "******* APPOINTMENT HAS BEEN and GONE *******"
    "Buffer base name for expired appts.")
  
  (defvar dp-appt-current-appts '()
    "List of most current/active appts we are dealing with.")
  
  (defvar dp-appt-frame-we-made nil
    "If we create a new frame below, this is it.")
  
  (defvar dp-appt-zombie-windows '()
    "Reminder windows that haven't been dismissed yet.")
  
  (defun dp-appt-zombie-p (&optional buffer)
    (memq (or buffer (current-buffer)) dp-appt-zombie-windows))
  
  (defun dp-appt-remove-zombie (&optional buffer)
    (setq dp-appt-zombie-windows (delq (or buffer (current-buffer)) 
                                       dp-appt-zombie-windows)))

  (defun dp-appt-zombify-buffer (&optional buffer)
    (add-to-list 'dp-appt-zombie-windows (or buffer (current-buffer)))
    ;; Keep this last reminder up until the SOB closes it.
    ;; Or for, say, 2.78352 hrs?
    (setq dp-appt-expired-appt-buf t)
    (let ((orig-name (buffer-name)))
      ;; Steal the appointment buffer by renaming it uniquely.
      (rename-buffer dp-appt-expired-appt-buffer-name t)
      (calendar-set-mode-line " LAST REMINDER... press Q to dismiss. ")
      ;; Make one for to be deleted.
      (get-buffer-create orig-name)))

  (defun dp-appt-last-reminder-p (min-to-app)
    "Somehow we need to be able to detect whether a reminder is the last or not."
    (zerop (string-to-int min-to-app)))
  
  (defun dp-appt-disp-window (min-to-appt time-string appt-text)
    (let ((frame (or (and (eq (next-frame) (selected-frame))
                          (setq dp-appt-frame-we-made (make-frame)))
                     (next-frame)))
          zombie)
      (set-frame-height frame 27)
      (select-frame frame)
      (raise-frame frame)
      ;; Don't want to type into this window if I can help it.
      ;;(focus-frame frame)
      (select-window (frame-root-window frame))
      (funcall (dp-get-orig-value 'appt-disp-window-function)
               min-to-appt time-string appt-text)
      ;; We always seem to be left in the "other" window.
      (delete-window)
      ;;!<@todo Is the current appt always the `car' of this list?
      (setq dp-appt-frame-appt (car appt-time-msg-list))
      ;; Log the appt for logging's sake.  Actually it's good if an appt is
      ;; accidentally dismissed or lost from view in some other way.
      (dmessage "dp-appt-disp-window: %s" dp-appt-frame-appt)
      (dp-define-buffer-local-keys '("\C-c\C-c" dp-appt-dismiss-appt
                                     "Q" dp-appt-dismiss-appt
                                     "X" dp-appt-dismiss-appt
                                     "C" dp-appt-dismiss-appt)
				   nil nil nil "dadw")
      (when (setq zombie (dp-appt-last-reminder-p min-to-appt))
        (dp-appt-zombify-buffer zombie))
      (set-buffer-dedicated-frame (current-buffer) frame)
      (set-buffer-modified-p nil)
      (dp-toggle-read-only 1)
      (dp-shrink-wrap-frame frame)))
  
  (defun dp-appt-delete-frame-old ()
    (when (and dp-appt-frame-we-made
               (frame-live-p dp-appt-frame-we-made))
      (let ((dp-confirm-frame-deletion-p nil))
        (delete-frame dp-appt-frame-we-made)
        (setq dp-appt-frame-we-made nil)
        (message "Deleted appointment's alarm frame."))))
  
  (defun dp-appt-delete-frame ()
    (when (and dp-appt-frame-we-made
               (frame-live-p dp-appt-frame-we-made))
      (let ((dp-confirm-frame-deletion-p nil))
        (delete-frame dp-appt-frame-we-made)
        (setq dp-appt-frame-we-made nil)
        (message "Deleted appointment's alarm frame."))))
  
  (defun dp-appt-delete-window-old (&rest rest)
    (if (dp-appt-zombie-p)
        (progn
          ;; Keep this last reminder up until the SOB closes it.
          ;; Or for, say, 2.78352 hrs?
          (setq dp-appt-expired-appt-buf t)
          (let ((orig-name (buffer-name)))
            ;; Steal the appointment buffer by renaming it uniquely.
            (rename-buffer dp-appt-expired-appt-buffer-name t)
            (calendar-set-mode-line " LAST REMINDER... press Q to dismiss. ")
            ;; Make one for to be deleted.
            (get-buffer-create orig-name)
            (dp-appt-remove-zombie)))
      (apply (dp-get-orig-value 'appt-delete-window-function) rest)
      (dp-appt-delete-frame)))
  
  (defun dp-appt-delete-window (&rest rest)
    (apply (dp-get-orig-value 'appt-delete-window-function) rest)
    (dp-appt-delete-frame))

  (defun dp-appt-dismiss-appt-old ()
    (interactive)
    (dp-appt-remove-appt)
    (dp-appt-delete-frame)
    (setq dp-appt-frame-appt nil))

  (defun dp-appt-dismiss-appt ()
    (interactive)
    (dp-appt-remove-appt)
    (dp-appt-delete-window)
    (let ((zbuf (dp-appt-zombie-p)))
      (when zbuf
        (dp-kill-buffer zbuf)))
    (dp-appt-delete-frame)
    (setq dp-appt-frame-appt nil))

  
  (dp-save-orig-n-set-new 'appt-disp-window-function
                          (cons 'dp-appt-disp-window 'literal))
  (dp-save-orig-n-set-new  'appt-delete-window-function 
                           (cons 'dp-appt-delete-window 'literal)))


(if (dp-use-v2-appt-stuff-p)
    (dp-appt-v2-setup)
  (dp-appt-v1-setup))

;; 
(defun dp-appt-make-v1-appt (time msg &optional specifier)
  "Make an OLD STYLE/internal appt.el compatible appointment.
Appts look thus: \(new-appt-time new-appt-message\). See `appt-add'.
e.g. ((1320) \"10:00pm: test\"."
  (list (list (appt-convert-time (format-time-string "%I:%M%p" time))) msg))

(defun dp-appt-make-v2-appt (new-appt-time new-appt-msg)
  "Copped from `appt-add'.  C'mon people, it's a *functional* language."
  (list (list (appt-convert-time new-appt-time))
        (concat new-appt-time " " new-appt-msg) t))

(defun* dp-mk-appt-list (delta-list description
                         &optional msg-func-arg-list 
                         (from-time 'zero))
  "DELTA-LIST is list of time differences from FROM-TIME.
MSG-FUNC is called with the appointment time (in appt time fmt -- HH:MM:SS of
the current day (i.e. before midnight)) and MSG-FUNC-ARG-LIST.  It should
return the string used to describe the appt."
  (interactive "NNumber of appointments: \nnPeriod: ")
  (setq from-time (dp-*-to-time-val from-time))
  (let ((saved-description description))
    (loop for tm in (dp-mk-offset-time-list delta-list from-time)
      collect (list (format-time-string "%T" tm)
                    (cond
                     ((functionp 'description)
                      (apply description msg-func-arg-list))
                     ((and description
                           (listp description))
                      (prog1
                          (car description)
                        (setq description (cdr description))
                        ;; Wrap if needed.
                        (setq-ifnil description saved-description)))
                     (description (format "%s" description))
                     (t "Appointment"))))))

(defun* dp-mk-neurontin-appt-list (num &optional (period 4)
                                   (from-time (current-time))
                                   offset
                                   include-zeroth-p)
  (interactive "NNum: ")
  (dp-mk-appt-list (dp-mk-periodic-time-val-list num period from-time
                                                 offset
                                                 include-zeroth-p)
                   "Neurontin[automagic]"))

(defstruct dp-Neurontin-appt-info
  creation-args
  appt-list)

(defvar dp-neurontin-appt-info nil
  "Saved lists of neurontin appts keyed by args so it can be recreated at will.
When args change, make new list and remember the new one.  
!<@todo Or do we want an alist keyed by creation-args for all invocations?
This is needed because elisp has no closures which means we can't just define
a recreator function at creation time using the original creation args.")

(defvar dp-current-neurontin-appts '()
  "So we can nuke the previous list of appts when adding a new list..")

(defun dp-remove-appts (appt-list)
  (mapc (function (lambda (appt)
                    (setq appt-time-msg-list (delete appt appt-time-msg-list))))
        appt-list))

(defun dp-add-neurontin-appts (&optional keep-old-p)
  "Re-submit the neurontin appointments.  
Non-diary appts need to be remade after processing the diary into appts.
!<@todo Extend this to handle any kind of list like this."
  (interactive)
  (unless keep-old-p
    (dp-remove-appts dp-current-neurontin-appts))
  (setq dp-current-neurontin-appts
        (dp-add-list-of-appts (and dp-neurontin-appt-info
                                   (dp-Neurontin-appt-info-appt-list 
                                    dp-neurontin-appt-info)))))

(defun* dp-mk-neurontin-appts0 (num keep-existing-p &optional
                                (timeval-of-first (current-time))
                                (period 4) (include-zeroth-p t))
  (interactive "NNum: \nP")
  (when include-zeroth-p
    ;; Move start time forward a bit so the zeroth appt will be seen.
    (setq timeval-of-first (dp-timeval-after 123 timeval-of-first)))
  (let ((creation-args (list (1+ num) period timeval-of-first 'zero
                             include-zeroth-p)))
    (unless (and keep-existing-p
                 dp-neurontin-appt-info
                 (equal creation-args 
                               (dp-Neurontin-appt-info-creation-args 
                                dp-neurontin-appt-info)))
      ;; Changed or new.
      (setq dp-neurontin-appt-info 
            (make-dp-Neurontin-appt-info
             :creation-args creation-args
             :appt-list (apply 'dp-mk-neurontin-appt-list creation-args)))
      (dp-add-neurontin-appts))
    ;;???(dp-Neurontin-appt-info-appt-list dp-neurontin-appt-info)
    (add-hook 'dp-appt-creation-hooks 'dp-add-neurontin-appts)))

(defun* dp-mk-neurontin-appts (keep-existing-p &optional
                               (timeval-of-first (current-time))
                               (number-of-reminders 3)
                               (period 4))
  (interactive "P")
  (if (interactive-p)
      (call-interactively 'dp-mk-neurontin-appts0)
    (dp-mk-neurontin-appts0 number-of-reminders
                            keep-existing-p
                            timeval-of-first
                            period)))

;; From diary-persistent:
;; &*/*/*
;; 10:00pm take Neurontin

(when (bound-and-true-p dp-setup-meds-appts-p)
  (defun dp-setup-meds-appts (&optional timeval-of-first keep-existing-p)
    (interactive)
    ;; Or hours till first...
    (dmessage "Timeval of first appt will be first `timeclock-in'.")
    (when (integerp timeval-of-first)
      (setq timeval-of-first (dp-timeval-after timeval-of-first)))
    (setq-ifnil timeval-of-first (current-time))
    ;; 3x appts 4hrs apart with first defaulted to 10am.
    ;;(warn "Round TO to some 24 hr time... e.g. 1:20pm --> 13 (or 13:30))")
    (dp-mk-neurontin-appts keep-existing-p timeval-of-first))
  
  ;; Set up appts after we're up since windows coming and going during init
  ;; cause problems.
  (add-hook 'dp-post-dpmacs-hook 
            (lambda ()
              (run-at-time (format "%d sec" appt-display-duration) 
                           nil 'dp-setup-meds-appts))))

;;
;; set up the appointment stuff.
(defun dp-activate-appts ()
  "Initiate appointment processing."
  (interactive)
  (if (not (dp-find-diary-file))
      (message "No diary file found.")
    (message "Using `%s' as diary file." diary-file)
    (condition-case dummy
	(progn
	  (when (dp-xemacs-p)
	    (appt-initialize)
	    (setq appt-announce-method 'dp-appt-frame-announce)
	    ;;(setq appt-announce-method 'appt-frame-announce)
	    (message "Alarms for appointments enabled.")))
	(message "Appt module not available."))
      ;; switch to the following if the patch is accepted
    ;;
    ))

(provide 'dp-appt)
