(defun dp-timeval-after (float-seconds &optional after)
  "Return a timeval representing the timeval FLOAT-SECONDS from now."
  (seconds-to-time (+ (time-to-seconds (or after
                                           (current-time))) float-seconds)))

(defun dp-seconds-at-last-midnight ()
  "How many seconds has it been since midnight?"
  (- (time-to-seconds (current-time))
     (* 60 (dp-mins-since-midnight))))

(defun dp-mins-since-midnight (&optional from-timeval)
  "Copped from `time-check'"
  (let* ((now (decode-time from-timeval))
	       (cur-hour (nth 2 now))
	       (cur-min (nth 1 now))
	       (mins (+ (* cur-hour 60) cur-min)))
  mins))

(defun dp-hours-since-midnight (&optional to)
  "Simplistic way to determine the fractional number of hours24 since midnight.
I'm sure I'm missing some existing means of doing this."
  (setq-ifnil to (current-time))
  (+ (string-to-number (format-time-string "%H" to))
     ;; We need to force base 10 since %M annoyingly returns 00-59
     (/ (string-to-number (format-time-string "%M" to) 10)
        60.0)))

(defun dp-timeval-since-midnight (&optional to)
  "Simplistic way to determine the timeval number of hours24 since midnight.
I'm sure I'm missing some existing means of doing this."
  )

(defun dp-hours-since (time)            ; &optional now)
  "Compute elapsed hours since TIME."
  (/ (time-to-seconds (time-since time)) 60 60))

(defun dp-hours-since-string (time &optional format-string)
  (format (or format-string "%3.2f") 
          (dp-hours-since time)))

(defun dp-time-to-hours (&optional time-val)
  "Since the epoch to TIME-VAL or now(tm)."
  (/ (time-to-seconds (or time-val (current-time))) 60 60))

(defun dp-hours-to-time (delta-hours)
  "Convert hours to a diff time val."
  (seconds-to-time (* delta-hours 60.0 60.0)))

(defun dp-time-hours-from (delta-hours &optional from)
  (time-add (or from (current-time)) (dp-hours-to-time delta-hours)))

(defun dp-appt-24hrtime-hours-from (hours &optional from)
  "Convert `dp-time-hours-from' to a string that `appt-add' likes.
FROM inherits `dp-time-hours-from' default value (q.v)."
  (format-time-string "%T" (dp-time-hours-from hours from)))

(defun dp-1/4-hours-string (hours format-string)
  (format format-string
          hours
          (dp-round-to-1/4-hr hours)))

(defun dp-1/4-hours-since-string (time format-string)
  (dp-1/4-hours-string (dp-hours-since time) format-string))

(defvar dp-def-time-log-file-name (concat (getenv "HOME") "/log/login-times")
  "File in which to log times, e.g. for contractor\(blecch) hours.")

(defvar dp-std-start-stamp "start: xemacs"
  "What we use to time stamp our start up with.")

(defun dp-log-message-to-file (log-file-name message &optional tmp-buf)
  (interactive "FFile: \nsmessage: \nP")
  (with-current-buffer (get-buffer-create (or tmp-buf
                                              " *dp Log Buffer*"))
    (erase-buffer)
    (insert message)
    (append-to-file (point-min) (point-max) 
                    (or log-file-name dp-def-time-log-file-name))
    message))
  
(defun dp-log-mk-std-time-string (&optional time)
  (format "%s" 
          (format-time-string dp-std-format-time-string-format
                              (or time (current-time)))))

(defun dp-log-time-to-file (message &optional time log-file-name buf-name)
  "Write a message and a timestamp to a file."
  (interactive "smessage: ")
  (if (dp-in-exe-path-p "log-time")
      (shell-command-to-string (format "LOG_TIME_DATE='%s' log-time %s: "
				       (if time ;and nil time )
                                           (dp-log-mk-std-time-string time)
					 "")
				       message))
      (dp-log-message-to-file 
       (or log-file-name dp-def-time-log-file-name)
       (format "%s -- %s\n" message (current-time-string time))
       (or buf-name " *dp Time Log Buffer*"))
      nil))

(defun dp-get-first-emacs-start-time-string (&optional start-stamp)
  (interactive)
  (let ((ts (shell-command-to-string 
            (format "log-time -1 %s -d -"
                    (or "Logical"
		     start-stamp dp-std-start-stamp)))))
    (posix-string-match 
     "\\(\\(Wed\\|Thu\\|Fri\\|Sat\\|Sun\\|Mon\\|Tue\\).*\\) --"
     ts)
    (match-string 1 ts)))

(defun dp-get-first-emacs-start-time ()
  (interactive)
  (date-to-time (dp-get-first-emacs-start-time-string)))

(defun dp-date-cmd-diff (date-string-1 date-string-2)
  "Compute difference between 2  `/bin/date' type output strings.
e.g.: Mon Dec 11 14:48:17 EST 2006 - Mon Dec 11 11:19:27 EST 2006."
  (interactive "stime string1: \nstime string2: ")
  (let ((ds1 (date-to-time date-string-1))
        (d21 (date-to-time date-string-2))
        tmp)
    (when (time-less-p ds1 ds2)
      (setq tmp ds1
            ds1 ds2
            ds2 tmp))
    (time-to-seconds (time-subtract (date-to-time ds1)
                                    (date-to-time ds2)))))

(defun dp-date-cmd-diff-as-hours (date-string-1 date-string-2)
  "Compute `dp-date-cmd-diff' on DATE-STRING-2 AND DATE-STRING-2 as hours."
  (interactive "stime string1: \nstime string2: ")
  (/ (dp-date-cmd-diff date-string-1 date-string-2) 60 60))

(defun* dp-timevalue-at-time (hrs24 &optional (minutes 0) (seconds 0) 
                              base-timeval)
  "Return a time value for hrs24:min:sec on the same day as BASE-TIMEVAL.
The default is to set time to hrs24:0:0."
  (apply 'encode-time seconds minutes hrs24 
         (cdddr (decode-time (or base-timeval (current-time))))))

(defun dp-time-val-p (time)
  "Very simplistic detection of a time val."
  ;; It's a list
  (and time
       (listp time)
       ;; And a decoded time val is longer than this.
       (< (length time) 4)))

(defun* dp-hour-list-to-time-val-list (hour-list &optional from-time)
  (setq from-time (dp-*-to-time-val from-time 'zero))
  (mapcar (function
           (lambda (hour)
             (time-add from-time (dp-hours-to-time hour))))
           hour-list))

(defun* dp-mk-periodic-time-val-list (num period-FP-hrs &optional 
                                          from-time (offset 'zero)
                                          include-zeroth-p)
  "List goes from [period-FP-hrs... num * period-FP-hrs...].  I.e. no 0.
Just cons \(current-time\) onto the return.  This is easier than going the
other way: remove last element from the `cdr' of the return.
OFFSET is a time diff of some sort."
  ;; Use other building blocks for consistency. OaOO!
  (dp-hour-list-to-time-val-list
   (dp-mk-periodic-list num (dp-time-to-hours (dp-*-to-time-val offset))
                        period-FP-hrs (not include-zeroth-p)) from-time))

(defun dp-mk-offset-time-list (delta-list &optional from-time)
  "DELTA-LIST is a list of time val deltas.
Return a list of time vals offset from FROM-TIME."
  (setq from-time (dp-*-to-time-val from-time))
  (mapcar (lambda (delta)
            (time-add (dp-*-to-time-val delta) from-time))
          delta-list))

(defun* dp-*-to-time-val (time-in &optional nil-is)
  (setq-ifnil nil-is 'now-default
              time-in nil-is)
  (cond
   ((dp-time-val-p time-in)
    time-in)
   ((numberp time-in)
    (dp-hours-to-time time-in))
   ((memq time-in '(zero zed nada 0 z zap naught)) dp-time-val-0)
   ((memq time-in '(now n current c = now-default)) (current-time))
   (t (error (format "dp-*-to-time-val: Can't handle things like %s yet" 
                     time-in)))))

(defun dp-session-length ()
  (interactive)
  (let ((st (dp-get-first-emacs-start-time-string)))
    (message "In: %s, Now: %s, %s."
             st
             (dp-log-mk-std-time-string)
             (dp-1/4-hours-since-string 
              st 
              "Total elapsed time: %3.2f (%s) hrs"))))

(provide 'dp-time)

