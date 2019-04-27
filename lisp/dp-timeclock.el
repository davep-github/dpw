;;;
;;;
;;; Setup for *macs' timeclock facility, and my carpe deim code.
;;;
(require 'timeclock)
(timeclock-modeline-display)

;;; HACK/PATCH.
;; This guy barfs when inserting a project name of nil.  It seems that other
;; places in the code (e.g. timeclock-in) should prompt for a non-nil name,
;; but we still can end up here with a project's name being nil.  I'm sure
;; it's a config error on my part.
;; A hack here, to get past the error is to insert (format "%s" project) vs
;; just project.  This stringizes and makes insert happier.
(defun timeclock-generate-report (&optional html-p)
  "Generate a summary report based on the current timelog file.
By default, the report is in plain text, but if the optional argument
HTML-P is non-nil, HTML markup is added."
  (interactive)
  (let ((log (timeclock-log-data))
	(today (timeclock-day-base)))
    (if html-p (insert "<p>"))
    (insert "Currently ")
    (let ((project (format "%s" (nth 2 timeclock-last-event)))
	  (begin (nth 1 timeclock-last-event))
	  done)
      (if (timeclock-currently-in-p)
	  (insert "IN")
	(if (or (null project) (= (length project) 0))
	    (progn (insert "Done Working Today")
		   (setq done t))
	  (insert "OUT")))
      (unless done
	(insert " since " (format-time-string "%Y/%m/%d %-I:%M %p" begin))
	(if html-p
	    (insert "<br>\n<b>")
	  (insert "\n*"))
	(if (timeclock-currently-in-p)
	    (insert "Working on "))
	(if html-p
	    (insert project "</b><br>\n")
	  (insert project "*\n"))
	(let ((proj-data (cdr (assoc project (timeclock-project-alist log))))
	      (two-weeks-ago (timeclock-seconds-to-time
			      (- (timeclock-time-to-seconds today)
				 (* 2 7 24 60 60))))
	      two-week-len today-len)
	  (while proj-data
	    (if (not (time-less-p
		      (timeclock-entry-begin (car proj-data)) today))
		(setq today-len (timeclock-entry-list-length proj-data)
		      proj-data nil)
	      (if (and (null two-week-len)
		       (not (time-less-p
			     (timeclock-entry-begin (car proj-data))
			     two-weeks-ago)))
		  (setq two-week-len (timeclock-entry-list-length proj-data)))
	      (setq proj-data (cdr proj-data))))
	  (if (null two-week-len)
	      (setq two-week-len today-len))
	  (if html-p (insert "<p>"))
	  (if today-len
	      (insert "\nTime spent on this task today: "
		      (timeclock-seconds-to-string today-len)
		      ".  In the last two weeks: "
		      (timeclock-seconds-to-string two-week-len))
	    (if two-week-len
		(insert "\nTime spent on this task in the last two weeks: "
			(timeclock-seconds-to-string two-week-len))))
	  (if html-p (insert "<br>"))
	  (insert "\n"
		  (timeclock-seconds-to-string (timeclock-workday-elapsed))
		  " worked today, "
		  (timeclock-seconds-to-string (timeclock-workday-remaining))
		  " remaining, done at "
		  (timeclock-when-to-leave-string) "\n")))
      (if html-p (insert "<p>"))
      (insert "\nThere have been "
	      (number-to-string
	       (length (timeclock-day-alist log)))
	      " days of activity, starting "
	      (caar (last (timeclock-day-alist log))))
      (if html-p (insert "</p>"))
      (when html-p
	(insert "<p>
<table>
<td width=\"25\"><br></td><td>
<table border=1 cellpadding=3>
<tr><th><i>Statistics</i></th>
    <th>Entire</th>
    <th>-30 days</th>
    <th>-3 mons</th>
    <th>-6 mons</th>
    <th>-1 year</th>
</tr>")
	(let* ((day-list (timeclock-day-list))
	       (thirty-days-ago (timeclock-seconds-to-time
				 (- (timeclock-time-to-seconds today)
				    (* 30 24 60 60))))
	       (three-months-ago (timeclock-seconds-to-time
				  (- (timeclock-time-to-seconds today)
				     (* 90 24 60 60))))
	       (six-months-ago (timeclock-seconds-to-time
				(- (timeclock-time-to-seconds today)
				   (* 180 24 60 60))))
	       (one-year-ago (timeclock-seconds-to-time
			      (- (timeclock-time-to-seconds today)
				 (* 365 24 60 60))))
	       (time-in  (vector (list t) (list t) (list t) (list t) (list t)))
	       (time-out (vector (list t) (list t) (list t) (list t) (list t)))
	       (breaks   (vector (list t) (list t) (list t) (list t) (list t)))
	       (workday  (vector (list t) (list t) (list t) (list t) (list t)))
	       (lengths  (vector '(0 0) thirty-days-ago three-months-ago
				 six-months-ago one-year-ago)))
	  ;; collect statistics from complete timelog
	  (while day-list
	    (let ((i 0) (l 5))
	      (while (< i l)
		(unless (time-less-p
			 (timeclock-day-begin (car day-list))
			 (aref lengths i))
		  (let ((base (timeclock-time-to-seconds
			       (timeclock-day-base
				(timeclock-day-begin (car day-list))))))
		    (nconc (aref time-in i)
			   (list (- (timeclock-time-to-seconds
				     (timeclock-day-begin (car day-list)))
				    base)))
		    (let ((span (timeclock-day-span (car day-list)))
			  (len (timeclock-day-length (car day-list)))
			  (req (timeclock-day-required (car day-list))))
		      ;; If the day's actual work length is less than
		      ;; 70% of its span, then likely the exit time
		      ;; and break amount are not worthwhile adding to
		      ;; the statistic
		      (when (and (> span 0)
				 (> (/ (float len) (float span)) 0.70))
			(nconc (aref time-out i)
			       (list (- (timeclock-time-to-seconds
					 (timeclock-day-end (car day-list)))
					base)))
			(nconc (aref breaks i) (list (- span len))))
		      (if req
			  (setq len (+ len (- timeclock-workday req))))
		      (nconc (aref workday i) (list len)))))
		(setq i (1+ i))))
	    (setq day-list (cdr day-list)))
	  ;; average statistics
	  (let ((i 0) (l 5))
	    (while (< i l)
	      (aset time-in i (timeclock-geometric-mean
			       (cdr (aref time-in i))))
	      (aset time-out i (timeclock-geometric-mean
				(cdr (aref time-out i))))
	      (aset breaks i (timeclock-geometric-mean
			      (cdr (aref breaks i))))
	      (aset workday i (timeclock-geometric-mean
			       (cdr (aref workday i))))
	      (setq i (1+ i))))
	  ;; Output the HTML table
	  (insert "<tr>\n")
	  (insert "<td align=\"center\">Time in</td>\n")
	  (let ((i 0) (l 5))
	    (while (< i l)
	      (insert "<td align=\"right\">"
		      (timeclock-seconds-to-string (aref time-in i))
		      "</td>\n")
	      (setq i (1+ i))))
	  (insert "</tr>\n")

	  (insert "<tr>\n")
	  (insert "<td align=\"center\">Time out</td>\n")
	  (let ((i 0) (l 5))
	    (while (< i l)
	      (insert "<td align=\"right\">"
		      (timeclock-seconds-to-string (aref time-out i))
		      "</td>\n")
	      (setq i (1+ i))))
	  (insert "</tr>\n")

	  (insert "<tr>\n")
	  (insert "<td align=\"center\">Break</td>\n")
	  (let ((i 0) (l 5))
	    (while (< i l)
	      (insert "<td align=\"right\">"
		      (timeclock-seconds-to-string (aref breaks i))
		      "</td>\n")
	      (setq i (1+ i))))
	  (insert "</tr>\n")

	  (insert "<tr>\n")
	  (insert "<td align=\"center\">Workday</td>\n")
	  (let ((i 0) (l 5))
	    (while (< i l)
	      (insert "<td align=\"right\">"
		      (timeclock-seconds-to-string (aref workday i))
		      "</td>\n")
	      (setq i (1+ i))))
	  (insert "</tr>\n"))
	(insert "<tfoot>
<td colspan=\"6\" align=\"center\">
  <i>These are approximate figures</i></td>
</tfoot>
</table>
</td></table>")))))

(defun dp-setup-timeclock ()
  "Setup my timeclock since my hours are so variable."
  ;; Only do this once each day.
  (add-hook 'timeclock-first-in-hook 'dp-setup-meds-appts)
  (timeclock-in)
  )

(add-hook 'dp-post-dpmacs-hook
	  (lambda ()
	    (run-with-timer 10 nil 'dp-setup-timeclock)))


;;;
;;;------------------------------- Carpe Deim ------------------------------
;;;
;;;
;;; Carpe Diem code.
;;;
(defcustom dp-wakeup-idle-time (* 5 60 60)
  "Consider it a new day if this much time elapses between commands."
  :group 'dp-vars
  :type 'integer)

(defvar dp-wakeup-idle-itimer nil
  "The itimer we're using for wakeup actions.")

(defconst dp-wakeup-greeting
  "Hello, Dave; I knew you'd be back. Carpe deim?")

(defconst dp-cd-wakeup-confirmation-function 'yes-or-no-p
  "How do we ask for a yes or no answer?
Another obvious option is `y-or-n-p'.  What ever it is must take a prompt
string and return non-nil for a yes type response.")

(defun dp-cd-add-wakeup-command-hook (hook-func)
  (add-one-shot-hook 'pre-command-hook hook-func))

(defun dp-cd-wakeup-command-hook ()
  "Called at first command after we've idled out."
  (if (not (funcall dp-cd-wakeup-confirmation-function dp-wakeup-greeting))
      ;; We've only been away from our desk rather than gone home.
      (message "Long meeting?")
    (run-hooks 'dp-cd-wakeup-hook)
    (dmessage "new day... log us out as of the idle timer's start.")
    (dmessage "  and log us back in again.")
    (dp-cd-start-idle-timer)))

(defvar dp-cd-wakeup-hook '()
  "Our \"morning\" routine.")

(defvar dp-cd-idle-timer-set nil
  "When did we last set the idle timer?")

(defvar dp-cd-idle-timer-fire nil
  "When did the idle timer last go off?")

;; The last activity was at idle-timer-fire - wakeup-time
;; Does the itimer facility have an interface to get this value?

(defun dp-cd-idle-handler ()
  ;; The idle handler has fired. Make sure we don't get another one until
  ;; after we've gone active again.
  (dp-cd-safe-delete-idle-timer)
  ;; For now, we're adding a one-shot command hook to catch the next session
  ;; beginning.
  (dp-cd-add-wakeup-command-hook))

(defun* dp-cd-safe-delete-idle-timer (&optional (itimer 'dp-wakeup-idle-itimer))
  (when (symbol-value itimer)
    (delete-itimer (symbol-value itimer))
    (set itimer nil)))

(defun dp-cd-start-idle-timer (&optional wakeup-time)
  "As in the first time I use xemacs after I wake up.
Do things like setup meds appointments relative to wake up time."
  (setq-ifnil wakeup-time dp-wakeup-idle-time)
  ;; Delete any existing timer.  This can be called anytime to reset itself.
  (dp-cd-safe-delete-idle-timer dp-wakeup-idle-itimer)
  (setq dp-wakeup-idle-itimer
        (run-with-idle-timer wakeup-time nil 'dp-cd-idle-handler)))

(add-hook 'dp-post-dpmacs-hook 'dp-cd-start-idle-timer)

(provide 'dp-timeclock)
