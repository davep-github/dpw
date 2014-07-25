beg>a<, end>bb<, front-pos>ccc<

========================
Monday March 05 2012
--

(cl-pe '(defun dp-list-subtract (l1 l2)
  "Return L1 with all elements of L2 removed."
  (loop for b in l1
    when (not (memq b l2))
    collect b)))

(defun dp-list-subtract (l1 l2)
  "Return L1 with all elements of L2 removed."
  (block nil
    (let* ((G117651 l1)
           (b nil)
           (G117652 nil))
      (while (consp G117651)
        (setq b (car G117651))
        (if (not (memq b l2)) (setq G117652 (cons b G117652)))
        (setq G117651 (cdr G117651)))
      (nreverse G117652))))nil

(dp-list-subtract '(w d c j f e j d s a) '(a c e))
(w d j f j d s)






(let* ((win-buffers
        (mapcar (lambda (win)
                  (window-buffer win))
                (window-list)))
       (buffers (delq nil (mapcar (lambda (buf)
                          (if (memq buf win-buffers)
                              nil
                            buf))
                        (buffer-list)))))
  (list win-buffers buffers))


(buffer-list)

(dp-all-window-buffers)
(#<buffer "elisp-devel.el"> #<buffer "*info*">)

(dp-non-window-buffers)

(dp-first-by-pred (lambda (e)
                    (eq e 'q))
                  '(a f 5 g q w g t))
(q w g t)




;;older; (defun* dp-layout-windows (op-list &optional other-win-arg 
;;older;                            (delete-other-windows-p t))
;;older;   "Layout windows trying to keep as many buffers visible as possible.
;;older; !<@todo XXX MAKE SURE THE CURSOR STAYS IN THE SAME PLACE."
;;older;   ;; Save the original list of buffers displayed in windows.
;;older;   (let ((original-window-buffers (dp-all-window-buffers)))
;;older;     (when delete-other-windows-p
;;older;       (delete-other-windows))
;;older;     ;; Set up the new window pattern.
;;older;     (let ((skip-these-windows (list (get-buffer-window (current-buffer))))
;;older;           (win-list (window-list))
;;older;           (buf-list (buffer-list)))
;;older;       (loop for op in op-list
;;older;         do (let (op-args)
;;older;              (if (listp op)
;;older;                  (eval op)
;;older;                (apply op op-args))))
;;older;       (when other-win-arg
;;older;         (other-window other-win-arg))
;;older;       (dp-distribute-buffers original-window-buffers
;;older;                              :skip-these-windows skip-these-windows))))

(listp 'other-window)
nil

(let ((op '(split-window)))
  (dp-aif op
    (eval op)))

(eval '(dmessage "blah"))
"blah"

;;(cl-pe

(let ((op (or dp-layout-compile-windows-func 'split-window-vertically)))
  (unless (listp op)
    (setq op (list op)))
  (dp-aif (op)
    (eval op)))

(dp-layout-compile-windows-func)
nil

nil

nil

nil

nil

nil

nil

#<window on "elisp-devel.el" 0x7fbeea31>

#<window on "elisp-devel.el" 0x7fb7c783>


#<window on "elisp-devel.el" 0x7fb43a7c>

#<window on "elisp-devel.el" 0x7f6ad716>


nil
(let ((op '(other-window 1)))
  (dp-aif (op)
    (eval op)))



'
(let ((op '(progn (princf "yee haw!"))))
  (dp-aif (op)
    (eval op)))
yee haw!
nil

yee haw!
nil

nil

#<window on "elisp-devel.el" 0x7f1e7294>


nil
nil
#<window on "elisp-devel.el" 0x7f136f0d>

(let ((op '(other-window 1)))
  (dp-aif (op)
    (eval op)))

(let ((op '(other-window 1)))
  (dp-aif (op)
    (eval op)))

aif-away!!!
nil

nil

(dp-aif split-window)



ll)
(let ((op (quote split-window))) (dp-aif op))




(apply 'progn '(princf "yadda"))



(functionp 'progn)
t



========================
Tuesday March 06 2012
--

nil

dp-c-mark-current-token


========================
Monday March 12 2012
--

(defun* dp-clr-shell0 (&key
                       (clear-fun 'erase-buffer)
                       (clear-args '())
                       dont-fake-cmd 
                       dont-preserve-input)
  "Clear shell window and remembered command positions."
  (interactive)
  (setq dp-shell-last-parse-start 0
	dp-shell-last-parse-end 0)
  (let* ((cur-input (buffer-substring (dp-current-pmark-pos) (point-max))))
    (kill-region (dp-current-pmark-pos) (point-max))
    (when (y-or-n-p "Save contents first? ")
      (dp-save-shell-buffer))
    (apply clear-fun clear-args)
    (unless dont-fake-cmd
      (funcall dp-shell-type-enter-func 
	       (dp-shell-buffer-type (buffer-name)))) ;; get us a prompt
    (dp-shell-init-last-cmds)
    (unless dont-preserve-input
      (dp-end-of-buffer)
      (insert cur-input))))

(defun dp-clr-shell (really-clear-p &optional dont-fake-cmd dont-preserve-input)
  (interactive "P")
  (if (or really-clear-p
          (eq last-command 'dp-clr-shell)
          ;; too many accidental real clears, when triggering a real clear by
          ;; 2 clear commands in a row.  so use only prefix arg to wipe
          ;; history
          nil)                          ;see if I like it.
      (dp-clr-shell0 :clear-fun 'erase-buffer
                     :dont-fake-cmd dont-fake-cmd 
                     :dont-preserve-input dont-preserve-input)
    (dp-clr-shell0 
     :dont-fake-cmd dont-fake-cmd 
     :dont-preserve-input  dont-preserve-input
     :clear-fun (lambda ()
                  (let (point
                        (old-point-max (point-max)))
                    ;; See if we're over the max.
                    (when (> (line-number (point-max)) 
                             dp-shell-buffer-max-lines)
                      (dp-end-of-buffer)
                      (forward-line (- dp-shell-buffer-max-lines))
                      ;; move back to previous command so that we have the
                      ;; entire command still in the history
                      (setq point (point))
                      (dp-shell-goto-prev-cmd-pos)
                      (if (> (point) point) ;did we wrap?
                          (goto-char point))
                      ;; Remove all of the command positions before the
                      ;; truncation point.  They're all markers so the
                      ;; remaining ones should adjust themselves.
                      (dp-shell-trim-command-positions (point))
                      (delete-region (point-min) (point))
                      ;; now, adjust all of the command positions They're
                      ;; markers now.
                      ;;(dp-shell-adjust-command-positions (- old-point-max
                      ;;(point-max)))
                      )
                    (dp-end-of-buffer)
                    (dp-point-to-top 1)
                    )))))

========================
Monday March 26 2012
--

(re-search-forward dp-ws+newline-regexp+)

(match-beginning 1)

abc                     
                     
(setq x "x")
"x"

(member "x" '("a" "b" "x" "z"))
("x" "z")

(format "%s%s" 
                                dp-ws+newline-regexp+-not
                                (or "[a-j)]" ""))
"[^ 	
]+[a-j)]"

"[^ 	
]+[a-j])"

nil

nil


(progn (if (looking-at "[  
]+[a(s]") (list (match-beginning 0) (match-end 0))))
(6916 6919)
};

(progn (if (looking-at "[ 	
]") ;;+[a-f)]") 
           (list (match-beginning 0) (match-end 0))))
nil







(6916 6929)
       
"[^ 	\n]+[a-f)]"



(dp-c-looking-back-at-sans-eos-junk "[;}]")
nil


;; (defun* dp-c-prev-eol-regexp (&optional regexp initial-eol-p)
;;   (interactive)
;;   (setq-ifnil regexp dp-ws+newline-regexp+-not)
;;   (save-excursion
;;     (when initial-eol-p
;;       (dp-c-end-of-line))
;;     (while
;;         ;; Look back for any non-ws chars
;;         (if (dp-looking-back-at dp-ws+newline-regexp+-not)
;;             ;; Got something. Return nil if it's not what we want.
;;             (return-from dp-c-prev-eol-regexp
;;               (if (dp-looking-back-at regexp)
;;                   (list (match-beginning 0)
;;                         (buffer-substring-no-properties (match-beginning 0)
;;                                                         (match-end 0)))
;;                 nil))
;;           (previous-line 1)
;;           (dp-c-end-of-line)))))
        


(defun dp-next-non-whitespace-char (&optional chars)
  (save-excursion
    (let (start (point))
      (when (looking-at (format "%s%s" 
                                dp-ws+newline-regexp+
                                (or chars "")))
        (list (1- (match-end 0))
              (buffer-substring-no-properties (1- (match-end 0))
                                              (match-end 0)))))))


(defun dp-prev-non-whitespace-char (&optional chars)
  (save-excursion
    (when (dp-looking-back-at (format "%s%s"
                                      (or chars "")
                                      dp-ws+newline-regexp+)
                              'nolimit)
      (list (match-beginning 0)
            (buffer-substring-no-properties (match-beginning 0)
                                            (1+(match-beginning 0)))))))


========================
Friday March 30 2012
--

(defun dp-push-window-config ()
  (interactive)
  (call-interactively 'wconfig-ring-save))

(defun dp-pop-window-config (n)
  (interactive "p")
  (call-interactively 'wconfig-yank-pop))

(frame-property (selected-frame) 'wconfig-ring)
(9 1 . [nil nil nil nil nil nil nil nil nil [cl-struct-window-configuration #<x-frame "XEmacs" 0x2c94f> 1 390 1517 1013 #<buffer "elisp-devel.el"> 15 10 4 [cl-struct-saved-window nil nil nil nil nil nil nil 0 0 1509 990 0 0 nil [cl-struct-saved-window nil nil nil nil nil nil nil 0 0 760 990 0 0 nil nil [cl-struct-saved-window nil nil nil #<buffer "tca.cpp"> #<marker at 4520 in tca.cpp 0x4a575d8> #<marker at 5473 in tca.cpp 0x4a57638> #<marker at 6111 in tca.cpp 0x4a57608> 0 0 760 495 0 0 nil nil nil [cl-struct-saved-window t nil nil #<buffer "elisp-devel.el"> #<marker at 8923 in elisp-devel.el 0x4a57668> #<marker at 8340 in elisp-devel.el 0x4a57698> nil 0 495 760 990 0 0 nil nil nil nil #<window 0x711bfeef>] #<window 0x70d86a89>] [cl-struct-saved-window nil nil nil #<buffer "wconfig.el"> #<marker at 5130 in wconfig.el 0x4a57548> #<marker at 4770 in wconfig.el 0x4a575a8> #<marker at 5262 in wconfig.el 0x4a57578> 760 0 1509 990 0 0 nil nil nil nil #<window 0x711bfddd>] #<window 0x711bfee7>] nil [cl-struct-saved-window nil t nil #<buffer " *Minibuf-1"> #<marker in no buffer 0x4a574b8> #<marker at 1 in  *Minibuf-1 0x4a57518> #<marker at 1 in  *Minibuf-1 0x4a574e8> 0 990 1509 1005 0 0 nil nil nil nil #<window on " *Minibuf-1" 0x2ea85>] #<window 0x711bfdd5>]]])


(dp-first-by-pred 'eq '(a b c d) 'q)
nil

(stringp "a")
t

(and-stringp nil)
nil

""

""

""

nil


(dp-embedded-lisp-close-string 'lalalal)
")"

")"

")"

")"

":)"

;; :(princf "HI"):
;; (princf "HI")

(cl-pe '(dp-deflocal blah 1))

(progn
  (defvar blah 1 "Undocumented. (dp-deflocal)")
  (make-variable-buffer-local 'blah)
  (setq-default blah 1))nil


(setq p 'b
      q '(c d e))
(c d e)

  `(a ,p (quote (list ,@q)))
(a b (quote (list c d e)))

(a b (quote c d e))

(a b c d e)

  `(a . b)
  `(a . ,p)

q.v.

(dp-string-join '(a b c) "-" nil nil nil
                (lambda (s)
                  (format "%s" s)))
"a-b-c"

(intern-soft "visit-header-docK")
nil

visit-header-doc

nil

;; q.v. header doc
;; q.v. header-doc
;; 

q\.v\.

q\.v\.

(cl-pe '(q.v. header doc))

(q\.v\.f '(header doc))










(nil
nil
q\.v\.f header doc)nil




(q\.v\.f header doc)




(q\.v\.f 'headerdoc)nil
)








(q\.v\.f '(header doc))

nil




(q\.v\.f '(header doc))nil



(q\.v\.f 'rest)nil

(q.v. header doc)
nil


(defun dp-uncolorize-all (&optional rest-of-buffer-p)
  "Remove all of my colorization. 
If the region is active, that is colorized.
REST-OF-BUFFER-P says only from point to point-max.
All means every dp-extent with the property 'dp-colorized-p non-nil."
  (interactive "P")
  (let ((beg-end
         (cond
          ((dp-region-active-p)
           (dp-region-boundaries-ordered))
          (rest-of-buffer-p
           (cons (point) (point-max)))
          (t
           (cons (point-min) (point-max))))))
        (dp-unextent-region 'dp-colorized-p
                            (car beg-end)
                            (cdr beg-end)))))


(let ((comment-end "")
      (comment-start "x"))
  (list (not (or (string= comment-end "")
                 (string= comment-start "")))
        (and (not (string= comment-end ""))
             (not (string= comment-start "")))))
(nil nil)

(t t)

(nil nil)

(nil nil)




========================
Thursday April 12 2012
--

(defun dp-space-to-col (col &optional insert-char)
  (interactive "Ncol: ")
  (setq-ifnil insert-char ? )
  (let ((num-to-insert (- col (current-column))))
    (when (> num-to-insert 0)
      (insert (make-string num-to-insert insert-char)))))

............................................
    hi

========================
Wednesday April 18 2012
--
(symbol-value 'dp-python-new-file-template)
"
import sys, os

def main(argv):
    import getopt
    opt_string = \"\"
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        #if o == '-<option-letter>':
        #    # Handle opt
        #    continue
        pass BUBBA

    for arg in args:
        # Handle arg
        pass

if __name__ == \"__main__\":
    main(sys.argv)

"

(cl-pe dp-major-mode-to-shebang)


((python-mode i-name
              "python"
              env-p
              run-with-/usr/bin/env-p
              comment-start
              "### "
              template
              dp-python-new-file-template)
 (sh-mode it shit)
 (c-mode it dp-c-new-file-template)
 (c++-mode it dp-c-new-file-template)
 (example-mode it example-it)
 (perl-mode i-name "perl" env-p run-with-/usr/bin/env-p))nil




((python-mode i-name "python" env-p run-with-/usr/bin/env-p comment-start "### " template "
import sys, os

def main(argv):
    import getopt
    opt_string = \"\"
    opts, args = getopt.getopt(argv[1:], opt_string)
    for o, v in opts:
        if o == '-<option-letter>':
            # Handle opt
            continue
    for arg in args:
        # Handle arg

if __name__ == \"__main__\":
    main(sys.argv)

")
 (sh-mode it shit)
 (c-mode it dp-c-new-file-template)
 (c++-mode it dp-c-new-file-template)
 (example-mode it example-it)
 (perl-mode i-name "perl" env-p run-with-/usr/bin/env-p))nil



========================
Tuesday April 24 2012
--
(princf"\\(^\\|\\s-\\|-D\\|\"\\|(\\)"
"\\(^\\|\\s-\\|-D\\|\"\\|(\\)"


(let ((vars '(
              "CXX_PTHREAD_OPT"
              "CXX_LD_PTHREAD_OPT"
              "LIBS"
              "EXTRA_CXX_DEFS"
              "CXX_DEBUG_FLAG"
              "CXX_OPT_FLAG"
              "CXX_ERROR_FLAGS"
              "EXTRA_CXX_DEFS"
              "EXTRA_CXX_FLAGS"
              "SHARED_DEF_PROG"
              "ADDITIONAL_PACKAGE_DIR"
              "INC_DIRS"
              "LIB_DIRS")))
  (with-current-buffer (dp-get-buffer "common.am.mak")
    (loop for v in vars do
      (dp-beginning-of-buffer)
      (while (re-search-forward
            ;; (repre "\\(\"\\|(\\)" "\\1ftci" nil)
              ;;                    |-D\\|\"\\|(\\)
              ;; epre "\\(^\\|-D\\|\"\\|(\\)" "\\1ftci_" nil)
              ;; epre "\\(^\\|\\s-\\|-D\\|\"\\|(\\)" "\\1ftci_" nil)
              (concat "\\(^\\|\\s-\\|-D\\|\"\\|(\\)" 
                      "\\(" v "\\)"
                      "\\($\\|\\s-\\|>\\|)\\)" ) nil t)
        (replace-match "\\1ftci_\\2\\3" t)))))


========================
Wednesday April 25 2012
--

xxx = aaa bbb  ccc   ddd
xxx = aaa bbb ddd     eeee \
q-followed-by-spaces


xxx = aaa bbb ccc

(defvar yaddaddadda t)
yaddaddadda

(defun dp-break-up-line (&optional sep term replacement)
  "Replace regexp SEP with REPLACEMENT. Add TERM to end of original line.
Continue to end of region if active, else end of original line.
Like when you have some long var in a Makefile:
SRCS = a.c b.c d.c ...
-->
SRCS = a.c \
       b.c \
       d.c
..."
  (interactive)
  (setq-ifnil sep "\\s-+"
              term " \\"
              replacement "\n")
  (let* ((b&e (dp-region-or... :bounder 'rest-of-line-p))
         (end-marker (dp-mk-marker (cdr b&e) nil t)))
    (goto-char (car b&e))
    (dmessage "em: %s lep: %s" end-marker (line-end-position))
    (while (re-search-forward sep end-marker t)
      (dmessage "ms>%s<" (match-string 0) end-marker)
      (unless t ;;(looking-at (regexp-quote term))
        (replace-match replacement)
        (goto-char (match-beginning 0))
        (dp-delete-to-end-of-line)
        (end-of-line)
        (dmessage "me: %s, em: %s" (match-end 0) end-marker)
        (unless (>= (match-end 0) end-marker)
          (insert term)))
      (next-line 1)
      (beginning-of-line)
      (when (looking-at sep)
        (replace-match ""))
      ;; !<@todo XXX run command on TAB?
      (indent-for-tab-command))))



psa_SOURCES = psa.cpp

sa-concierge.cpp \
sa-concierge.h \
sa-message-handler.cpp \
sa-message-handler.h












# don't split me!

========================
Monday April 30 2012
--
(defun dp-shells-set-favored-buffer (name &optional buffer override-p)
  "Set the shell buffer we think the current buffer most wants to visit."
  (let ((fav-buf (dp-shells-get-favored-buffer buffer)))
    (cond
     ((and fav-buf
           (consp fav-buf))
      (setcar fav-buf name))
     (t (setq ))
     
(defun* dp-shell0 (&optional arg &key other-window-p name)
  "Open/visit a shell buffer.
First shell is numbered 0 by default.
ARG is numberp:
 ARG is >= 0: switch to that numbered shell.
 ARG is < 0: switch to shell buffer<\(abs ARG)>
 ARG memq `dp-shells-shell<0>-names' shell<0> in other window."
"pmax: 1, p: 17428"
"pmix: 1, pmax: 107367"
  (interactive "P")
"del region: pmin: 1, p: 17492, remainder: 89984"
  (let* ((specific-buf-requested-p current-prefix-arg)
         (arg-specified-p (null (current-prefix-arg)))
         (pnv (cond
               ((member arg dp-shells-shell<0>-names)
                0)
               (t (prefix-numeric-value arg))))
         (fav-buf0 (dp-shells-get-favored-buffer (current-buffer)))
         (fav-buf (dp-shells-favored-shell-buffer-buffer fav-buf0))
         (fav-buf-name (dp-shells-favored-shell-buffer-name fav-buf))
         ;; The fan is the buffer who favors this shell.
         (fan-buf-name (format "<%s>" (buffer-name)))
         (fav-flags (dp-shells-favored-shell-buffer-flags fav-buf0))
         (other-window-p (or (eq arg '-) 
                             (and pnv (< pnv 0) (setq pnv (abs pnv)))
                             other-window-p
                             fav-flags
                             (Cup)))
         (switch-window-func (cond
                              ((functionp other-window-p) other-window-p)
                              (other-window-p 'switch-to-buffer-other-window)
                              (t nil)))
         ;; Ordered by priority.
         (sh-name (or name
                      (stringp arg)
                      (and arg
                           (or (dp-shells-get-shell-buffer-name pnv)
                               (format "*shell*<%s>" pnv)))
                      (and fav-buf0 fav-buf-name)
                      (and pnv
                           (or (dp-shells-get-shell-buffer-name pnv)
                               (format "*shell*<%s>" pnv)))
                      (and (dp-buffer-live-p 
                            (dp-shells-most-recent-shell-buffer)))))
         ;; Is the shell already in existence?
         (existing-shell-p (dp-buffer-live-p sh-name))
         (sh-buffer (and sh-name
                         (get-buffer-create sh-name)))
         win fav-buf0 new-shell-buf)

    (
    (setq fav-buf0 (dp-shells-get-favored-buffer (current-buffer))
         fav-buf (dp-shells-favored-shell-buffer-buffer fav-buf0)
         fav-buf-name (dp-shells-favored-shell-buffer-name fav-buf)
         ;; The fan is the buffer who favors this shell.
         fan-buf-name (format "<%s>" (buffer-name))
         fav-flags (dp-shells-favored-shell-buffer-flags fav-buf0)
         switch-window-func (cond
                              ((functionp other-window-p) other-window-p)
                              (other-window-p 'switch-to-buffer-other-window)
                              (t nil))
         ;; Ordered by priority.
         sh-name (or name
                      (stringp arg)
                      (and arg
                           (or (dp-shells-get-shell-buffer-name pnv)
                               (format "*shell*<%s>" pnv)))
                      (and fav-buf0 fav-buf-name)
                      (and pnv
                           (or (dp-shells-get-shell-buffer-name pnv)
                               (format "*shell*<%s>" pnv)))
                      (and (dp-buffer-live-p 
                            (dp-shells-most-recent-shell-buffer))))
         ;; Is the shell already in existence?
         existing-shell-p (dp-buffer-live-p sh-name)
         sh-buffer (and sh-name
                         (get-buffer-create sh-name))
         win fav-buf0 new-shell-buf)

    ;;(dmessage "arg>%s<, sh-name>%s<" arg sh-name)
    (if existing-shell-p
        (progn
          (dp-visit-or-switch-to-buffer sh-buffer switch-window-func)
          ;; We're in the requested buffer now.
          ;; If we came from a file with a live favored shell buffer, set up
          ;; the fiddly-bits(tm).
          ;;!<@todo This should be moved to any we visit this buffer, but
          ;;the hook doesn't exist yet.  I can still do it in all of my
          ;;visit  points.
          (when specific-buf-requested-p
            (dp-shells-set-most-recent-shell (current-buffer) 'shell))
          (when (dp-fav-buf-p fav-buf0)
            (setq dp-shell-whence-buf fav-buf
                  dp-use-whence-buffers-p t)
            (unless (string-match (regexp-quote fan-buf-name) fav-buf-name)
              (rename-buffer (format "%s%s" fav-buf-name fan-buf-name)))
            (message "Using fav buf: %s" fav-buf0))
          (dmessage "point: %s, window-point: %s" (point) (window-point)))
      ;;;;;;;;;;;;;;;;;;;;; EA! ;;;;;;;;;;;;;;;;;;;;;
      ;; Handle new shell case. We may have a name already.
      (setenv "PS1_prefix" nil 'UNSET)
      (setenv "PS1_host_suffix"
              (format "%s" (dp-shells-guess-suffix sh-name "")))
      (setenv "PS1_bang_suff" (format dp-shells-shell-num-fmt pnv))
      (save-window-excursion/mapping
       (shell sh-buffer))
      (dp-visit-or-switch-to-buffer sh-buffer switch-window-func)
      ;;
      ;; We're in the new shell buffer now.
      ;;
      (setq dp-shell-isa-shell-buf-p '(dp-shell shell)
            other-window-p nil)
      (dp-shells-set-most-recently-created-shell sh-buffer 'shell)
      (dp-shells-set-most-recent-shell sh-buffer 'shell)
      ;; new shell (I hope!)
      (add-to-list 'dp-shells-shell-buffer-list sh-buffer)
      (add-local-hook 'kill-buffer-hook 'dp-shells-delq-buffer)
      (add-local-hook 'kill-buffer-hook 'dp-save-shell-buffer-contents-hook)
      ;; Set the name once. All saves will pile up in the same file.  I've
      ;; added a manual save command and that will go there, too.  If shell
      ;; buffers get too big, then the performance begins to suck.  Many
      ;; things can be shell wide.
      ;; !<@todo XXX Make sure that as few things as possible (0!) look at
      ;; the entire buffer. Also, check into the fontifier. It may do evil
      ;; things.
      ;; Saves are currently done with sticky names so this isn't needed.
      ;;(setq-ifnil dp-save-buffer-contents-file-name 
      ;;            (dp-shellify-shell-name (buffer-name)))
      (dmessage "Loading shell input ring")
      (dp-maybe-read-input-ring))))

========================
Wednesday May 02 2012
--

;; Copped from `compilation-set-window-height'
(defun dp-set-window-height (height-in-lines &optional buffer-or-window)
  (interactive "NNew height: ")
  ;; if buffer, find window.
  (let ((window (cond
                 ((not buffer-or-window)
                  (selected-window))
                 ((bufferp buffer-or-window)
                  (dp-get-buffer-window buffer-or-window))
                 ((windowp buffer-or-window)
                  buffer-or-window)
                 (t (error "bad type to dp-set-window-height")))))
  (save-excursion
    (with-selected-window window
      (enlarge-window (- height-in-lines

                         (window-height)))))))

========================
Thursday May 03 2012
--

(defun dp-bob ()
  (execute-kbd-macro 'dp-poc-layout-2+1))

(dp-bob)
nil
(dp-do-a-jk 'dp-poc-layout-2/1)
nil



========================
Tuesday May 08 2012
--
(defmacro dp-defaliases0 (def-type &rest symbols-followed-by-newdef)
  "Define a list of aliases. SYMBOLS-FOLLOWED-BY-NEWDEF ends with 'newdef.
SYMBOLS-FOLLOWED-BY-NEWDEF is an &rest list: SYMB0 SYMB1... NEWDEF.
Ie, NEWDEF is \(last symbol-followed-by-newdefs).
Emits a series of defaliases:
\(defalias SYMB0 NEWDEF)
\(defalias SYMB1 NEWDEF)
\(defalias SYMBn NEWDEF)
NEWDEF is last to match the order of args to `defalias'."
  (unless (>= (length symbols-followed-by-newdef) 2)
    (error "dp-defaliases: requires 2 or more args."))
  (let ((newdef (car (last symbols-followed-by-newdef)))
        (symbols-followed-by-newdef (butlast symbols-followed-by-newdef))
        arg init-val bunch-of-defalias-calls)
    (while symbols-followed-by-newdef
      (setq arg (car symbols-followed-by-newdef)
            symbols-followed-by-newdef (cdr symbols-followed-by-newdef))
      (setq new-elem `(,def-type ,arg ,newdef))
      (setq bunch-of-defalias-calls (cons new-elem bunch-of-defalias-calls)))
    (cons 'progn (reverse bunch-of-defalias-calls))))
(put 'dp-defaliases0 'lisp-indent-function
     (get 'defalias 'lisp-indent-function))


(defmacro dp-defaliases (&rest symbols-followed-by-newdef)
  `(dp-defaliases0 defalias ,@symbols-followed-by-newdef))
(put 'dp-defaliases 'lisp-indent-function
     (get 'defalias 'lisp-indent-function))

(defmacro dp-safe-aliases (&rest symbols-followed-by-newdef)
  `(dp-defaliases0 dp-safe-alias ,@symbols-followed-by-newdef))
(put 'dp-safe-aliases 'lisp-indent-function
     (get 'defalias 'lisp-indent-function))


(cl-pe '(dp-defaliases 'a 'b 'c 'BLAH))

(cl-pe '(dp-safe-aliases 'a 'b 'c 'BLAH))

(progn
  (if (fboundp 'a)
      (if (get 'a 'dp-safe-alias-p)
          (if (dp-alias-eq 'a 'BLAH)
              (dmessage "dp-safe-alias: Identical redefinition.")
            (dmessage-ding "dp-safe-alias:: Allowing redefinition of %s from %s to %s"
                           'a
                           (symbol-function 'a)
                           'BLAH)
            (defalias 'a 'BLAH))
        (funcall (if dp-unsafe-alias-is-fatal-p 'error 'warn)
                 "dp-safe-alias: DENIED! %ssymbol: `%s' is already fbound to `%s'."
                 (if (functionp 'BLAH) "function " "")
                 'a
                 'BLAH))
    (defalias 'a 'BLAH)
    (put 'a 'dp-safe-alias-p t))
  (if (fboundp 'b)
      (if (get 'b 'dp-safe-alias-p)
          (if (dp-alias-eq 'b 'BLAH)
              (dmessage "dp-safe-alias: Identical redefinition.")
            (dmessage-ding "dp-safe-alias:: Allowing redefinition of %s from %s to %s"
                           'b
                           (symbol-function 'b)
                           'BLAH)
            (defalias 'b 'BLAH))
        (funcall (if dp-unsafe-alias-is-fatal-p 'error 'warn)
                 "dp-safe-alias: DENIED! %ssymbol: `%s' is already fbound to `%s'."
                 (if (functionp 'BLAH) "function " "")
                 'b
                 'BLAH))
    (defalias 'b 'BLAH)
    (put 'b 'dp-safe-alias-p t))
  (if (fboundp 'c)
      (if (get 'c 'dp-safe-alias-p)
          (if (dp-alias-eq 'c 'BLAH)
              (dmessage "dp-safe-alias: Identical redefinition.")
            (dmessage-ding "dp-safe-alias:: Allowing redefinition of %s from %s to %s"
                           'c
                           (symbol-function 'c)
                           'BLAH)
            (defalias 'c 'BLAH))
        (funcall (if dp-unsafe-alias-is-fatal-p 'error 'warn)
                 "dp-safe-alias: DENIED! %ssymbol: `%s' is already fbound to `%s'."
                 (if (functionp 'BLAH) "function " "")
                 'c
                 'BLAH))
    (defalias 'c 'BLAH)
    (put 'c 'dp-safe-alias-p t)))nil



(progn
  (defalias 'a 'BLAH)
  (defalias 'b 'BLAH)
  (defalias 'c 'BLAH))




BLAH










(dp-defaliases 'a 'b 'c 'BLAH)
BLAH

(symbol-plist 'c)
(custom-group ((c-strict-syntax-p custom-variable) (c-echo-syntactic-information-p custom-variable) (c-report-syntactic-errors custom-variable) (c-basic-offset custom-variable) (c-tab-always-indent custom-variable) (c-insert-tab-function custom-variable) (c-syntactic-indentation custom-variable) (c-syntactic-indentation-in-macros custom-variable) (c-comment-only-line-offset custom-variable) (c-indent-comment-alist custom-variable) (c-indent-comments-syntactically-p custom-variable) (c-block-comment-prefix custom-variable) (c-comment-prefix-regexp custom-variable) (c-doc-comment-style custom-variable) (c-ignore-auto-fill custom-variable) (c-cleanup-list custom-variable) (c-hanging-braces-alist custom-variable) (c-hanging-colons-alist custom-variable) (c-hanging-semi&comma-criteria custom-variable) (c-backslash-column custom-variable) (c-backslash-max-column custom-variable) (c-auto-align-backslashes custom-variable) (c-backspace-function custom-variable) (c-delete-function custom-variable) (c-require-final-newline custom-variable) (c-electric-pound-behavior custom-variable) (c-special-indent-hook custom-variable) (c-label-minimum-indentation custom-variable) (c-progress-interval custom-variable) (c-default-style custom-variable) (c-offsets-alist custom-variable) (c-style-variables-are-local-p custom-variable) (c-mode-hook custom-variable) (c++-mode-hook custom-variable) (objc-mode-hook custom-variable) (java-mode-hook custom-variable) (idl-mode-hook custom-variable) (pike-mode-hook custom-variable) (c-mode-common-hook custom-variable) (c-initialization-hook custom-variable) (c-enable-xemacs-performance-kludge-p custom-variable) (c-font-lock-extra-types custom-variable) (c++-font-lock-extra-types custom-variable) (objc-font-lock-extra-types custom-variable) (java-font-lock-extra-types custom-variable) (idl-font-lock-extra-types custom-variable) (pike-font-lock-extra-types custom-variable) (fume custom-group)))

a


(symbol-function 'c)
BLAH

BLAH



nil

nil

(custom-group ((c-strict-syntax-p custom-variable) (c-echo-syntactic-information-p custom-variable) (c-report-syntactic-errors custom-variable) (c-basic-offset custom-variable) (c-tab-always-indent custom-variable) (c-insert-tab-function custom-variable) (c-syntactic-indentation custom-variable) (c-syntactic-indentation-in-macros custom-variable) (c-comment-only-line-offset custom-variable) (c-indent-comment-alist custom-variable) (c-indent-comments-syntactically-p custom-variable) (c-block-comment-prefix custom-variable) (c-comment-prefix-regexp custom-variable) (c-doc-comment-style custom-variable) (c-ignore-auto-fill custom-variable) (c-cleanup-list custom-variable) (c-hanging-braces-alist custom-variable) (c-hanging-colons-alist custom-variable) (c-hanging-semi&comma-criteria custom-variable) (c-backslash-column custom-variable) (c-backslash-max-column custom-variable) (c-auto-align-backslashes custom-variable) (c-backspace-function custom-variable) (c-delete-function custom-variable) (c-require-final-newline custom-variable) (c-electric-pound-behavior custom-variable) (c-special-indent-hook custom-variable) (c-label-minimum-indentation custom-variable) (c-progress-interval custom-variable) (c-default-style custom-variable) (c-offsets-alist custom-variable) (c-style-variables-are-local-p custom-variable) (c-mode-hook custom-variable) (c++-mode-hook custom-variable) (objc-mode-hook custom-variable) (java-mode-hook custom-variable) (idl-mode-hook custom-variable) (pike-mode-hook custom-variable) (c-mode-common-hook custom-variable) (c-initialization-hook custom-variable) (c-enable-xemacs-performance-kludge-p custom-variable) (c-font-lock-extra-types custom-variable) (c++-font-lock-extra-types custom-variable) (objc-font-lock-extra-types custom-variable) (java-font-lock-extra-types custom-variable) (idl-font-lock-extra-types custom-variable) (pike-font-lock-extra-types custom-variable) (fume custom-group)))


(progn
  (defalias 'a 'BLAH)
  (defalias 'b 'BLAH)
  (defalias 'c 'BLAH))nil


dpj-topic-list
(("ansys.fluent" last-update: "2012-01-02T13:40:39") ("ask-the-physicist" last-update: "2012-02-24T07:54:45") ("bs" last-update: "2012-01-05T13:18:14") ("bull" last-update: "2012-02-28T08:45:56") ("def.environment" last-update: "2012-03-15T10:01:45") ("dp-coding-standard.naming" last-update: "2012-03-07T08:46:18") ("dp-coding-standard.style") ("emacs.elisp" last-update: "2012-05-02T17:00:13") ("ftci" last-update: "2012-04-24T16:51:01") ("ftci.autohell") ("ftci.code" last-update: "2012-03-23T13:47:19") ("ftci.code.design" last-update: "2012-03-13T11:45:36") ("ftci.code.gloox" last-update: "2012-03-12T12:38:21") ("ftci.future" last-update: "2012-01-23T08:10:48") ("ftci.messages" last-update: "2012-05-03T18:18:10") ("ftci.messages.run") ("ftci.millstones" last-update: "2012-03-15T12:23:02") ("ftci_client" last-update: "2012-01-11T07:40:41") ("fvwm" last-update: "2012-03-23T08:51:38") ("git" last-update: "2012-04-30T11:41:23") ("hardware.cluster" last-update: "2012-05-03T09:47:52") ("hardware.cluster.bright.license") ("humor" last-update: "2012-04-24T09:30:36") ("ideas" last-update: "2012-04-23T13:07:01") ("jabber" last-update: "2012-02-13T09:57:37") ("personal.work.after-contract" last-update: "2012-03-15T07:07:31") ("physi" last-update: "2012-04-27T15:22:01") ("physics" last-update: "2012-04-27T15:22:13") ("politics" last-update: "2012-05-08T13:27:29") ("tools.git" last-update: "2012-03-07T07:20:06") ("tools.index-code" last-update: "2012-04-20T08:14:32") ("tools.teeker") ("work.tools" last-update: "2012-04-20T08:14:08"))

(("ansys.fluent" last-update: "2012-01-02T13:40:39") ("ask-the-physicist" last-update: "2012-02-24T07:54:45") ("bs" last-update: "2012-01-05T13:18:14") ("bull" last-update: "2012-02-28T08:45:56") ("def.environment" last-update: "2012-03-15T10:01:45") ("dp-coding-standard.naming" last-update: "2012-03-07T08:46:18") ("dp-coding-standard.style") ("emacs.elisp" last-update: "2012-05-02T17:00:13") ("ftci" last-update: "2012-04-24T16:51:01") ("ftci.autohell") ("ftci.code" last-update: "2012-03-23T13:47:19") ("ftci.code.design" last-update: "2012-03-13T11:45:36") ("ftci.code.gloox" last-update: "2012-03-12T12:38:21") ("ftci.future" last-update: "2012-01-23T08:10:48") ("ftci.messages" last-update: "2012-05-03T18:18:10") ("ftci.messages.run") ("ftci.millstones" last-update: "2012-03-15T12:23:02") ("ftci_client" last-update: "2012-01-11T07:40:41") ("fvwm" last-update: "2012-03-23T08:51:38") ("git" last-update: "2012-04-30T11:41:23") ("hardware.cluster" last-update: "2012-05-03T09:47:52") ("hardware.cluster.bright.license") ("humor" last-update: "2012-04-24T09:30:36") ("icypoo" last-update: "2012-05-08T17:52:23") ("ideas" last-update: "2012-04-23T13:07:01") ("jabber" last-update: "2012-02-13T09:57:37") ("personal.work.after-contract" last-update: "2012-03-15T07:07:31") ("physi" last-update: "2012-04-27T15:22:01") ("physics" last-update: "2012-04-27T15:22:13") ("politics" last-update: "2012-05-08T13:27:29") ("tools.git" last-update: "2012-03-07T07:20:06") ("tools.index-code" last-update: "2012-04-20T08:14:32") ("tools.teeker") ("work.tools" last-update: "2012-04-20T08:14:08"))

(assoc "ask-the-physicist" dpj-topic-list)
("ask-the-physicist" last-update: "2012-02-24T07:54:45")

(setq aalliisstt '((a b c) (1 2 3) (p q r)))
((a b c) (1 2 3) (p q r))

((a b c) (1 2 3))

((a b c) (1 2 3))

((a b c) (1 2 3) (p q r))

(assoc '1 aalliisstt)
(1 2 3)

(remove-alist 'aalliisstt '1)
((a b c) (p q r))



nil

aalliisstt
((a b c) (1 2 3) (p q r))




(a b c)

nil


(defun dp-c-cheap-move-out-of-syntactic-region (&optional backwards-p)
  (interactive "P")
  (let ((movement-cmd (if backwards-p
                          'backward-char-command
                        'forward-char-command))
        (initial-syntax (list (dp-c-get-syntactic-region))))
    (while (dp-c-in-syntactic-region initial-syntax)
      (funcall movement-cmd))))
        
                      

========================
Monday May 14 2012
--
(defun dp-c-in-a-pure-// ()
  (interactive)
  (and (is-c++-one-line-comment)
       (dp-c*-pure-comment-line-p)))

(cons nil nil)
(nil)

;;in a command AND looking back at (//|/*)[^!]
(defun dp-c-doxy-need-a-!-p (&optional false-val)
  (cond
   ((not (dp-in-c)) (cons "!" t))
   ((not (dp-in-a-c*-comment)) (cons "!" t))
   ((save-excursion
      (beginning-of-line)
      (let ((beg-pos (comment-search-forward (line-end-position) t)))
        (when beg-pos
          (goto-char beg-pos)
          (looking-at "\\(//\\|/\\*\\)\\($\\|[^!]\\).*"))))
    (cons "!" nil))
   (t (cons false-val t))))
;;
"
/*!
 * @todo
 * ... no ! needed ...
 * too hard to see if ! is up there so assume in old style comment and 
 * not looking back at /*, --> no !.
 */
//! @todo
/*! @todo */

xxx(
 int a,          //!<@arg -- let M-; handle.
 const char* p)
"
(defun xxx()
  (interactive)
  (if (dp-region-active-p)
      (dp-io-xxx)
    ;; The doxygen element syntax is different when it comes after a line vs
    ;; before it.
    ;; e.g.
    ;; /*!
    ;;  *!@todo blah
    ;;  */
    ;; vs:
    ;; bad_thing(ccc);   //!<@todo.
    ;; So fix it.
    (let ((!-stuff (dp-c-doxy-need-a-!-p "")))
    (dp-insert-for-comment+ "XXX" 
                            " @todo " 
                            :doxy-prefix (car !-stuff)
                            :remove-preceding-ws-p (cdr !-stuff)))))

========================
Friday May 18 2012
--
tag-completion-table

(bound-and-true-p tag-completion-table)
[YYLSP_NEEDED bangs yyget_leng FTCIDiscoHandler YY_SYMBOL_PRINT Argv_t_iterator::Argv_t_iterator Match_item_t::args_required_p EOB_ACT_END_OF_FILE YYSTACK_FREE YY_USE_CONST 0 FTCI_debug UINT32_MAX response_ref yy_create_buffer m_desc yyset_out 0 find_registration YY_STATE_BUF_SIZE 0 Registration_t::cap_version yy_bs_lineno make_connection YY_LOCATION_PRINT yylex_destroy ui_streamp Msg_copy_completor_t RESV_STATE_IN_USE FTCI_message_t::m_dest_addr yy_buffer_stack STR_LIT comparison_expr Initiator_type_t YYNSTATES yy_input_file Concierge_t yyset_debug FTCIRosterListener::handleRosterError yy_meta YY_DECL_IS_OURS FML_MTYPE_RUN_APP_STATUS yy_delete_buffer client_exit CARosterListener::ca 0 alloca yyterminate yysyntax_error YY_INPUT A_client_t::m_inflight YY_RULE_SETUP Match_item_t::m_name concatenate YY_BUFFER_STATE Max_cap_ver_len yy_scan_bytes at yyss_alloc yy_last_accepting_cpos YY_REDUCE_PRINT YYSTACK_ALLOC Concierge_t::Concierge_t REG_STATE_UNREGISTERED YY_FLEX_MAJOR_VERSION FINISH_PARSE FTCIIqHandler yyget_in YYPULL Msg_test_completor_t::Msg_test_completor_t YY_END_OF_BUFFER_CHAR FML_FN_ARGS_REQUIRED YY_NULL arithmetic_expr NEQ_TOK expr_list yy_buffer_state::yy_bs_lineno ~Argv_t yy_reduce_print Registration_t::formatted_cap_and_reg_description A_client_t::set_state CAConnectionListener::onConnect CONN_STATE_DISCONNECTED XMPP_CLIENT Argv_t::iterator FML_FN_MSG_TYPE log_msg_dbg operator\ \[\] CONN_STATE_all yy_init Inflight_msg_t Registration_t::state handleRosterPresence INT32_MAX ECHO prompt_string yy_get_next_buffer error_stream YY_NUM_RULES trace_streamp ca A_client_t::num_inflight_msgs Match_list_t::parse Registration_t::formatted_cap MM_UI_match_simple_async yyalloc yy_base FML_MTYPE_RUN_APP str_at FTCIClient::m_peer_id UI_run_match_t::UI_run_match_t YY_END_OF_BUFFER Msg_test_completor_t::complete YY_FLEX_MINOR_VERSION yy_size_t YYCOPY ~Dyn_type_t DEBUG_NAME_AND_VAL_LOG yyalloc::yyss_alloc finish_stmt_list m_cond FTCIClient::m_peer_ip A_client_t::RECV_TIMEOUT_default REG_DOT_H_INCLUDED argv_t Dyn_type_t::Dyn_type_t YYTABLE_NINF 0 Inflight_msg_list_t::m_messages YYABORT A_client_t::send_msg_to yywrap Argv_t::add YY_s_val add_int_field IFMPL_const_iterator_t 0 YYERROR_VERBOSE INT8_MAX flex_int8_t yy_fill_buffer yy_chk yy_trans_info::yy_nxt CAIqHandler::ca strguts YY_STATE_EOF yy_flex_strlen operator\ == Msg_sync_completor_t::Msg_sync_completor_t yy_init_globals Registration_t::in_state_p Menu_cmd_t::exec flex_uint16_t CONN_STATE_AVAILABLE lock INT16_MIN A_client_t::m_msg_loop_running_p yy_ec yytnamerr 0 yytext YYDPRINTF DEBUG_VAR_TRACE YY_START UI_key_val_match_seq_t::UI_key_val_match_seq_t YY_NEW_FILE YY_RESTORE_YY_MORE_OFFSET valid_p c_str_less_p Argv_t::size yy_init_buffer YYTOKEN_TABLE yydestruct INTERACTIVE_OSTREAM yyset_lineno string_expr YYFAIL Msg_completor_base_t::m_con yytext_ptr yyget_debug CA_Dispatch_message_completor_t::CA_Dispatch_message_completor_t yytname YY_EXIT_FAILURE UI_msg_seq_t::poll_status yyunput FTCIStanza YY_TYPEDEF_YY_BUFFER_STATE Argv_t::raw_command_line RECV_TIMEOUT_none yyin A_client_t::init flex_uint32_t FTCIConnectionListener::m_ca FTCIRosterListener::handleItemUpdated yy_buffer_state::yy_is_our_buffer String_cmd_map_t 0 EOB_ACT_LAST_MATCH yyfree yy_buffer_stack_top yy_buffer_stack_max 0 FTCIRosterListener::handleRosterPresence 0 CAIqHandler::CAIqHandler yyout YY_BREAK FTCIRosterListener::handleItemRemoved Argv_t::push_back A_client_t::stop_msg_loop cap_name mk_tag_close YYSTATE flex_uint8_t UIM_GUI YYEOF YYRECOVERING yy_switch_to_buffer yy_flex_strncpy yyerrok flex_int16_t yy_accept yyget_out stmt_list short __STDC_LIMIT_MACROS yyerror FTCI_FML_protocol_version yydefgoto __anon1::desc 0 MESSAGE_HANDLER_BASE_DOT_H_INCLUDED PFTCI_msg_type_t FTCIIqHandler::handleIq yy_state_type yy_trans_info::yy_verify 0 YY_BUFFER_NEW yychar FTCIClient::set_peer_ip stop_msg_loop Inflight_msg_list_t::find_msg ENV_OVERRIDE_OP String_menu_map_t yylval input filter YYPURE initiator yy_buffer_state::yy_buffer_status A_client_t::start_req_with_reply LAST_SRET yy_buf_pos YY_DO_BEFORE_ACTION YY_INT_ALIGNED UIM_text Menu_cmd_t::m_cmd_name YY_START_STACK_INCR yy_scan_string flex_int32_t yy_start YY_DECL dupe_raw_command_line Capability_t::dump YYSIZE_MAXIMUM yy_scan_buffer yydebug CAMessageHandler::ca handleDiscoInfo FTCIRosterListener::handleRoster YY_SKIP_YYWRAP FTCI_msg_item_sep set_connected 0 YY_BUFFER_EOF_PENDING A_client_t::pmsg_reply yy_bs_column STRCMP_TOK YY_USER_ACTION YY_STACK_PRINT FTCIClient::send_msg yy_trans_info FTCI_CL_VER sm_next_msg_num xml_to_map Msg_copy_completor_t::m_response yypush_buffer_state YY_READ_BUF_SIZE YY_EXTRA_TYPE Argv_t::m_argv Dyn_type_t::copy FML_msg_tag RESV_STATE__first yy_try_NUL_trans RESV_STATE_RESERVED FTCIConnectionListener::FTCIConnectionListener CC_all_capabilities YY_MORE_ADJ 0 YYID FML_FN_RUN_CMD_LINE Inflight_msg_list_t::find_iter yyprhs 0 renew Registration_t::operator\ == symbol handleIqID 0 YYSTYPE_IS_DECLARED 0 FLEX_BETA 0 yyless MM_UI_match_low_level_sync MM_UI_match_async Inflight_msg_ptr_list_t find_iter YY_FLEX_SUBMINOR_VERSION CADiscoHandler::ca YYERROR operator\ bool yymore A_client_t::start_msg_loop DYNAMIC_TYPE_DOT_H_INCLUDED YYPACT_NINF yytype_uint16 Argv_t::dump log_streamp prepare_for_connection yy_buffer_state::yy_bs_column INT32_MIN 0 FTCI_message_t::app_cmd_line cap_index Run_mode_gui m_current Msg_test_completor_t::parent_class_t yy_flush_buffer FML_MTYPE_ECHO_REQ reg_description args_required yyparse UI_match_request_t::parse_matches interactive_p yystos YYSTYPE::s_val UINT16_MAX yyclearin add YYEMPTY FTCIDiscoHandler::handleDiscoInfo A_client_t::m_identifier Max_cap_name_len print_results_prefix yycheck INITIAL ltstr FTCILogHandler A_client_t::agent_connect yyconst peer_exists_p YY_FATAL_ERROR Argv_t::argc CONN_STATE_UNAVAILABLE YYUNDEFTOK yyrestart yy_buffer_state::yy_buf_pos yyrealloc LE_TOK yy_n_chars ENV_OVERRIDE 0 yylineno yy_buffer_state::yy_at_bol Inflight_msg_t::dump INT8_MIN Capability_t::args_required_p Con_or_default print_results YY_CHAR yypop_buffer_state YY_SC_TO_UI yy_ch_buf YYUSE YYSKELETON_NAME yytoknum print_STR_LIT A_client_t::A_client_t add_global_cap yyensure_buffer_stack yytranslate YY_BUF_SIZE FML_MTYPE_CON_DEREGISTER FTCIClient::set_peer MM_UI_match_simple_sync FTCIStanza::filter yy_load_buffer_state YYSTACK_ALLOC_MAXIMUM FTCI_message_t::compose_reply raw_command_line Nested_menu_t::Nested_menu_t pmsg_reply REG_STATE_PENDING_REGISTRATION FTCIRosterListener::handleSubscriptionRequest yy_did_buffer_switch_on_eof yystrlen yyr1 yy_buffer_state::yy_fill_buffer FTCIStanza::FTCIStanza equality_expr void_void_t A_lock_t::unlock YY_LESS_LINENO FTCI_message_t::from end 0 Argv_t::dupe_raw_command_line Argv_Echo_iter_t::operator\ \(\) 0 Capability_t::operator\ == SHARED_DEFS_H_INCLUDED YYRHSLOC string_true yyget_lineno Rapid_xml_node_t yy_symbol_value_print FML_MTYPE_MATCH_REQUEST YYTABLES_NAME CAConnectionListener::onTLSConnect 0 yy_buffer_state::yy_input_file logical_expr yy_get_previous_state ideq m_argc YYSTACK_GAP_MAXIMUM FTCI_msg_args_required UNARY_MINUS EOB_ACT_CONTINUE_SCAN unput FML_FN_LOG_MSG yy_verify mygetline YYNNTS Nested_menu_t::m_cmds UIM_none LAST_RET argc UI_msg_seq_t::m_wait_chan DEBUG_VAR_NAME_TO_STREAM FML_FN_SEQ_NUM Inflight_msg_list_t::remove Concierge_list yy_is_our_buffer m_ret_val FLEXINT_H YYINITDEPTH FML_MTYPE_REGISTER_ACK very_tmp_stream CAPI_key_val_match_app_name yy_last_accepting_state yypgoto m_annotation yy_set_bol A_client_t::make_connection FTCI_INITIATOR_SA Concierge_list_t::size A_client_t::CONN_STATE_all do_match Argv_t::argv_t status_streamp FTCIMessageHandler CONN_STATE_connected Capability_t REJECT pmsg_start_seq yy_buffer_state::yy_is_interactive YYFPRINTF 0 Reg_list_t ~FTCIStanza Argv_t::compose_command_line A_client_t m_peer_id yy_buffer_state::yy_n_chars yy_nxt yy_set_interactive yy_is_interactive Build_msg_t yystpcpy yyset_in set_registered yy_def 0 0 m_peer_ip m_messages YYSTYPE_SFMT ~A_cond_var_t yyinput yy_symbol_print YY_type_t FML_MTYPE_RESERVATION yytype_int8 Match_list_t::clear_parse Nested_menu_t::m_prompt A_client_t::msg_loop SA_concierge_t::SA_concierge_t yy_flex_debug YYSTACK_RELOCATE]
()
nil



========================
Wednesday May 23 2012
--

faf
/home/dapanarx/davep/dpw.git/

(define-abbrev dp-go-abbrev-table "faff" "find . -type f -print0 | xargs -r0 fgrep" nil 1)

"faff" "find . -type f -print0 | xargs -r0 fgrep"


(define-abbrev dp-go-abbrev-table "faff" "find . -type f -print0 | xargs -r0 fgrep" nil 1)

(dp-add-abbrev "faffX" "find . -type f -print0 | xargs -r0 fgrep" nil
               :table-names '(dp-manual))
(#<buffer "elisp-devel.el"> #<buffer " *Minibuf-1"> #<buffer "dp-common-abbrevs.el"> #<buffer "dp-abbrev.el"> #<buffer "dp-common-abbrevs-orig.el"> #<buffer "dp-abbrev-defs.el"> #<buffer "*shell*<0>"> #<buffer "*scratch*"> #<buffer ".go.emacs"> #<buffer "*Help: variable `dp-go-abbrev-table'*"> #<buffer " *Minibuf-0*"> #<buffer "*Hyper Help*"> #<buffer "lisp"> #<buffer "go2env"> #<buffer ".go"> #<buffer ".go.intel"> #<buffer "go-mgr"> #<buffer "mic-paren.el"> #<buffer "Man: xargs"> #<buffer "dpmisc.el"> #<buffer "gnuserv.el"> #<buffer "*background-1*"> #<buffer "process.el"> #<buffer "index-code"> #<buffer "*igrep*"> #<buffer "keydefs.el"> #<buffer "info.el"> #<buffer "disass.el"> #<buffer "cus-edit.el"> #<buffer "callers-of-rpt.el"> #<buffer "bytecomp.el"> #<buffer "dp-dot-emacs.intel.el"> #<buffer "bytecomp-runtime.el"> #<buffer " *Message-Log*"> #<buffer " *Echo Area*"> #<buffer " *substitute*"> #<buffer " *pixmap conversion*"> #<buffer "*Help: function `background'*"> #<buffer "*Completions*"> #<buffer "*journal-topics*"> #<buffer " *string-output*"> #<buffer " *string-output*<2>"> #<buffer "daily-2012-05.jxt"> #<buffer "*Buffer List*"> #<buffer "*Hyper Apropos*">)

(#<buffer "elisp-devel.el"> #<buffer " *Minibuf-1"> #<buffer "dp-abbrev.el"> #<buffer "dp-common-abbrevs-orig.el"> #<buffer "dp-common-abbrevs.el"> #<buffer "dp-abbrev-defs.el"> #<buffer "*shell*<0>"> #<buffer "*scratch*"> #<buffer ".go.emacs"> #<buffer "*Help: variable `dp-go-abbrev-table'*"> #<buffer " *Minibuf-0*"> #<buffer "*Hyper Help*"> #<buffer "lisp"> #<buffer "go2env"> #<buffer ".go"> #<buffer ".go.intel"> #<buffer "go-mgr"> #<buffer "mic-paren.el"> #<buffer "Man: xargs"> #<buffer "dpmisc.el"> #<buffer "gnuserv.el"> #<buffer "*background-1*"> #<buffer "process.el"> #<buffer "index-code"> #<buffer "*igrep*"> #<buffer "keydefs.el"> #<buffer "info.el"> #<buffer "disass.el"> #<buffer "cus-edit.el"> #<buffer "callers-of-rpt.el"> #<buffer "bytecomp.el"> #<buffer "dp-dot-emacs.intel.el"> #<buffer "bytecomp-runtime.el"> #<buffer " *Message-Log*"> #<buffer " *Echo Area*"> #<buffer " *substitute*"> #<buffer " *pixmap conversion*"> #<buffer "*Help: function `background'*"> #<buffer "*Completions*"> #<buffer "*journal-topics*"> #<buffer " *string-output*"> #<buffer " *string-output*<2>"> #<buffer "daily-2012-05.jxt"> #<buffer "*Buffer List*"> #<buffer "*Hyper Apropos*">)

dp-go-abbrev-table
[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]


find . -type f -print0 | xargs -r0 fgrep
find . -type f -print0 | xargs -r0 egrep
find . -type f -print0 | xargs -r0
find . -type f -print0 | xargs -r0 fgrep

dp-manual-abbrev-table
[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata symlink dq ws ccs PPT faffX hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]

global-abbrev-table
[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 yeild 0 0 0 0 0 0 0 0 0 0 0 peice 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

(cl-pe '(dp-deflocal dp-expand-abbrev-default-tables (list nil ; Default table.
                                                     dp-tmp-manual-abbrev-table
                                                     dp-go-abbrev-table 
                                                     dp-manual-abbrev-table)
  "All abbrev tables to check by default.  Use nil the current default table."))

(progn
  (defvar dp-expand-abbrev-default-tables (list nil dp-tmp-manual-abbrev-table dp-go-abbrev-table dp-manual-abbrev-table) "All abbrev tables to check by default.  Use nil the current default table.
(dp-deflocal)")
 (make-variable-buffer-local 'dp-expand-abbrev-default-tables)
 (setq-default dp-expand-abbrev-default-tables
 (list nil
 dp-tmp-manual-abbrev-table
 dp-go-abbrev-table
 dp-manual-abbrev-table)))nil

'(nil)
(nil)
osr
from table>[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
find . -type f -print0 | xargs -r0 fgrep
dp-expand-abbrev-default-tables
(nil)
(dp-init-abbrevs)

from table>[0 0 0 0 0 0 0 0 0 0 0 0 0 0 faffGo 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]<
find . -type f -print0 | xargs -r0 fgrep

from table>[0 0 0 0 0 0 0 0 0 faffBubba 0 0 0 0 faffGo 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]<
find Bubba -type f -print0 | xargs -r0 fgrep

from table>[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
find . -type f -print0 | xargs -r0 fgrep

;; a good one>>
(define-abbrev dp-go-abbrev-table "faff" "\"find . -type f -print0 | xargs -r0 fgrep\"" nil 1)

find . -type f -print0 | xargs -r0 fgrep
faff
dp-manual-abbrev-table
[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]

[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata symlink dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]
find
from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
find

from table>[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
find . -type f -print0 | xargs -r0 fgrep

from table>[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
find . -type f -print0 | xargs -r0 fgrep
from table>[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
find . -type f -print0 | xargs -r0 egrep
from table>[0 0 0 0 0 0 0 0 0 faffBubba 0 0 0 0 faffGo 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]<
faffGo
from table>[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
find . -type f -print0 | xargs -r0 fgrep

find . -type f -print0 | xargs -r0 fgrep

from table>[0 0 0 0 0 0 0 0 0 faffBubba 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]<
find Bubba -type f -print0 | xargs -r0 fgrep

from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
find

from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
find
from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
find
from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
find

from table>[0 0 0 0 0 0 0 0 0 faffBubba 0 0 0 0 faffGo 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]<
find Bubba -type f -print0 | xargs -r0 fgrep

from table>[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
find . -type f -print0 | xargs -r0

from table>[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
find . -type f -print0 | xargs -r0 fgrep
from table>[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
find . -type f -print0 | xargs -r0 egrep

find . -type f -print0 | xargs -r0 fgrep

find . -type f -print0 | xargs -r0 egrep
find . -type f -print0 | xargs -r0 fgrep
find . -type f -print0 | xargs -r0 fgrep
find . -type f -print0 | xargs -r0 fgrep
rc

dp-go-abbrev-table
[0 0 0 0 0 0 0 0 0 faffBubba 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

[0 0 0 0 0 0 0 0 0 faffBubba 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]
find . -type f -print0 | xargs -r0 fgrep
from table>[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
find . -type f -print0 | xargs -r0 fgrep
from table>[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
find . -type f -print0 | xargs -r0 egrep
from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
find
from table>[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
find . -type f -print0 | xargs -r0 fgrep
from table>[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
ASCII

dp-go-abbrev-table
[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]

[0 0 0 0 0 0 0 0 0 faffBubba 0 0 0 0 faffGo 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

[0 0 0 0 0 0 0 0 0 faffBubba 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]

from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
/home/dapanarx/work/ftci/
from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
/home/dapanarx/.rc/
from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
/home/dapanarx/.rc/

from table>[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
find . -type f -print0 | xargs -r0 fgrep
from table>[0 0 0 0 0 0 0 0 0 faffBubba 0 0 0 0 faffGo 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]<
find Go -type f -print0 | xargs -r0 fgrep
from table>[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
background
from table>[v srcs 0 inv dpdx faf fname land hud sf med ntms hier npc bg pita os fd envvar mem fafe faff libs FHR IMHO metadata faffMan dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
find . -type f -print0 | xargs -r0 egrep

dp-go-abbrev-table
[0 0 0 0 0 0 0 0 0 faffBubba 0 0 0 0 faffGo 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]

[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]

[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]

[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]


from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
/home/dapanarx/.rc/

from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
find
from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
find

from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
find

from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
/home/dapanarx/bin/
from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
find

(dp-add-abbrev "dpMan" "dpMan . -type f -print0 | xargs -r0 egrep" 
               nil :table-names '(dp-go))
(#<buffer "elisp-devel.el"> #<buffer " *Minibuf-1"> #<buffer "dp-common-abbrevs.el"> #<buffer "dp-abbrev.el"> #<buffer ".go.emacs"> #<buffer "*Help: function `dp-add-abbrev'*"> #<buffer "*grep*"> #<buffer "dp-vars.el"> #<buffer "dpmisc.el"> #<buffer "*igrep*"> #<buffer "*shell*<0>"> #<buffer "daily-2012-05.jxt"> #<buffer "symbols.c"> #<buffer "go2env"> #<buffer "*scratch*"> #<buffer "dp-abbrev-defs.el"> #<buffer "*Hyper Help*"> #<buffer "simple.el"> #<buffer "*Help: variable `dp-go-abbrev-table'*"> #<buffer "dp-common-abbrevs-orig.el"> #<buffer " *Minibuf-0*"> #<buffer "lisp"> #<buffer ".go"> #<buffer ".go.intel"> #<buffer "go-mgr"> #<buffer "mic-paren.el"> #<buffer "Man: xargs"> #<buffer "gnuserv.el"> #<buffer "*background-1*"> #<buffer "process.el"> #<buffer "index-code"> #<buffer "keydefs.el"> #<buffer "info.el"> #<buffer "disass.el"> #<buffer "cus-edit.el"> #<buffer "callers-of-rpt.el"> #<buffer "bytecomp.el"> #<buffer "dp-dot-emacs.intel.el"> #<buffer "bytecomp-runtime.el"> #<buffer " *Message-Log*"> #<buffer " *Echo Area*"> #<buffer " *substitute*"> #<buffer " *pixmap conversion*"> #<buffer "*Help: function `background'*"> #<buffer "*Completions*"> #<buffer "*journal-topics*"> #<buffer " *string-output*"> #<buffer " *string-output*<2>"> #<buffer "*Hyper Apropos*"> #<buffer "*Buffer List*"> #<buffer " *revert*">)



from table>[v srcs 0 inv dpdx ooi fname land hud sf med ntms hier npc bg dpMan os fd envvar mem osr wadr libs FHR IMHO metadata symlink dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
const char* 

from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
find

from table>[v srcs 0 inv dpdx ooi fname land hud sf med ntms hier npc bg dpMan os fd envvar mem osr wadr libs FHR IMHO metadata symlink dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
dpMan . -type f -print0 | xargs -r0 egrep

from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
/home/dapanarx/.rc/

from table>[v srcs 0 inv dpdx ooi fname land hud sf med ntms hier npc bg pita os fd envvar mem osr wadr libs FHR IMHO metadata symlink dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
ASCII

from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
/home/dapanarx/.rc/

from table>[v srcs 0 inv dpdx ooi fname land hud sf med ntms hier npc bg dpMan os fd envvar mem osr wadr libs FHR IMHO metadata symlink dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
dpMan . -type f -print0 | xargs -r0 egrep

from table>[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 dpMan 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]<
dpMan . -type f -print0 | xargs -r0 egrep
dpMan

from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
find

from table>[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]<
/home/dapanarx/.rc/

(dp-add-abbrev "dpGo" "dpGo . -type f -print0 | xargs -r0 egrep" 
               nil :table-names '(dp-go))
(#<buffer "elisp-devel.el"> #<buffer " *Minibuf-1"> #<buffer "dp-common-abbrevs.el"> #<buffer "dp-abbrev.el"> #<buffer ".go.emacs"> #<buffer "*Help: function `dp-add-abbrev'*"> #<buffer "*grep*"> #<buffer "dp-vars.el"> #<buffer "dpmisc.el"> #<buffer "*igrep*"> #<buffer "*shell*<0>"> #<buffer "daily-2012-05.jxt"> #<buffer "symbols.c"> #<buffer "go2env"> #<buffer "*scratch*"> #<buffer "dp-abbrev-defs.el"> #<buffer "*Hyper Help*"> #<buffer "simple.el"> #<buffer "*Help: variable `dp-go-abbrev-table'*"> #<buffer "dp-common-abbrevs-orig.el"> #<buffer " *Minibuf-0*"> #<buffer "lisp"> #<buffer ".go"> #<buffer ".go.intel"> #<buffer "go-mgr"> #<buffer "mic-paren.el"> #<buffer "Man: xargs"> #<buffer "gnuserv.el"> #<buffer "*background-1*"> #<buffer "process.el"> #<buffer "index-code"> #<buffer "keydefs.el"> #<buffer "info.el"> #<buffer "disass.el"> #<buffer "cus-edit.el"> #<buffer "callers-of-rpt.el"> #<buffer "bytecomp.el"> #<buffer "dp-dot-emacs.intel.el"> #<buffer "bytecomp-runtime.el"> #<buffer " *Message-Log*"> #<buffer " *Echo Area*"> #<buffer " *substitute*"> #<buffer " *pixmap conversion*"> #<buffer "*Help: function `background'*"> #<buffer "*Completions*"> #<buffer "*journal-topics*"> #<buffer " *string-output*"> #<buffer " *string-output*<2>"> #<buffer "*Hyper Apropos*"> #<buffer "*Buffer List*"> #<buffer " *revert*">)
dpGo
from table>[v srcs 0 inv dpdx ooi fname land hud sf med ntms hier npc bg pita os fd envvar mem osr wadr libs FHR IMHO metadata symlink dq ws ccs PPT yopp hp xmission mks arg bup seqs sand te dap 0 con 0 FCFS LARTC dep STFU ascii IMO phr exe devel vp BCBS WH vvs md acet]<
Prop_handler_ret_t
from table>[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 dpGo 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]<
dpGo . -type f -print0 | xargs -r0 egrep



(defun dp-add-abbrevs (abbrev-list &rest rest)
  ;; apply dp-add-abbrev to each element in abbrev-list where rest is passed through to dp-add-abbrev.
                


========================
Friday May 25 2012
--

dp-go-abbrev-table
[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]

phr
[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]

[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]

[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]

[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 faffQ 0 0 0 0 0 0 faffX 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 faffX 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

[0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 faffX 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]

[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]

(listp nil)
t

(setq dpgat dp-go-abbrev-table)
[alien ppp 0 dpgit 0 pocc dpgitbin ulb 0 0 pine 0 0 0 yb lisp poc ye poccc 0 yokeletc pocs 0 fluent yl 0 0 ksrc pydb pya yokelsbin 0 testA yokellib testC 0 poccom work 0 0 dpw elm inb notes 0 dpgitlisp 0 0 doc 0 0 poclib yokelbin yokel 0 0 ysb 0 0]


(dp-add-abbrev "faffX" "find . -type f -print0 | xargs -r0 fgrep" nil
               :table-names '(dp-go))
(#<buffer "elisp-devel.el"> #<buffer " *Minibuf-0*"> #<buffer "dp-abbrev.el"> #<buffer "*grep*"> #<buffer "dp-abbrev-defs.el"> #<buffer "dp-common-abbrevs.el"> #<buffer "*Hyper Apropos*"> #<buffer "abbrev.el"> #<buffer "compile.el"> #<buffer "*scratch*"> #<buffer " *Echo Area*"> #<buffer " *Message-Log*"> #<buffer " *substitute*"> #<buffer " *pixmap conversion*">)

(#<buffer "elisp-devel.el"> #<buffer " *Minibuf-0*"> #<buffer "dp-abbrev.el"> #<buffer "*grep*"> #<buffer "dp-abbrev-defs.el"> #<buffer "dp-common-abbrevs.el"> #<buffer "*Hyper Apropos*"> #<buffer "abbrev.el"> #<buffer "compile.el"> #<buffer "*scratch*"> #<buffer " *Echo Area*"> #<buffer " *Message-Log*"> #<buffer " *substitute*"> #<buffer " *pixmap conversion*">)


========================
Thursday June 14 2012
--
(dp-get-*TAGS-handler-list)
([cl-struct-dp-*TAGS-handler find-tag pop-tag-mark find-tag-other-window])




========================
Thursday June 21 2012
--
?*
?*
?x
?x

(format "%d" ?*)
"42"

"*"


(defvar dp-c-doxy-comment-first-line-format 
  "
 /*%s*/"
  "Opening line in a C/C++ doxy comment. Will be filled to C[++] fill column.")

(defvar doxy-c-class-member-comment-elements '( > "
 /*!" > "
  * @brief " (P "brief desc: " desc nil) > "
  */" > % >)
  "Elements of a class function comment template")

(defvar doxy-c-function-comment-elements '( > "
 /*!" > "
  * @brief " (P "brief desc: " desc nil) > "
  */" > % >)
  "Elements of a C/C++ function comment template")

(defvar doxy-c-class-comment-elements '( > "
 /*!" > "
 * @class " p > "
 * @brief " (P "brief desc: " desc nil) > "
 */" > % >)
  "Elements of a C/C++ class comment template")

(defvar dpx '(a b))


dpx

dpx


dpx

dpx

CRAP! need class indent to members for correct length.
(defun* dp-c-define-doxy-tempo-templates (&optional (num-stars 72)
                                          (star ?*))
  ;; lead by: "/*" and trailed by: "*/" == 4 chars
  (let ((stars (make-string (- dp-line-too-long-warning-column 1 4)
                           star))
        (tempo-define-template "doxy-c-class-member-comment"
                               doxy-c-class-member-comment-elements)
  (tempo-define-template "doxy-c-function-comment"
                         doxy-c-function-comment-elements)
  (tempo-define-template "doxy-c-class-comment"
                         doxy-c-class-comment-elements))

  (defmacro dp-deflocal (name init-val &optional docstring)
    "Define a variable and make it buffer local."
    (setq docstring
          (if docstring
              (setq docstring (format "%s\n(dp-deflocal)" docstring))
            "Undocumented. (dp-deflocal)"))
    `(progn
      (defvar ,name ,init-val ,docstring)
      (make-variable-buffer-local ',name)
      (setq-default ,name ,init-val)))

  (put 'dp-deflocal 'lisp-indent-function lisp-body-indent)

(defvar dpx '(forced))
dpx

(cl-pe '(setq-ifnil dpxl 'blah))

(if dpxl dpxl (setq dpxl 'blah))nil

(cl-pe '(setq-ifnil-or-unbound zzz 'no-zzz))

(if (progn nil (and (boundp 'zzz) zzz)) zzz (setq arg 'no-zzz))nil



(progn
  (defvar dpxl 'blah "Undocumented. (dp-deflocal)")
  (make-variable-buffer-local 'dpxl)
  (setq-default dpxl 'blah))nil
(defvar dpx '(forced))
dpx






(defvar 'dpx '(forced)) ==> (defvar (quote dpx) (quote (forced)))
(defvar 'dpx '(forced) "some doc") ==> 
                (defvar (quote dpx) (quote (forced)) "some doc")

(defvar dpx '(forced) "some doc")
dpx
(forced)
(eval-interactive-verbose nil)

(defmacro dp-revar (name init-val &optional docstring)
  "Force reevaluation of a defvar just like eval'ing in interactive lisp mode."
  (let ((expr `(defvar 
                ,name
                ,init-val)))
    (when docstring
      (setq expr `(,@expr ,docstring)))
    `(let ((eval-interactive-verbose nil))
      (eval-interactive (quote ,expr)))))

(cl-pe '(dp-revar dpx '(forced) "some doc"))

(let ((eval-interactive-verbose nil))
  (eval-interactive 
   '(defvar dpx (quote (forced)) "some doc")))


========================
Monday June 25 2012
--

(defun dp-delete-co-region (&optional beg end)
  (multiple-value-bind 
      (beg end) 
      (dp-region-boundaries-ordered beg end)
    (dp-iterate-lines-in-region (beg end (function 
                                          (lambda ()
                                            (beginning-of-line)
                                            (when)
                                            
                                            )))

)


dpvt
(1 9 "sudo" nil "*dse-debug*" nil "tee" "-a" "/home/dapanarx/tmp/dse-test")


========================
Monday July 02 2012
--

(defun dp-c-get-syntactic-line-indentation ()
  "Determine `c++-mode's desired indentation for this line."
  (interactive)
  (let ((indentation (c-get-syntactic-indentation
                      (c-guess-basic-syntax))))
    (when (interactive-p)
      (message "%s: desired indentation: %s" major-mode indentation))
    indentation))




========================
Monday July 09 2012
--
(defun dp-c*-next-line (count)
  "Add trailing white space removal functionality."
  (interactive "_p")
  (loop repeat count do
    (if (eolp)
        (dp-func-and-move-down 'dp-cleanup-line
                               t
                               'next-line)
      (call-interactively 'next-line))))
    

========================
Monday July 16 2012
--




(cl-pe '(dp-with-all-output-to-string (princf "CCC")))

(save-current-buffer (set-buffer (get-buffer-create (generate-new-buffer-name " *string-output-CCC*")))
                     (setq buffer-read-only nil)
                     (buffer-disable-undo (current-buffer))
                     (erase-buffer)
                     (unwind-protect
                         (progn
                           (let ((standard-output (current-buffer)))
                             (princf "CCC"))
                           (buffer-string))
                       (set-buffer-modified-p nil)
                       (kill-this-buffer)))
"CCC
"







========================
Wednesday July 18 2012
--

;; thinks we don't have a fully functional terminal
;;work on this later.; (defun gith (topic &optional sync-p)
;;work on this later.;   (interactive "sgit help on: \nP")
;;work on this later.;   (shell-command (concat "git help " topic
;;work on this later.;                          (if sync-p "" "&"))))


========================
Thursday July 19 2012
--

;;installed; (defun dp-gnuserv-find-file-function (path)
;;installed;   "Called when gnuserv edits a file.
;;installed; This could be done with advice, but advice should be avoided if another
;;installed; solution exists. In this case, the `gnuserv-find-file-function' variable."
;;installed;   (interactive "fFile: ")
;;installed;   ;; gnuserv unconditionally goes to the line in the message.
;;installed;   ;; Makes sense, except when the file is already being edited.
;;installed;   ;; So, if the file is already in a buffer, then we push a go-back
;;installed;   (let ((visited-p (get-file-buffer path)))
;;installed;     (dp-find-file path)
;;installed;     (when visited-p
;;installed;       (dp-push-go-back "gnuserv visiting an already visited file"))))

;;installed; (setq gnuserv-find-file-function 'dp-gnuserv-find-file-function)


========================
Monday July 23 2012
--
(describe-bindings-internal emacs-lisp-mode-map)

tab             dp-python-indent-command
delete          dp-delete
C-tab           lisp-complete-symbol
C-/             eldoc-doc
C-c             << Prefix Command >>
C-p             << Prefix Command >>
C-x             << Prefix Command >>
C-z             dp-shell
M-tab           lisp-complete-symbol
M-return        dp-open-newline
M-;             lisp-indent-for-comment
M-`             comint-previous-matching-input-from-input
M-q             dp-fill-paragraph-or-region-with-no-prefix
M-s             dp-upcase-preceding-symbol
M-backspace     dp-delete-word
M-left          dp-beginning-of-defun
M-right         dp-end-of-defun
M-C-return      Anonymous Lambda
M-C-i           lisp-complete-symbol
M-C-p           py-beginning-of-def-or-class
M-C-q           indent-sexp
M-C-x           dp-eval-defun-or-region

C-c !           dp-python-shell
C-c C-c         gnuserv-edit

C-p `           comint-previous-matching-input-from-input

C-x C-left      py-beginning-of-def-or-class
nil

Minor Mode Bindings for `flyspell-mode':
key             binding
---             -------



========================
Wednesday July 25 2012
--

(defvar ffap-string-at-point-mode-alist
  '(
    ;; The default, used when the `major-mode' is not found.
    ;; Slightly controversial decisions:
    ;; * strip trailing "@" and ":"
    ;; * no commas (good for latex)
    ;; BUT commas are good for me for names to be ignored by version controlled
    ;;;(file "--:$+<>@-Z_a-z~" "<@" "@>;.,!?:")
    (file "--:$+<>@-Z_a-z~," "<@" "@,>;.!?:")
    ;; An url, or maybe a email/news message-id:
    (url "--:=&?$+@-Z_a-z~#,%" "^A-Za-z0-9" ":;.,!?")
    ;; Find a string that does *not* contain a colon:
    (nocolon "--9$+<>@-Z_a-z~" "<@" "@>;.,!?")
    ;; A machine:
    (machine "-a-zA-Z0-9." "" ".")
    ;; Mathematica paths: allow backquotes
    (math-mode ",-:$+<>@-Z_a-z~`" "<" "@>;.,!?`:")
    )
  "Alist of \(MODE CHARS BEG END\), where MODE is a symbol,
possibly a `major-mode' or some symbol internal to ffap
\(such as 'file, 'url, 'machine, and 'nocolon\).
`ffap-string-at-point' uses the data fields as follows:
1. find a maximal string of CHARS around point,
2. strip BEG chars before point from the beginning,
3. Strip END chars after point from the end.")

ffap-string-at-point-mode-alist

========================
Thursday July 26 2012
--
gdb-arrow-extent
#<extent *[5723, 5746) 0x1803d7b0 in buffer fml.h>



;;installed; (defun dp-gdb-scroll-down-source-buffer (num)
;;installed;   (interactive "_p")
;;installed;   (let ((buffer (and gdb-arrow-extent
;;installed;                      (extent-object gdb-arrow-extent)))
;;installed;         window)
;;installed;     (if (not buffer)
;;installed;         (call-interactively 'dp-scroll-down-other-window)
;;installed;       (setq window (display-buffer buffer))
;;installed;       (with-selected-window window
;;installed;         (dp-scroll-down num)))))

;;installed; (defun dp-gdb-scroll-up-source-buffer (num)
;;installed;   (interactive "_p")
;;installed;   (let ((buffer (and gdb-arrow-extent
;;installed;                      (extent-object gdb-arrow-extent)))
;;installed;         window)
;;installed;     (if (not buffer)
;;installed;         (call-interactively 'dp-scroll-up-other-window)
;;installed;       (setq window (display-buffer buffer))
;;installed;       (with-selected-window window
;;installed;         (dp-scroll-up num)))))



========================
Friday July 27 2012
--

(cl-pe '(decf num))

(setq num (1- num))nil


========================
Wednesday August 08 2012
--


========================
Thursday August 09 2012
--
;; a good one>>
(define-abbrev dp-go-abbrev-table "faff" "\"find . -type f -print0 | xargs -r0 fgrep\"" nil 1)
faff

(define-abbrev dp-go-abbrev-table "faff" "\"find . -type f -print0 | xargs -r0 fgrep\"" nil 1)

find . -type f -print0 | xargs -r0 fgrep
faff

faff
pocc
========================
Friday August 17 2012
--


(mapconcat FUNCTION SEQUENCE SEPARATOR)

(mapconcat (lambda (x)
             (format "%s" x))
           '(i 2 3)
           "-")
"i-2-3"



"i-2-3"

"a-b-c"


(let* ((what '(header-doc))
       (what-name (concat "q.v.-"
                          (mapconcat (lambda (x)
                                       (format "%s" x))
                                     what
                                     "-")))
       ;; Do this or make an assoc?
       (what-sym (intern-soft what-name)))
  (princf "what-name>%s<" what-name)
  (princf "what-sym>%s<" what-sym)
  (when what-sym
    (funcall what-sym)))
what-name>q.v.-header-doc<
what-sym>q.v.-header-doc<

what-name>q.v.-header-doc<
what-sym>q.v.-header-doc<

what-name>q.v.-header-doc<
what-sym>q.v.-header-doc<

what-name>q.v.-header-doc<
what-sym>q.v.-header-doc<

what-name>q.v.-header-doc<
what-sym>q.v.-header-doc<

what-name>q.v.-a-b-c<
what-sym>nil<
nil

what-sym>nil<
nil





========================
Wednesday August 29 2012
--
(("a" "b") "a" "b")
(("a" "b") t) -->

(let ((e '(("a" "b") t))
      a b c d)
  (princf "%s" (car e))
  (princf "%s" (cdr e))
  (setq c (car e))
  (setq a (cons c c))
  (princf "%s" a)



(listp nil)
t

(and-listp)

queue

)
(a b)
(t)
((a b) a b)
nil

(a b)
(t)
nil
nil

(a b)
(t)

(a b)
(t)

(a b)
(t)

(a b)
(t)
nil

;;; Abbrev entry format:
;;; ABBREV-ENTRY ::= (ABBREVS/EXPANSIONS TABLE-INFO)
;;; ABBREVS/EXPANSIONS ::= (ABBREV-NAMES EXPANSIONS)
;;; ABBREV-NAMES ::= \"abbrev-name\" | (\"abbrev-name0\"...)
;;; EXPANSIONS ::= \"expansion0\"...
;;; TABLE-INFO ::= TABLE-NAME | TABLE-INFO-PLIST
;;; TABLE-NAME ::= 'table-name-sym | \"table-name\"  ; it's `format'd w/%s
;;; TABLE-INFO-PLIST ::= (PROP/VAL PROP/VAL ...)
;;; PROP/VAL ::= 'table-name TABLE-NAME


(dp-redefine-abbrev '((("abbrev-test-a" "abbrev-test-bb" "abbrev-test-ccc")
                       "abbrev-test-a" "abbrev-test-bb" "abbrev-test-ccc")
                     dp-manual))




(dp-redefine-abbrev '((("abbrev-test-a" "abbrev-test-bb" "abbrev-test-ccc")
                       (t))
                     dp-manual))






device



========================
Thursday August 30 2012
--
(dp-abbrev-mk-abbrev-table-name dp-default-abbrev-table)
"dp-manual-abbrev-table"

"dp-manual-abbrev-table"
)

(dp-rotate-and-func '(a b c) 'a)
(a b c)
(a b c)

(dp-rotate-and-func '(a b c) 'q)
<error>

(dp-rotate-and-func '(a b c) 'a 'remove)
(b c)
(b c)

(dp-rotate-and-func '(a b c) 'q 'remove)
<error>

(dp-rotate-and-func '() 'a)
nil

(dp-rotate-and-func '() 'a 'dp-nop)
a

(setq dp-q "a b")
"a b"

(setq dp-qi (intern "dp-q"))
dp-q

(symbol-value (intern "dp-q"))
"a b"



ehoh



(dp-nop)
nil






========================
Friday September 14 2012
--

(car-safe nil)
nil

;; dedicated is least best. selection-preference = - (1/0)
;; 

(dp-deflocal dp-selection-preference 0
  "How much do we want to choose this buffer's window as the
`other' or `next' or whatever window?")

(defun dp-get-selection-preference (&optional buffer)
  (setq-ifnil buffer (current-buffer))
  ;; If buffer is in a dedicated window, return very small
  (buffer-local-value 'dp-selection-preference buffer))

(defun dp-best-other-window (&optional win-list frame minibuf window)
  (interactive)
  (setq-ifnil win-list (window-list frame minibuf window))
  ;; For all buffers displayed in windows
  ;; find highest preference.
  (let ((original-buffer (current-buffer))
        (buffers (dp-all-window-buffers win-list))
        (best-pref -999999)
        best-buf buf pref)
    (setq buffers (cdr-safe buffers))
    (while buffers
      (setq buf (car buffers)
            pref (dp-get-selection-preference buf))
      (when (and (not (equal original-buffer buf))
                 (> pref best-pref))
        (setq best-buf buf
              best-pref pref))
      (setq buffers (cdr buffers)))
    best-buf))


(dp-best-other-window)
#<buffer "config">

#<buffer "*Hyper Help*">

#<buffer "dpmisc.el">

#<buffer "dpmisc.el">

#<buffer "config">

#<buffer "dpmisc.el">

#<buffer "dpmisc.el">

#<buffer "elisp-devel.el">


#<buffer "elisp-devel.el">

nil


========================
Thursday September 20 2012
--

(defun cre-guts (reparse limit-search find-at-least)
        (set-buffer compilation-last-buffer)
      ;; If we are out of errors, or if user says "reparse",
      ;; discard the info we have, to force reparsing.
      (if (or (eq compilation-error-list t)
	      reparse)
	  (compilation-forget-errors))
      (if (and compilation-error-list
	       (or (not limit-search)
		 (> compilation-parsing-end limit-search))
	     (or (not find-at-least)
		 (>= (length compilation-error-list) find-at-least)))
	;; Since compilation-error-list is non-nil, it points to a specific
	;; error the user wanted.  So don't move it around.
	nil

      ;; XEmacs change: if the compilation buffer is already visible
      ;; in a window, use that instead of thrashing the display.
      (let ((w (get-buffer-window compilation-last-buffer)))
	(if w
	    (select-window w)
	  (switch-to-buffer compilation-last-buffer)))

      ;; This was here for a long time (before my rewrite); why? --roland
      ;;(switch-to-buffer compilation-last-buffer)
      (set-buffer-modified-p nil)
      (if (< compilation-parsing-end (point-max))
	  ;; compilation-error-list might be non-nil if we have a non-nil
	  ;; LIMIT-SEARCH or FIND-AT-LEAST arg.  In that case its value
	  ;; records the current position in the error list, and we must
	  ;; preserve that after reparsing.
	  (let ((error-list-pos compilation-error-list))
	    (funcall compilation-parse-errors-function
		     limit-search
		     (and find-at-least
			  ;; We only need enough new parsed errors to reach
			  ;; FIND-AT-LEAST errors past the current
			  ;; position.
			  (- find-at-least (length compilation-error-list))))
	    ;; Remember the entire list for compilation-forget-errors.  If
	    ;; this is an incremental parse, append to previous list.  If
	    ;; we are parsing anew, compilation-forget-errors cleared
	    ;; compilation-old-error-list above.
	    (setq compilation-old-error-list
		  (nconc compilation-old-error-list compilation-error-list))
	    (if error-list-pos
		;; We started in the middle of an existing list of parsed
		;; errors before parsing more; restore that position.
		(setq compilation-error-list error-list-pos))
	    ))))

(defun compile-reinitialize-errors (reparse
                                    &optional limit-search find-at-least)
  (save-excursion
    ;; XEmacs change: Below we made a change to possibly change the
    ;; selected window.  If we don't save and restore the old window
    ;; then if we get an error such as 'no more errors' we'll end up
    ;; in the compilation buffer.
    (save-window-excursion
      (cre-guts reparse limit-search find-at-least)
)
))

========================
Wednesday October 10 2012
--

c-simple-skip-symbol-backward
c-simple-skip-symbol-backward


========================
Tuesday November 13 2012
--
#!/bin/sh

source script-x
set -u
progname="$(basename $0)"

cols=${1-}
shift
lines=${1-}
shift

echo 1>&2 COLUMNS=$cols LINES=$lines "$@"
COLUMNS=$cols LINES=$lines "$@"


========================
Thursday November 15 2012
--
(lambda (buffer) 
  (unless (and (buffer-file-name buffer) 
               (file-exists-p (buffer-file-name buffer))) 
    (set-buffer-modified-p t buffer)) 
  (switch-to-buffer buffer))

========================
Wednesday November 21 2012
--

(defun* dp-mk-shell-frame (&key (width 256)
                           (height 47))
  (interactive)
  (select-frame-set-input-focus (make-frame))
  (dp-set-frame-width width)
  (dp-set-frame-height height))


========================
Monday December 03 2012
--
(setq ORIG-comint-password-prompt-regexp comint-password-prompt-regexp)
"\\(\\([Oo]ld \\|[Nn]ew \\|^\\)[Pp]assword\\|pass ?phrase\\):\\s *\\'\\|\\(Enter passphrase for.*: \\)\\|\\(\\[sudo\\] password for dapanarx.*: \\)\\|\\(Enter passphrase for.*: \\)\\|\\(\\[sudo\\] password for dapanarx.*: \\)\\|\\(Enter passphrase for.*: \\)\\|\\(Enter password.*: \\)\\|\\(\\[sudo\\] password for dapanarx.*: \\)"

"\\(\\([Oo]ld \\|[Nn]ew \\|^\\)[Pp]assword\\|pass ?phrase\\):\\s *\\'\\|\\(Enter passphrase for.*: \\)\\|\\(\\[sudo\\] password for dapanarx.*: \\)\\|\\(Enter passphrase for.*: \\)\\|\\(\\[sudo\\] password for dapanarx.*: \\)"

"\\(\\([Oo]ld \\|[Nn]ew \\|^\\)[Pp]assword\\|pass ?phrase\\):\\s *\\'\\|\\(Enter passphrase for.*: \\)\\|\\(\\[sudo\\] password for dapanarx.*: \\)"

"\\(\\([Oo]ld \\|[Nn]ew \\|^\\)[Pp]assword\\|pass ?phrase\\):\\s *\\'\\|\\(Enter passphrase for.*: \\)\\|\\(\\[sudo\\] password for dapanarx.*: \\)"

(posix-string-match (concat "^" "Enter passphrase for" "$")
              comint-password-prompt-regexp)
nil


========================
Thursday December 13 2012
--
(dp-build-co-comment-start "bubba")
";bubba "

";bubba "

";bubba "



(dp-build-co-comment-start "bubba" nil :end "<<<" :num-starts 3)
";;;bubba<<< "


";bubba<<< "

";bubba<<< "

";bubba<<< "

"endbubba"

";bubba "

"; "

"; "

(dp-build-co-comment-start "" nil :num-starts 3)
";;; "

"; "

""


(dp-build-co-comment-start "tag" ";" :end "z" :num-starts 3)
";;;tagz"

";;;tag"

";;;tag"
comment-start
"; "

"; ; ;tag "


"aaatag!!!"

"aaataga"

";;;tag;"

";;;tag;"

";;;tag;"

(dp-add-local-variables-hack '("setq" "funcall" "blah"))
(nil nil nil nil nil)


(let* ((v '(0))
       (v (cons "a" v))
       (v (append v (list "z"))))
  v)
("a" 0 "z")

("a" 0 . "z")

(nconc '(a b) "c")
(a b . "c")

(a b "c")

(a b . "c")


("a" 0 . "z")

("a" . "z")

("a")


(append '("a") '("q") '("b"))
("a" "q" "b")

("a" "b")


(dp-build-co-comment-start "blah" nil :end "***"
                           :num-starts 3)
";;;blah*** "

"*********blah"

(dp-build-co-comment-start "setq" ";" :end "z" :num-starts 3)
";;;setqz"

(dp-add-local-variables-hack 
   '("mode:sh"
     "comment-start: \"#\""
     "comment-end: \"\""))
(nil nil nil nil nil)

(dpj-sticky-variables-hack)
(nil nil nil)

(append '(a) nil nil)
(a)



     "comment-start: \"#\""
     "comment-end: \"\""))
)
(dpj-sticky-variables-hack)
(nil nil nil nil nil)



  (dp-add-local-variables-hack 
   '("(dpj-make-sticky)")))
dpj-sticky-variables-hack


dpj-sticky-variables-hack


     "comment-start: \"#\""
     "comment-end: \"\""))

(dp-mk-local-variables-hack-header)


(dp-mk-local-variables-hack '(a b 1) t)

(dp-build-co-comment-start 
                         (concat " " "a")  nil 
                         :end " ***"
                         :num-starts 3)


(defun isearch-done (&optional nopush edit)
  ;; Called by all commands that terminate isearch-mode.
  (dmessage "isearch-done: point: %s" (point))
  (dmessage "isearch-done: mark: %s" (mark))
  (dmessage "isearch-done: region-beginning: %s" (region-beginning))

  (setq isearch-window-configuration nil)
  (let ((inhibit-quit t)) ; danger danger!
    (if (and isearch-buffer (buffer-live-p isearch-buffer))
	;; Some loser process filter might have switched the window's
	;; buffer, so be sure to set these variables back in the
	;; buffer we frobbed them in.  But only if the buffer is still
	;; alive.
	(with-current-buffer isearch-buffer
	  (setq overriding-local-map nil)
	  ;; Use remove-hook instead of just setting it to our saved value
	  ;; in case some process filter has created a buffer and modified
	  ;; the pre-command-hook in that buffer...  yeah, this is obscure,
	  ;; and yeah, I was getting screwed by it. -jwz
	  (remove-hook 'pre-command-hook 'isearch-pre-command-hook)
	  (set-keymap-parents isearch-mode-map nil)
	  (setq isearch-mode nil)
	  (redraw-modeline)
	  (isearch-dehighlight)
	  (isearch-highlight-all-cleanup)
	  (isearch-restore-invisible-extents nil nil)
	  ))

    ;; it's not critical that this be inside inhibit-quit, but leaving
    ;; things in small-window-mode would be bad.
    (let ((found-start (window-start (selected-window)))
	  (found-point (point)))
      (cond ((eq (selected-frame) isearch-selected-frame)
	     (if isearch-small-window
		 (goto-char found-point)
	       ;; Exiting the save-window-excursion clobbers
	       ;; window-start; restore it.
	       (set-window-start (selected-window) found-start t))))
      ;; If there was movement, mark the starting position.
      ;; Maybe should test difference between and set mark iff > threshold.
      (dmessage "isearch-done[1]: region-beginning: %s" (region-beginning))
      (if (and (buffer-live-p isearch-buffer)
 	       (/= (point isearch-buffer) isearch-opoint))
 	  ;; #### FSF doesn't do this if the region is active.  Should
 	  ;; we do the same?
 	  (progn
 	    (push-mark isearch-opoint t nil isearch-buffer)
 	    (or executing-kbd-macro (> (minibuffer-depth) 0)
 		(display-message 'command "Mark saved where search started"))))
)
    (dmessage "isearch-done[2]: region-beginning: %s" (region-beginning))

    (setq isearch-buffer nil)
    (dmessage "isearch-done[3]: region-beginning: %s" (region-beginning))
    ) ; inhibit-quit is t before here

  (when (and (> (length isearch-string) 0) (not nopush))
    ;; Update the ring data.
    (dmessage "isearch-done[4]: region-beginning: %s" (region-beginning))
    (isearch-update-ring isearch-string isearch-regexp))

  (run-hooks 'isearch-mode-end-hook)
  (dmessage "isearch-done[5]: region-beginning: %s" (region-beginning))

  (and (not edit) isearch-recursive-edit (exit-recursive-edit))
  (dmessage "isearch-done[n]: region-beginning: %s" (region-beginning))

)


(defun zmacs-activate-region ()
  "Make the region between `point' and `mark' be active (highlighted),
if `zmacs-regions' is true.  Only a very small number of commands
should ever do this.  Calling this function will call the hook
`zmacs-activate-region-hook', if the region was previously inactive.
Calling this function ensures that the region stays active after the
current command terminates, even if `zmacs-region-stays' is not set.
Returns t if the region was activated (i.e. if `zmacs-regions' if t)."
  (dmessage "zmacs-activate-region: point: %s" (point))
  (dmessage "zmacs-activate-region: mark: %s" (mark))
  (dmessage "zmacs-activate-region: region-beginning: %s" (region-beginning))
  (if (not zmacs-regions)
      nil
    (setq zmacs-region-active-p t
	  zmacs-region-stays t
	  zmacs-region-rectangular-p (and-boundp 'mouse-track-rectangle-p
                                       mouse-track-rectangle-p))
    (if (marker-buffer (mark-marker t))
	(zmacs-make-extent-for-region (cons (point-marker t) (mark-marker t))))
    (run-hooks 'zmacs-activate-region-hook)
    t))



========================
Wednesday December 26 2012
--
(progn
  (save-excursion
    (dp-colorize-matching-lines "breakpoint 3, c_ip_interface::getnextbyte.*$"))
  (save-excursion
    (dp-colorize-matching-lines "breakpoint 2, c_ip_interface::start.*id=0x0, bitstreamdata=0x1) at ip_interface\\.cpp:370.*$"))
  (save-excursion 
    (dp-colorize-matching-lines "#1  0x[0-9a-f]* in c_ip_interface::start.*0x0, bitstreamdata=0x1) at ip_interface\\.cpp:370.*$"))
  (save-excursion
    (dp-colorize-matching-lines "breakpoint 1, c_ip_interface::stop (this=0x[0-9a-f]*, id=0x0, bitstreamdata=0x1) at ip_interface.cpp:403.*$"))
)


(setq dp-tmp-v1 '("breakpoint 3, c_ip_interface::getnextbyte.*$"
                  "breakpoint 2, c_ip_interface::start.*id=0x0, bitstreamdata=0x1) at ip_interface\\.cpp:370.*$"
                  "#1  0x[0-9a-f]* in c_ip_interface::start.*0x0, bitstreamdata=0x1) at ip_interface\\.cpp:370.*$"
                  "breakpoint 1, c_ip_interface::stop (this=0x[0-9a-f]*, id=0x0, bitstreamdata=0x1) at ip_interface.cpp:403.*$"))
("breakpoint 3, c_ip_interface::getnextbyte.*$" "breakpoint 2, c_ip_interface::start.*id=0x0, bitstreamdata=0x1) at ip_interface\\.cpp:370.*$" "#1  0x[0-9a-f]* in c_ip_interface::start.*0x0, bitstreamdata=0x1) at ip_interface\\.cpp:370.*$" "breakpoint 1, c_ip_interface::stop (this=0x[0-9a-f]*, id=0x0, bitstreamdata=0x1) at ip_interface.cpp:403.*$")



========================
Thursday December 27 2012
--
(dp-gdb-most-recent-buffer 
 :dead-or-alive-p t)

(let ((dead-or-alive-p t))
  (dp-choose-buffers (function 
                      (lambda (buf-cons)
                        (when (or dead-or-alive-p
                                  (dp-buffer-process-live-p 
                                   (car buf-cons)))
                          buf-cons)))
                     dp-gdb-buffers))
(#<buffer "elisp-devel.el"> #<buffer "dp-shells.el"> #<buffer " *Minibuf-0*"> #<buffer "*scratch*"> #<buffer "*grep*"> #<buffer "dpmisc.el"> #<buffer "just-opcodes.0"> #<buffer "*shell*<0>"> #<buffer "dp-keys.el"> #<buffer " *Echo Area*"> #<buffer " *Message-Log*"> #<buffer " *substitute*"> #<buffer " *pixmap conversion*"> #<buffer " *Recovered Context*"> #<buffer " *string-output*"> #<buffer " *string-output*<2>"> #<buffer "*Buffer List*"> #<buffer "bsev_command_decoder.cpp"> #<buffer "bitstream_fetch_engine.cpp"> #<buffer "ip_interface.cpp"> #<buffer "pkt.fOPCODE-list.0"> #<buffer "hub_uma_me_9_10.pl"> #<buffer "run-one-tgen"> #<buffer " *string-output*<3>"> #<buffer " *string-output*<4>"> #<buffer " *string-output*<5>"> #<buffer " *string-output*<6>"> #<buffer "all-start-stop=getNextByte.0"> #<buffer "notes.jxt"> #<buffer "*journal-topics*"> #<buffer "screenrc"> #<buffer " *string-output*<7>"> #<buffer " *string-output*<8>"> #<buffer "env"> #<buffer " *string-output*<9>"> #<buffer " *string-output*<10>"> #<buffer "bt@all-getNextByte.0"> #<buffer "bt@stop.2"> #<buffer "bsev_fetch_core.cpp"> #<buffer "h264_MBdecoder.cpp"> #<buffer "mpeg2_MBdecoder.cpp"> #<buffer "gdb.info.gz"> #<buffer "bt@stop.1"> #<buffer "bt@stop.0"> #<buffer "bsev_fetch_core.h"> #<buffer "bsev_command_decoder.h"> #<buffer "ip_interface.h"> #<buffer "crypto_interface.cpp"> #<buffer "crypto_interface.h"> #<buffer "bitstream_fetch_engine.h"> #<buffer "pathadd"> #<buffer " *string-output*<11>"> #<buffer " *string-output*<12>"> #<buffer "bashrc"> #<buffer " *string-output*<13>"> #<buffer " *string-output*<14>"> #<buffer "vde_bsev.cpp"> #<buffer "vde_bsev.h"> #<buffer "gdb-pid"> #<buffer "csl.h"> #<buffer "csl.h<2>"> #<buffer "eng_tsec.cpp"> #<buffer "dpmacs.el"> #<buffer " *string-output*<15>"> #<buffer " *string-output*<16>"> #<buffer "info.notes"> #<buffer " *string-output*<17>"> #<buffer " *string-output*<18>"> #<buffer "daily-2012-12.jxt"> #<buffer " *string-output*<19>"> #<buffer " *string-output*<20>"> #<buffer " *string-output*<21>"> #<buffer " *string-output*<22>">)

(dp-identity-rest 1 2 3 '(a b))
(cdr '(1 2 3 (a b)))
(2 3 (a b))

(apply 'dp-identity-rest 1 2 3 '(a b) nil)
(1 2 3 (a b))

(apply 'dp-identity-rest 1 2 3 'a)


(1 2 3 a)

(1 2 3 nil)



(1 2 3 a b nil)

(list 1 2 nil)
(1 2 nil)

(1 2 3 a b)



(car '(1 2 3 (a b)))
1


rest>(1 2 3 (a b))<
1

1

nil


(list 1 nil)
(1 nil)
(append '(a) '(z))
(a z)

(append 'a nil)

(a . z)

(a)

(let ((file "a")
      (corefile "z")
      tail-args)
  (when file
    (setq tail-args (list file))
    (when corefile
      (setq tail-args (append tail-args (list corefile)))))
  tail-args)
("a" "z")

nil

("a")

nil

nil

nil

("x" "c")



(defun* dp-start-gdb (&key path corefile directory name)
  "Run gdb on program FILE in buffer *gdb-FILE*.
The directory containing FILE becomes the initial working directory
and source-file directory for GDB.  If you wish to change this, use
the GDB commands `cd DIR' and `directory'."
  (when path
    (setq path (file-truename (expand-file-name path))))
  (let* ((file (and path (file-name-nondirectory path)))
         (name (or name (concat "gdb-" (or file "NONE"))))
         (buffer-name (concat "*" name "*"))
         tail-args)
    (switch-to-buffer (concat "*" name "*"))
    (if (eq major-mode 'gdb-mode)
        (message "Buffer is already in gdb-mode")
      (cond
       (directory (setq default-directory directory))
       (path (setq default-directory (file-name-directory path))))
      (or (bolp) (newline))
      (insert "Current directory is " default-directory "\n")
      (when file
        (setq tail-args (list file))
        (when corefile
          (setq tail-args (append tail-args (list corefile)))))
      (apply 'make-comint
             name
             (substitute-in-file-name gdb-command-name)
             nil
             "-fullname"
             "-cd" default-directory
             tail-args)
      (set-process-filter (get-buffer-process (current-buffer)) 'gdb-filter)
      (set-process-sentinel (get-buffer-process (current-buffer)) 'gdb-sentinel)
      ;; XEmacs change: turn on gdb mode after setting up the proc filters
      ;; for the benefit of shell-font.el
      (gdb-mode)
      (gdb-set-buffer))
    (goto-char (point-max))))

(dp-gdb0)


(defun dp-gdb (&optional new-p path corefile)
  "Extension to gdb that:
. Prefers the most recently used buffer if its process is still live,
. Else it asks for a buffer using a completion list of other gdb buffers,
. Else (or if nothing selected above) it starts a new gdb session."
  (interactive "P")
  (unless new-p
    ;; Not new, try to switch to the most recent session/buffer.
    (if (and (dp-buffer-process-live-p (dp-gdb-most-recent-buffer 
                                        :dead-or-alive-p t)
                                       :default-p nil)
             (let ((buf (car (dp-gdb-get-buffer-interactively))))
               (if (not (string= buf "-" ))
                   ;; Make sure we're true.
                   (or (dp-visit-or-switch-to-buffer buf) t)
                 nil)))
        ()
      ;; Nothing to resume, make a new one.
      (setq new-p t)
      ;; Toss a buffer with a dead gdb proc.
      (dp-bury-or-kill-process-buffer (dp-gdb-most-recent-buffer 
                                       :dead-or-alive-p t))))
  (when new-p                           ; New can be changed above.
    ;; Want to get here if new-p or no live proc buffers.
    (let ((dp-gdb-recursing t)
          (id-num (prefix-numeric-value new-p))
          name)
      ;; Let's grab the file name our-self, regardless of interactivity, so
      ;; we can put it into our own history.
      (if (< id-num 0)                  ; '- --> -1
          (setq name (format "gdb-NONE%d" id-num)
                path nil)
        (setq-ifnil path (read-file-name "Run dp-gdb on file: " nil nil nil nil
                                         'dp-gdb-file-history))
        (when (member path '("" "-" "." "/"))
          (setq path nil)))

      (dp-start-gdb :path path :corefile corefile :name name))

    (add-local-hook 'kill-buffer-hook 'dp-gdb-clear-dead-buffers)
    (dp-add-or-update-alist 'dp-gdb-buffers (buffer-name) 
                            (or corefile 'dp-gdb))
    (dp-add-to-history 'dp-gdb-buffer-history (buffer-name))
    (when (boundp 'dp-gdb-commands)
      ;; The node-name from locale-rcs will probably be used most.  But since
      ;; I have the whole list easily available, I may as well allow gdb
      ;; commands to be keyed to any of the locales.
      (loop for key in (cons "." (dp-get-locale-rcs)) do
        (loop for cmd in (cdr (assoc key dp-gdb-commands)) do
          (insert cmd)
          (comint-send-input))))))

========================
Monday January 14 2013
--
# Make gdb buffer limit its size.
# from log-message
(defun dp-restrict-buffer-growth (threshold-chars &optional threshold-percent)
  "Keep the size of a file with limits."
  (interactive "NMax size? ")
  (setq-ifnil threshold-percent 0.9)
  (when (> (point-max) (max threshold-chars (point-min)))
	;; Trim log to some percent of max size to avoid truncating on every
	;; iteration.
	(goto-char (max (- (point-max)
			   (truncate (* threshold-percent 
                                        threshold-chars)))
			(point-min)))
	(forward-line 1)
        (dmessage "del region: pmin: %s, p: %s, remainder: %s" 
                  (point-min) (point) (- (point-max) (point)))
 	(delete-region (point-min) (point))))

(dp-restrict-buffer-growth 100000)

(defun gdb (path &optional corefile)
  "Run gdb on program FILE in buffer *gdb-FILE*.
The directory containing FILE becomes the initial working directory
and source-file directory for GDB.  If you wish to change this, use
the GDB commands `cd DIR' and `directory'."
  (interactive "FRun gdb on file: ")
  (setq path (file-truename (expand-file-name path)))
  (let ((file (file-name-nondirectory path)))
    (switch-to-buffer (concat "*gdb-" file "*"))
    (setq default-directory (file-name-directory path))
    (or (bolp) (newline))
    (insert "Current directory is " default-directory "\n")
    (apply 'make-comint
	   (concat "gdb-" file)
	   (substitute-in-file-name gdb-command-name)
	   nil
	   "-fullname"
	   "-cd" default-directory
	   file
	   (and corefile (list corefile)))
    (set-process-filter (get-buffer-process (current-buffer)) 'gdb-filter)
    (set-process-sentinel (get-buffer-process (current-buffer)) 'gdb-sentinel)
    ;; XEmacs change: turn on gdb mode after setting up the proc filters
    ;; for the benefit of shell-font.el
    (gdb-mode)
    (gdb-set-buffer)))


nil


========================
Tuesday January 15 2013
--

(dp-mk-gdb-name)
("gdb-naught" . "*gdb-naught*")



set annotate 1


========================
Wednesday January 30 2013
--
(progn
  (global-set-key [(meta ?.)] 'gtags-find-tag)
  (global-set-key [(meta ?,)] 'gtags-pop-stack)
  (define-key gtags-mode-map [(control meta ?.)] 'gtags-find-tag-other-window)
  (define-key gtags-mode-map [(meta ?,)] 'gtags-pop-stack)

)


========================
Thursday January 31 2013
--
(setq gtags-prefix-key "\C-c\C-.")
""

""
(define-key gtags-mode-map (concat gtags-prefix-key "P") 'gtags-find-file)
gtags-find-file

(concat gtags-prefix-key "P")
"P"

"P"

(global-set-key [(control c) (control ?.) ?P] 'gtags-find-file)
(global-set-key [(control c) (control ?.) ?Q] 'gtags-find-file)
nil

(global-set-key "\C-c\C-.Q" 'gtags-find-file)
nil

nil

nil

gtags-find-file

(concatenate 'vector [(control c) (control ?.)] "A")
[(control c) (control ?\.) ?A]

[(control c) (control ?\.) ?P]



(setq gtags-prefix-key [(control c) (control ?.)])

;;installed (defun dp-gtags-map-key (keys def &optional map)
;;installed   (setq-ifnil map gtags-mode-map)
;;installed   (define-key map (concatenate 'vector gtags-prefix-key keys) def))

;;installed (if gtags-suggested-key-mapping
;;installed     (progn
;;installed       ;; Current key mapping.
;;installed       (dp-gtags-map-key "h" 'gtags-display-browser)
;;installed       (dp-gtags-map-key "P" 'gtags-find-file)
;;installed       (dp-gtags-map-key "f" 'gtags-parse-file)
;;installed       (dp-gtags-map-key "g" 'gtags-find-with-grep)
;;installed       (dp-gtags-map-key "I" 'gtags-find-with-idutils)
;;installed       (dp-gtags-map-key "s" 'gtags-find-symbol)
;;installed       (dp-gtags-map-key "r" 'gtags-find-rtag)
;;installed       (dp-gtags-map-key "t" 'gtags-find-tag)
;;installed       (dp-gtags-map-key "d" 'gtags-find-tag)
;;installed       (dp-gtags-map-key "v" 'gtags-visit-rootdir)
;;installed       ; common
;;installed       (define-key gtags-mode-map "\C-x4." 'gtags-find-tag-other-window)))



;;installed (defun dp-choose-buffers-by-major-mode (mode)
;;installed   (dp-choose-buffers (lambda (buf)
;;installed                        (with-current-buffer buf
;;installed                          (when (eq mode major-mode)
;;installed                            buf)))))

;;installed (dp-choose-buffers-by-major-mode 'gtags-select-mode)
;;installed (#<buffer "*GTAGS SELECT* (D)GetSurfaceByName">)

;;installed (defun dp-gtags-visit-select-buffer (other-window-p)
;;installed   (interactive "P")
;;installed   (let ((buffers (dp-choose-buffers-by-major-mode 'gtags-select-mode)))
;;installed     (if (not buffers)
;;installed         (dp-ding-and-message "No gtags select buffers.")
;;installed       (when (> (length buffers) 1)
;;installed         (dp-ding-and-message "More than one select buffer. Choosing 1st."))
;;installed       (if other-window-p
;;installed           (switch-to-buffer-other-window (car buffers))
;;installed         (switch-to-buffer (car buffers))))))

;;installed (defun dp-get-p4-location ()
;;installed   (interactive)
;;installed   (dp-get-special-abbrev "'" "\\(\\(^//.*\\)\\)"))

;;installed (defun dp-expand-p4-location ()
;;installed   (interactive)
;;installed   (let* ((abbrev-data (dp-get-p4-location))
;;installed          beg end abbrev-strings expansion)
;;installed     (when abbrev-data
;;installed       (setq beg (nth 0 abbrev-data)
;;installed             end (nth 1 abbrev-data)
;;installed             abbrev-strings (nth 2 abbrev-data)
;;installed             expansion (dp-nuke-newline 
;;installed                        (shell-command-to-string 
;;installed                         (format "dp4-reroot . %s" 
;;installed                                 (if (listp abbrev-strings)
;;installed                                     (dp-string-join abbrev-strings " ")
;;installed                                   abbrev-strings)))))
;;installed       (delete-region beg end)
;;installed       (insert expansion "/"))))

=============================================================================


:(cfl "/home/dpanariti/yokel/share/xemacs/xemacs-packages/lisp/xemacs-base/ffap.el" 30131 "    (c++-mode . ffap-c-mode)		; " nil):


(setq original-ffap-alist ffap-alist)

(setq ffap-alist original-ffap-alist)


(setq ffap-alist (cons (cons "^//[^:]+" 'dp-ffap-p4-location)
                       original-ffap-alist))

(("^//[^:]+" . dp-ffap-p4-location) ("" . ffap-completable) ("\\.info\\'" . ffap-info) ("\\`info/" . ffap-info-2) ("\\`[-a-z]+\\'" . ffap-info-3) ("\\.elc?\\'" . ffap-el) (emacs-lisp-mode . ffap-el-mode) (finder-mode . ffap-el-mode) (help-mode . ffap-el-mode) (c++-mode . ffap-c-mode) (cc-mode . ffap-c-mode) ("\\.\\([chCH]\\|cc\\|hh\\)\\'" . ffap-c-mode) (fortran-mode . ffap-fortran-mode) ("\\.[fF]\\'" . ffap-fortran-mode) (tex-mode . ffap-tex-mode) (latex-mode . ffap-latex-mode) ("\\.\\(tex\\|sty\\|doc\\|cls\\)\\'" . ffap-tex) ("\\.bib\\'" . ffap-bib) ("\\`\\." . ffap-home) ("\\`~/" . ffap-lcd) ("^[Rr][Ff][Cc][- #]?\\([0-9]+\\)" . ffap-rfc) (dired-mode . ffap-dired))




(("^//[^:]+" . dp-ffap-p4-location) ("" . ffap-completable) ("\\.info\\'" . ffap-info) ("\\`info/" . ffap-info-2) ("\\`[-a-z]+\\'" . ffap-info-3) ("\\.elc?\\'" . ffap-el) (emacs-lisp-mode . ffap-el-mode) (finder-mode . ffap-el-mode) (help-mode . ffap-el-mode) (c++-mode . ffap-c-mode) (cc-mode . ffap-c-mode) ("\\.\\([chCH]\\|cc\\|hh\\)\\'" . ffap-c-mode) (fortran-mode . ffap-fortran-mode) ("\\.[fF]\\'" . ffap-fortran-mode) (tex-mode . ffap-tex-mode) (latex-mode . ffap-latex-mode) ("\\.\\(tex\\|sty\\|doc\\|cls\\)\\'" . ffap-tex) ("\\.bib\\'" . ffap-bib) ("\\`\\." . ffap-home) ("\\`~/" . ffap-lcd) ("^[Rr][Ff][Cc][- #]?\\([0-9]+\\)" . ffap-rfc) (dired-mode . ffap-dired))

      
(let ((l '((a . b) (c . d))))
  (setq l (cons '(1 . 2) l)))
((1 . 2) (a . b) (c . d))

(append '(a v d) '())
(a v d)

dp-hide-ifdef-for-T3D


(defun dp-visit-gtags-select-buffer (&optional other-window-p)
  (interactive "P")
  (let ((buf (dp-get-buffer (car-safe (dp-choose-buffers-by-major-mode
                                       'gtags-select-mode))
                            'nil-if-nil)))
    (if buf
        (if other-window-p
            (switch-to-buffer-other-window buf)
          (switch-to-buffer buf))
      (dp-ding-and-message "No gtags select buffers."))))





========================
Thursday February 14 2013
--

(shell-command-to-string "figlet hi")
" _     _ 
| |__ (_)
| '_ \\| |
| | | | |
|_| |_|_|
         
"


0

0

0

0

(shell-command-to-string "echo hi2 > /home/dpanariti/tmp/shell-command-echo-test")


""

0

(process-status gnuserv-process)
exit

(dp-gnuserv-running-p)
nil


========================
Tuesday February 19 2013
--


(progn 
  (save-window-excursion
    (select-window (or (get-buffer-window current-gdb-buffer)
                       (selected-window)))

    (walk-windows
     (function
      (lambda (w)
        (princf "w: %s" w))))))
nil
w: #<window on "run-to-here.cpp" 0x50f>
w: #<window on "elisp-devel.el" 0x50d>
w: #<window on "*gdb-run-to-here*" 0x485>

(dp-get-buffer "run-to-here.cpp")
#<buffer "run-to-here.cpp">


(setq bubba
(progn
  ;; Searches frame for the most appropriate source window
  ;; BUFFER to display
  ;; LINE number to display
  (let* ((line 29)
         (source-buffer (dp-get-buffer "run-to-here.cpp"))
         (source-pos
          (eval-in-buffer source-buffer
                          (save-excursion (goto-line line) (point)))))
    (catch 'found
      (save-window-excursion
        (select-window (or (get-buffer-window current-gdb-buffer)
                           (selected-window)))
        (walk-windows
         (function
          (lambda (w)
            (princf "w: %s" w)
            (and (eq source-buffer (window-buffer w))
                 (pos-visible-in-window-p source-pos w)
                 (throw 'found w))))))
      (display-buffer source-buffer))))
)
w: #<window on "*scratch*" 0x643>
w: #<window on "run-to-here.cpp" 0x61d>
#<window on "run-to-here.cpp" 0x61d>

w: #<window on "*scratch*" 0x643>
w: #<window on "run-to-here.cpp" 0x61d>
#<window on "run-to-here.cpp" 0x61d>

w: #<window on "*scratch*" 0x643>
w: #<window on "run-to-here.cpp" 0x61d>
#<window on "run-to-here.cpp" 0x61d>

w: #<window on "*scratch*" 0x643>
w: #<window on "run-to-here.cpp" 0x61d>
#<window on "run-to-here.cpp" 0x61d>

w: #<window on "*scratch*" 0x643>
w: #<window on "dp-shells.el" 0x61d>
w: #<window on "elisp-devel.el" 0x645>
#<window on "run-to-here.cpp" 0x61d>

#<window 0x52f>
w: #<window on "run-to-here.cpp" 0x52f>
bubba
#<window 0x52f>
(princf "w: %s" bubba)
w: #<window 0x52f>
nil







(defun gdb-display-window (source-buffer line)
  ;; Searches frame for the most appropriate source window
  ;; BUFFER to display
  ;; LINE number to display
  (let ((source-pos
         (eval-in-buffer source-buffer
           (save-excursion (goto-line line) (point)))))
    (catch 'found
      (save-window-excursion
        (select-window (or (get-buffer-window current-gdb-buffer)
                           (selected-window)))
        (walk-windows
         (function
          (lambda (w)
            (and (eq source-buffer (window-buffer w))
                 (pos-visible-in-window-p source-pos w)
                 (throw 'found w))))))
      (display-buffer source-buffer))))


========================
Wednesday February 20 2013
--
(setq debug-ignored-errors nil)
(setq debug-on-error t)
(kill-emacs)

(setq kill-emacs-hook nil)
nil



========================
Friday February 22 2013
--

(dp-expand-p4-location "//hw/bubba")
"/home/dpanariti/lisp/devel/hw/bubba"

"bubba"



========================
Wednesday February 27 2013
--
!! make a function to dump all minor-modeline strings.
(cddadr '(flyspell-mode (buf-obj0 buf-obj1  . flyspell-mode-line-string)))
flyspell-mode-line-string

(buf-obj1 . flyspell-mode-line-string)

(buf-obj0 buf-obj1 . flyspell-mode-line-string)


(car '((buf-obj0 buf-obj1 . flyspell-mode-line-string)))
(cdr '(buf-obj0 buf-obj1 . flyspell-mode-line-string))
(buf-obj1 . flyspell-mode-line-string)

(cdr '(buf-obj0 buf-obj1 . flyspell-mode-line-string))
buf-obj0




nil

((buf-obj0 buf-obj1 . flyspell-mode-line-string))

flyspell-mode

(setq dpv-frame (selected-frame))
#<x-frame "XEmacs" on #<x-device on "o-xterm-51:23.0" 0x2> 0x2>

(set-frame-property dpv-frame 'bubba "i am teh bubba")
nil
(frame-property dpv-frame 'bubba)
"i am teh bubba"

(defun dp-set-frame-local-var (name-sym val &optional frame)
  (set-frame-property (or frame (selected-frame)) name-sym val))
dp-set-frame-local-var

dp-set-frame-local-var


(defun dp-get-frame-local-var (name-sym &optional frame)
  (frame-property (or frame (selected-frame)) name-sym))

(dp-set-frame-local-var 'bubba "new-bubba")
nil

(dp-get-frame-local-var 'bubba)
"new-bubba"







========================
Wednesday March 06 2013
--
dp-ws+newline
" 	
"


(add-hook 'comint-output-filter-functions 'dp-shell-lookfor-dir-change)
(dp-shell-lookfor-dir-change comint-strip-ctrl-m py-pdbtrack-track-stack-file ansi-color-process-output comint-postoutput-scroll-to-bottom comint-watch-for-password-prompt)

(dp-shell-lookfor-dir-change)

      (message "dir>%s<" (match-string 1 str)))))
dp-shell-lookfor-dir-change


(dp-shell-lookfor-dir-change "dpanariti@o-xterm-34:/home/scratch.dpanariti_t124/sb2/hw/hw")
"/home/scratch.dpanariti_t124/sb2/hw/hw"

"/home/scratch.dpanariti_t124/sb2/hw/hw"


nil


nil


nil

nil


nil

"/home/scratch.dpanariti_t124/sb2/hw/hw"

"/home/scratch.dpanariti_t124/sb2/hw/hw"

"/home/scratch.dpanariti_t124/sb2/hw/hw"


nil

"/home/scratch.dpanariti_t124/sb2/hw/hw"

"dir>/home/scratch.dpanariti_t124/sb2/hw/hw<"

"dir>/home/scratch.dpanariti_t124/sb2/hw/hw<"

"dir>/home/scratch.dpanariti_t124/sb2/hw/hw<"

nil

nil

nil


                                

========================
Thursday March 07 2013
--
(dp-me-expand-dest "." "sb2")
"/home/scratch.dpanariti_t124/sb2/hw"

(directory-file-name "/home/scratch.dpanariti_t124_1/sb3/sb3hw")
"/home/scratch.dpanariti_t124_1/sb3/sb3hw"

(file-name-directory "/home/scratch.dpanariti_t124/sb2/hw")
"/home/scratch.dpanariti_t124/sb2/"

(file-name-nondirectory
 (directory-file-name
  (file-name-directory (directory-file-name
                        "/home/scratch.dpanariti_t124/sb2/hw"))))
"sb2"

(file-name-nondirectory
 (directory-file-name
  (file-name-directory (directory-file-name
                        (dp-me-expand-dest "." "sb2")))))
"sb2"


/home/scratch.dpanariti_t124/sb2/hw/
(progn
  (dp-set-sandbox "/home/scratch.dpanariti_t124/sb2/hw/")
  
  (princf "name %s" dp-current-sandbox-name)
  (princf "path %s" dp-current-sandbox-regexp))
name sb2
path /home/scratch.dpanariti_t124/sb2/hw/
nil

name sb2
path /home/scratch.dpanariti_t124/sb2/hw/
nil

"sb2"

"sb2"
dp-current-sandbox-regexp
"/home/scratch.dpanariti_t124/sb2/hw"

"sb2"

(progn
  (princf "name %s" dp-current-sandbox-name)
  (princf "path %s" dp-current-sandbox-regexp))
name sb5
path /home/scratch.dpanariti_t124_2/sb5/sb5hw/
nil

name sb2
path sb2
nil

name sb2
path sb2
nil

name sb2
path /home/scratch.dpanariti_t124/sb2/hw/
nil

)

("" 
 (modeline-coding-system-extent "%C")
 (#<extent [detached) help-echo keymap from no buffer 0xc> . modeline-modified) 
 (#<extent [detached) keymap from no buffer 0x8> 
           (#<extent [detached) 
                     help-echo keymap from no buffer 0x6> 
                     10 
                     (line-number-mode "L%l") 
                     (column-number-mode "C%c")) 
           " " 
           (24 (#<extent [detached) help-echo keymap from no buffer 0x7> "%b"))) 
 " " 
 global-mode-string 
 " %[(" 
 (#<extent [detached) keymap from no buffer 0x5> "" mode-name minor-mode-alist) 
 (#<extent [detached) help-echo keymap from no buffer 0x12> . "%n") 
 modeline-process ")%]----" "%-"))


========================
Tuesday March 12 2013
--

;;more dev below ;; elephant = loader_0
;;more dev below (defun dp-grep-buffers (regexp)
;;more dev below   (interactive "sregexp? ")
;;more dev below   (let ((matching-buffer-list (delq nil (mapcar (function
;;more dev below                                (lambda (buf)
;;more dev below                                  (with-current-buffer buf
;;more dev below                                    (save-excursion
;;more dev below                                      ;; Widen, too.
;;more dev below                                      (goto-char (point-min))
;;more dev below                                      ;; Make an igrep, etc, like buffer with
;;more dev below                                      ;; all matches and line numbers.
;;more dev below                                      (when (re-search-forward regexp nil t)
;;more dev below                                        buf)))))
;;more dev below                               (buffer-list)))))
;;more dev below         (message "matching-buffer-list>%s<" matching-buffer-list)))

;;more dev below (dp-grep-buffers "loader_0")
;;more dev below (#<buffer "elisp-devel.el"> #<buffer "sanity_msenc.cpp"> #<buffer "sanity_vde.cpp"> #<buffer "vde_gpu_compositing_by_vic.cpp"> #<buffer "vic2gpu_display_composite.cpp"> #<buffer "vic2gpu_display_composite_256x128_A8B8G8R8_bl_1x16x1_gpu_input_cfg"> #<buffer " *Message-Log*">)


========================
Monday March 25 2013
--
(defun dp-gdb (&optional new-p path corefile)
  "Extension to gdb that:
. Prefers the most recently used buffer if its process is still live,
. Else it asks for a buffer using a completion list of other gdb buffers,
. Else (or if nothing selected above) it starts a new gdb session."
  (interactive "P")
  (unless new-p
    (let* (buf 
           (mrb (dp-gdb-most-recent-buffer :dead-or-alive-p t)
           (current-buf-live-p (and mrb 
                                    (dp-buffer-process-live-p 
                                     mrb :default-p nil))
           (get-buffer-interactively-p (or (Cu--p)
                                           (not current-buf-live-p))))
      (setq buf
            (cond 
             ((not get-buffer-interactively-p)
              mrb)
             ((let ((buf (car (dp-gdb-get-buffer-interactively))))
                (if (not (string= buf "-" ))
                    ;; Make sure we're true.
                    (or (dp-visit-or-switch-to-buffer buf) t)
                  nil))

            (if (and get-buffer-interactively-p
                     (let ((buf (car (dp-gdb-get-buffer-interactively))))
                       (if (not (string= buf "-" ))
                           ;; Make sure we're true.
                           (or (dp-visit-or-switch-to-buffer buf) t)
                         nil)))
                
                (if current-buf-live-p
                    mrb)
                    
                    
          (if 
      
                
      (if get-buffer-interactively-p
           
    (if (or (dp-buffer-process-live-p (dp-gdb-most-recent-buffer
                                       :dead-or-alive-p t)
                                      :default-p nil)
            )
        ()
      (setq new-p t)
      ;; Toss a buffer with a dead gdb proc.
      (dp-bury-or-kill-process-buffer (dp-gdb-most-recent-buffer
                                       :dead-or-alive-p t))))
  (when new-p                           ; New can be changed above.
    (if (eq new-p '-)
        (dp-gdb-naught)
      ;; Want to get here if new-p or no live proc buffers.
      (let ((dp-gdb-recursing t))
        ;; Let's grab the file name our-self, regardless of interactivity, so
        ;; we can put it into our own history.
        (setq-ifnil path (read-file-name "Run dp-gdb on file: " nil nil nil nil
                                         'dp-gdb-file-history))
        (gdb path corefile)
        (set-process-filter (get-buffer-process (current-buffer))
                            'dp-gdb-filter)))
    (add-local-hook 'kill-buffer-hook 'dp-gdb-clear-dead-buffers)
    (dp-add-or-update-alist 'dp-gdb-buffers (buffer-name)
                            (or corefile 'dp-gdb))
    (dp-add-to-history 'dp-gdb-buffer-history (buffer-name))
    (when (boundp 'dp-gdb-commands)
      ;; The node-name from locale-rcs will probably be used most.  But since
      ;; I have the whole list easily available, I may as well allow gdb
      ;; commands to be keyed to any of the locales.
      (loop for key in (cons "." (dp-get-locale-rcs)) do
        (loop for cmd in (cdr (assoc key dp-gdb-commands)) do
          (insert cmd)
          (comint-send-input))))))

========================
Wednesday March 27 2013
--
;; see also above

;; elephant = loader_0
(defun dp-grep-buffers (regexp &optional buffer-filename-regexp)
  (interactive "sregexp? ")
  (setq-ifnil buffer-filename-regexp ".*")
  (let ((matching-buffer-list 
         (delq nil (mapcar (function
                            (lambda (buf)
                              (with-current-buffer buf
                                (save-excursion
                                  ;; Widen, too.
                                  (goto-char (point-min))
                                  ;; Make an igrep, etc, like buffer with
                                  ;; all matches and line numbers.
                                  (when (re-search-forward regexp nil t)
                                    (list (point) buf
                                          ;; filename:num which M-e can
                                          ;; follow as well as things which
                                          ;; go to compiler error or grep
                                          ;; lines.
                                          (format "%s:%s" 
                                                  (buffer-file-name)
                                                  (line-number (point)))))))))
                           (dp-choose-buffers-file-names buffer-filename-regexp)))))
    (message "matching-buffer-list>%s<" matching-buffer-list)
    matching-buffer-list))


(dp-grep-buffers "loader_0" ".*\.cpp")
((5969 #<buffer "dep_cpu_cpu_gpu.cpp"> "/home/scratch.dpanariti_t124/sb2/hw/arch/traces/mobile/traces/gpu_multiengine/dep_cpu_cpu_gpu/dep_cpu_cpu_gpu.cpp:161") (2233 #<buffer "vic2gpu_display_composite.cpp"> "/home/scratch.dpanariti_t124/sb2/hw/arch/traces/mobile/traces/gpu_multiengine/vic2gpu_display_composite/vic2gpu_display_composite.cpp:49") (2228 #<buffer "sanity_vic.cpp"> "/home/scratch.dpanariti_t124/sb2/hw/arch/traces/mobile/traces/gpu_multiengine/sanity_vic/sanity_vic.cpp:50"))




((5969 #<buffer "dep_cpu_cpu_gpu.cpp">) (2233 #<buffer "vic2gpu_display_composite.cpp">) (2228 #<buffer "sanity_vic.cpp">))

(#<buffer "dep_cpu_cpu_gpu.cpp"> #<buffer "vic2gpu_display_composite.cpp"> #<buffer "sanity_vic.cpp">)

nil

(#<buffer "elisp-devel.el"> #<buffer "daily-2013-03.jxt"> #<buffer "dep_cpu_cpu_gpu.cpp"> #<buffer "dep_cpu_cpu_gpu_128x128_A4B4G4R4_bl_1x16x1_gpu_input_cfg"> #<buffer "dep_cpu_cpu_gpu_cfg"> #<buffer "vic2gpu_display_composite_16x16_A8B8G8R8_pitch_gpu_input_cfg"> #<buffer "vic2gpu_display_composite.cpp"> #<buffer "sanity_vic.cpp">)



(#<buffer "elisp-devel.el"> #<buffer "daily-2013-03.jxt"> #<buffer "dep_cpu_cpu_gpu.cpp"> #<buffer "dep_cpu_cpu_gpu_128x128_A4B4G4R4_bl_1x16x1_gpu_input_cfg"> #<buffer "*shell*<2>"> #<buffer "dep_cpu_cpu_gpu_cfg"> #<buffer "vic2gpu_display_composite_16x16_A8B8G8R8_pitch_gpu_input_cfg"> #<buffer "vic2gpu_display_composite.cpp"> #<buffer "sanity_vic.cpp">)



//home/scratch.dpanariti_t124/sb2/hw/arch/traces/mobile/traces/gpu_multiengine/dep_cpu_cpu_gpu/dep_cpu_cpu_gpu.cpp:161

========================
Saturday March 30 2013
--

========================
Thursday April 04 2013
--

static const char* g_MappingModeName = "";

static const NvU32 g_DefaultNumLines = 4;
static const char* k_InjectFaultsKeyword = "inject_faults";
static bool g_InjectFaults_p;
static NvU32 g_NumInjected_faults = 0;
static NvU32 g_NumMismatches = 0;
static bool g_Unexpected_mismatches = false;
static bool g_Unexpected_number_of_mismatches = false;
static NvU32 PIXEL_INCREMENT;


static const char* k_InjectFaultsKeyword = "inject_faults";

static NvU32 PIXEL_INCREMENT;

static const char* k_Inject_faultsKeyword = "inject_faults";


()
(format-kbd-macro 'one-hump)
"M-c <backspace>"

  (read-kbd-macro "M-c <backspace>"))
[(meta ?c) backspace]

;;installed (defun dp-change-one-hump ()
;;installed   (interactive)
;;installed   (when (looking-at "_")
;;installed       (forward-char 1))
;;installed   (if (dp-looking-back-at "_")
;;installed     (progn 
;;installed       (dp-toggle-capitalization 1)
;;installed       (delete-backward-char))
;;installed     (dmessage-ding "Not looking at humpworthy text.")))
;;installed (defalias 'one-hump 'dp-change-one-hump)

========================
Tuesday April 23 2013
--

(let ((arg 0)
      use-most-recent-p prompt-p new-p)
  (cond
   ((eq arg nil) (setq use-most-recent-p t) "==nil")
   ((Cu-p nil arg) (setq prompt-p t) "==C-u")
   ((equal arg 0) (setq new-p 0) "==0")
   ((Cu--p arg) (setq new-p t) "=='-")))
"==0"

"==C-u"

"=='-"

nil

"=='-"

"==t"

nil

nil

"==nil"

(Cu-p '(4))
nil

(Cu-val '0)
0
(dp-identity 'bubba)
bubba

nil

0


(dp-gdb-most-recent-buffer
                                        :dead-or-alive-p t)
nil



========================
Tuesday April 30 2013
--

+----+----+
| a  | b  |
+----+----+
| d  | c  |
+----+----+

prev: a->b->c->d->a...

a: (1, 1)
b: (2, 1)
c: (2, 2)
d: (1, 2)

(x0 < x1) && (y0 < y1)

a < b:  10 <= 20 && 10 <= 10 --> t

x * 100 + y

a: 100 + 1 == 101.
b: 200 + 1 == 201.
c: 200 + 2 == 202.
d: 100 + 2 == 102,

a, d, b, c


;;installed (defun* dp-mk-mode-r/o-transparent-regexp (extension &optional
;;installed                                           extra-suffix-regexp
;;installed                                           (dot "."))
;;installed   (dp-mk-mode-transparent-regexp extension
;;installed                                  dp-default-mode-transparent-r/o-suffix-regexp
;;installed                                  extra-suffix-regexp
;;installed                                  dot))

;;installed (defun* dp-mk-mode-r/w-transparent-regexp (extension &optional
;;installed                                           extra-suffix-regexp
;;installed                                           (dot "."))
;;installed   (dp-mk-mode-transparent-regexp extension
;;installed                                  dp-default-mode-transparent-r/w-suffix-regexp
;;installed                                  extra-suffix-regexp
;;installed                                  dot))
  

(dp-mk-mode-r/o-transparent-regexp nil)
"historical\\|save\\|hide\\|no-index\\|pristine\\|HISTORICAL\\|SAVE\\|HIDE\\|NO-INDEX\\|PRISTINE\\|KEEP\\|keep\\|REFERENCE\\|reference\\|novc\\|junk\\|NOVC\\|JUNK\\|stale\\|bad\\|b0rked\\|broken?\\|hosed\\|fubar\\|STALE\\|BAD\\|B0RKED\\|BROKEN?\\|HOSED\\|FUBAR\\|merged?\\|obs\\|olde?\\|orig\\|MERGED?\\|OBS\\|OLDE?\\|ORIG"

"historical\\|save\\|hide\\|no-index\\|pristine\\|HISTORICAL\\|SAVE\\|HIDE\\|NO-INDEX\\|PRISTINE\\|KEEP\\|keep\\|REFERENCE\\|reference\\|novc\\|junk\\|NOVC\\|JUNK\\|stale\\|bad\\|b0rked\\|broken?\\|hosed\\|fubar\\|STALE\\|BAD\\|B0RKED\\|BROKEN?\\|HOSED\\|FUBAR\\|merged?\\|obs\\|olde?\\|orig\\|MERGED?\\|OBS\\|OLDE?\\|ORIG"


(dp-mk-mode-r/w-transparent-regexp nil)
"wip\\|exp\\|dev\\|WIP\\|EXP\\|DEV"

"wip\\|exp\\|dev\\|WIP\\|EXP\\|DEV"



========================
Tuesday May 07 2013
--
;;installed (defun xxx ()
  (interactive)
  (if (dp-region-active-p)
      (dp-io-xxx)
    ;; The doxygen element syntax is different when it comes after a line vs
    ;; before it.
    ;; e.g.
    ;; /*!
    ;;  *!@todo blah
    ;;  */
    ;; vs:
    ;; bad_thing(tm);   //!<@todo.
    ;; So fix it.
    (let ((doxy-prefix (if (or (not (dp-in-c))
                               (dp-in-a-c*-comment))
                           ""
                         "!<")))
      (dp-insert-for-comment+ "XXX " "@todo " :sep-char ""
                              :doxy-prefix doxy-prefix))))

;; !<@todo XXX 
;; @todo XXX 
;; @todo XXX 
;; @todo XXX 

========================
Thursday June 06 2013
--

   (^|/|\s-+),.+       --> current sb, after trying regular expansion
   (^|/|\s-+),.+,      --> current sb
   (^|/|\s-+),.+,,     --> current sb
   (^|/|\s-+),.+,.+    --> sb between final 2 ,s. ,dir,sbox,
   (^|/|\s-+),.+,.+,   --> sb between final 2 ,s. ,dir,sbox,

"\\(^\\|/\\|\\s-+\\),\\([^,]+\\)\\(,\\{0,2\\}\\)$"
"\\(^\\|/\\|\\s-+\\),\\([^,]+\\),\\([^,]+\\)\\(,\\{0,1\\}\\)$"

(setq dp-tre0
      (concat
       "\\("                            ; 1
       "\\(^\\|/\\|\\s-+\\)"
       ","
       "\\([^,]+\\)"                    ; 2
       ","
       "\\([^,]+\\)"                    ; 3
       "\\(?:,\\{0,1\\}\\)"             ; 4
       "\\)$")
      dp-tre1
      (concat
       "\\("                            ; 1
       "\\(^\\|/\\|\\s-+\\)"            ; 2
       ","
       "\\([^,]+\\)"                    ; 3
       "\\(?:,\\{0,2\\}\\)"             ; 4
       "\\)$"
       ))
"\\(\\(^\\|/\\|\\s-+\\),\\([^,]+\\)\\(,\\{0,2\\}\\)\\)$"




,abb

,abb,

,abb,,

,abb,sb

,abb,sb,

(135872 135878 ",abb,")


(dp-looking-back-at REGEXP &optional LIMIT))


(defun dp-tfun ()
  (interactive)
  (let (who-matched)
    (if (dp-looking-back-at dp-tre0)
        (setq who-matched "dp-tre0")
      (if (dp-looking-back-at dp-tre1)
          (setq who-matched "dp-tre1")))
    (if who-matched
        (progn
          (dmessage "m3>%s<" (match-string 3))
          (dmessage "m4>%s<" (match-string 4))
          (format "%s matched. matches>%s<" who-matched
                  (dp-all-match-strings-string :string-join-args '("|" nil nil t))))
      "No match")))
dp-tfun

,abb,   --> "dp-tre1 matched. matches>,abb,|,abb,||abb|,<"
,abb,sb --> "dp-tre0 matched. matches>,abb,sb|,abb,sb||abb|sb|<"

3 --> abbrev name
4 (if) --> sb name

(defun dp-get-sandbox-rel-abbrev ()
  (interactive)
  (when (or
         (dp-looking-back-at dp-sandbox-rel-regexp0)
         (dp-looking-back-at dp-sandbox-rel-regexp1))
    (list (match-beginning 0)
          (match-end 0)
          (concat (match-string 3)
                  " "
                  (or (match-string 4) "")))))



========================
Monday June 10 2013
--

(cl-pe '(dp-declare-frame-local-var fl-bubba))

(progn
  (put 'fl-bubba 'dp-frame-local-variable-p t)
  (defconst fl-bubba "DECLARED frame local variable" "dp-frame-local-var"))
fl-bubba




(progn
  (put 'fl-bubba 'dp-frame-local-variable t)
  (defconst fl-bubba "DECLARED frame local variable" "dp-frame-local-var"))
fl-bubba


"DECLARED frame local variable"





(symbol-plist 'flv-bubba)
(variable-documentation "dp-frame-local-var" dp-frame-local-variable-p default)

(dp-frame-local-variable-p t variable-documentation "dp-frame-local-var" dp-frame-local-variable t)

(variable-documentation "dp-frame-local-var" dp-frame-local-variable t)

(variable-documentation "dp-frame-local-var" dp-frame-local-variable t)


fl-bubba
"DECLARED frame local variable"

"i am a bubba"


fl-bubba
"i am a bubba"


(cl-pe '(dp-get-frame-local bubba))

(dp-get-frame-local bubba)nil






## Make a dp-frame-local-variables obarray.
(set-frame-property (selected-frame) 'dp-bubba "I am BUBBA!")

(dp-setq-frame-local-var 'fl-bubba "val")
"val"

(cl-pe '(dp-get-frame-local-var fl-bubba))

(progn
  (dp-assert-frame-local-variable 'fl-bubba)
  (frame-property (or nil (selected-frame)) 'fl-bubba nil))nil


(progn
  (dp-assert-frame-local-variable 'fl-bubba)
  (frame-property (or nil (selected-frame)) 'fl-bubba nil))
"val"




(progn
  (dp-assert-frame-local-variable var-sym)
  (frame-property (or nil (selected-frame)) 'fl-bubba nil))nil


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

dp-sandbox-regexp-private
"DECLARED frame local variable"

(dp-set-sandbox-regexp "/home/scratchX.")
"/home/scratchX."

"/home/scratch."







(dp-get-frame-local dp-sandbox-regexp-private)
"/home/scratchX."

"/home/scratch."

(dp-sandbox-regexp)
"/home/scratchX."


(dp-sandbox-p "/home/scratchX.bubba")
0

nil




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;









(dp-setq-frame-local-var 'fl-bubba "val2")
"val2"

(dp-get-frame-local fl-bubbaa)

"val2"


(cl-pe '(dp-get-frame-local bib))

(dp-get-frame-local fl-bubba)
"val2"

"val2"

(dp-get-frame-local-var 'fl-bubba nil nil)
"val2"









(dp-get-frame-local bib)nil





kdjhfkdjhfkj



(dp-assert-frame-local-variable 'bubba)


dp-setq-frame-local-var

(defsubst dp-assert-frame-local-variable (var-sym)
  (unless (get var-sym 'dp-frame-local-variable-p)
    (error 'invalid-state (format "`%s' is not frame local" var-sym)))
  (get var-sym 'dp-frame-local-variable-p))

(defun dp-set-frame-local-var (var-sym val &optional frame)
  (setq-ifnil frame (selected-frame))
  (message "frame: %s, var-sym: %s, val: %s" frame var-sym val)
  ;; Enforce declaration requirement.
  (dp-assert-frame-local-variable var-sym)
  (set-frame-property frame var-sym val)
  (put var-sym 'dp-frame-local-variable-p t)
  val)

(defun dp-get-frame-local-var (var-sym &optional frame default)
    (if (eq (dp-assert-frame-local-variable var-sym) 'default)
        (symbol-value var-sym)
      (frame-property (or frame
                          (selected-frame))
                      var-sym
                      ;; User can provide DEFAULT in order to differentiate nil
                      ;; from the case where the property doesn't exist.
                      default)))

(defmacro dp-get-frame-local (var-sym &optional frame default)
  `(dp-get-frame-local-var (quote ,var-sym) ,frame ,default))

(defmacro dp-setq-frame-local (&rest arglist)
  (if (not (= 0 (mod (length arglist) 2)))
      (error "dp-setq-frame-local: arglist len must be a multiple of 2."))
  (let (arg init-val result)
    (while arglist
      (setq arg (car arglist)
            arglist (cdr arglist)
            init-val (car arglist)
            arglist (cdr arglist))
      (setq new-elem `(dp-set-frame-local-var (quote ,arg) ,init-val))
      (setq result (cons new-elem result)))
    (cons 'progn (reverse result))))

(defmacro dp-def-frame-local-var (var-name val &optional docstring)
  (let ((sep (if docstring
                 ": "
               ""))
        (docstring (or docstring "")))
    (setq docstring (concat "dp-frame-local-var" sep docstring))
    `(progn
      ;; Use this as default value until explicitly set.
      (put (quote ,var-name) 'dp-frame-local-variable-p 'default)
      (defconst ,var-name ,val ,docstring))))

;; (defmacro dp-declare-frame-local-var (var-name &optional docstring)
;;   (dp-def-frame-local-var var-name
;;                           "DECLARED frame local variable" docstring))

(dp-def-frame-local-var dp-sandbox-regexp-private nil
  "Regexp to detect a sandbox.")

;; Use, e.g., in a spec-macs.
(defsubst dp-set-sandbox-regexp (regexp)
  (dp-setq-frame-local dp-sandbox-regexp-private regexp))

(defsubst dp-sandbox-regexp ()
  (dp-get-frame-local dp-sandbox-regexp-private))

;; Set in a spec-macs.
(defvar dp-sandbox-make-command nil
  "A special makefile for using in sandbox. E.g. mmake @ nvidia.")

(defsubst dp-sandbox-p (filename)
  (and filename
       (dp-sandbox-regexp)
       (string-match (dp-sandbox-regexp) filename)))

(dp-def-frame-local-var dp-current-sandbox-regexp-private nil
  "Regexp to detect the current sandbox.")

(defsubst dp-current-sandbox-regexp ()
  (dp-get-frame-local dp-current-sandbox-regexp-private))

;; XXX @todo I want to allow an abbrev for the name.
;; It will be expanded and regexp quoted into `dp-current-sandbox-regexp'.
(dp-def-frame-local-var dp-current-sandbox-name-private nil
  "Name of the current sandbox.")

(defsubst dp-current-sandbox-name ()
  (dp-get-frame-local dp-current-sandbox-name-private))

(dp-def-frame-local-var dp-current-sandbox-read-only-private-p nil
  "See `dp-set-sandbox' for the meaning of this variable.")

(defsubst dp-current-sandbox-read-only-p ()
  (dp-get-frame-local dp-current-sandbox-read-only-private-p))

;; Begin moving to a sandbox per frame.
(defsubst dp-set-current-sandbox-read-only-p (read-only-p)
  (dp-setq-frame-local dp-current-sandbox-read-only-private-p read-only-p))

(defun dp-set-sandbox-name-and-regexp (name regexp &optional default-p)
  (dp-remove-editor-identification-data 'sandbox-name)
  (if default-p
      (progn
        (dp-setq-frame-local dp-current-sandbox-name-private name)
        (dp-setq-frame-local dp-current-sandbox-regexp-private regexp))
    (dp-setq-frame-local dp-current-sandbox-name-private name)
    (dp-setq-frame-local dp-current-sandbox-regexp-private regexp))
  (dp-add-editor-identification-data 'sandbox-name 
                                     (dp-current-sandbox-name)))


(defun dp-sandbox-file-before-change-function (ben end)
  (if (buffer-file-name)
      (let ((read-only-p (dp-sandbox-read-only-p (buffer-file-name))))
        (dmessage "ro-p: %s" read-only-p)
        ;; None of this prevents the initial change from happening.
        (toggle-read-only read-only-p)  ; We may be going from RO -> RW or RW -> RO.
        (when read-only-p
          (error "File is R/O in this frame.")))
    (dmessage "ro-p: buffer has no file.")))


========================
Tuesday June 11 2013
--

;; //a/b/c[,sb][,]
;; //a/b/c[ sb][,]
(defvar dp-sandbox-rel-regexp2
  (concat
   "\\("                                ; 1
   "\\(^\\|\\s-+\\)"                    ; 2
   "\\(//[^, ]+\\)"                     ; 3 -- Abbrev
   "[, ]"
   "\\([^, ]+?\\)"                      ; 4 -- Sandbox
   "\\(?:$\\|,\\{0,1\\}\\)"
   "\\)$")
  "Finds syntax: //path?")

(defvar dp-sandbox-rel-regexp3
  (concat
   "\\("                                ; 1
   "\\(^\\|\\s-+\\)"                    ; 2
   "\\(//[^, ]+?\\)"                    ; 3 -- Abbrev
   "\\(?:$\\|[, ]\\{0,2\\}\\)"          ; 4
   "\\)$"
   )
  "Finds syntax: //path[, ]sb")

(progn
  (re-search-forward dp-sandbox-rel-regexp3)
  (message "3>%s<" (match-string 3))
  (message "4>%s<" (match-string 4)))






//a/b/c



(progn"4>nil<"
"4>nil<"

  (re-search-forward dp-sandbox-rel-regexp2)
  (message "3>%s<" (match-string 3))
  (message "4>%s<" (match-string 4)))






//a/b/c bkah"4>bkah<"

"
"
========================
Wednesday June 12 2013
--

\\(//\\|,\\)\\([^,]+\\)\\(,[^,]+\\)?,?$
(progn
  (save-excursion
    (if (re-search-forward "\\(//\\|,\\)\\([^, \n\t]+\\)\\(,[^, \n\t]+\\)?,?" nil t)
        (progn
          (goto-char (point-max))
          (princf "match0>%s<" (match-string 1)))
      (goto-char (point-max))
      (princf "NO matches."))))

(defun dp-ldd-f ()
  (interactive)
  (save-excursion
    (if (dp-looking-back-at "\\(?:/\\| \\|^\\)\\(\\(//\\|[ ,]\\)\\([^, 
	]+\\)\\([, ][^, 
	]*\\)?[ ,]?\\)")
        (progn
          (goto-char (point-max))
          (princf "match1>%s<" (match-string 1))
          (princf "mex>%s<" ())
      (goto-char (point-max))
      (princf "NO matches."))))

"\(?:^\| \|/\)\(\(//\|[ ,]\)\([^, 
	]+\)\([, ][^, 
	]*\)?[ ,]?\)"

"\\(?:^\\| \\|/\\)\\(\\(//\\|[ ,]\\)\\([^, 	
]+\\)\\([, ][^, 	
]*\\)?[ ,]?\\)"

(dp-me-expand-dest ",tg")
"../../../../../../../../hw/ap_tlit1/diag/testgen"



 ,tg                    ! mex doesn't recognize this.
 ,tg,
 ,tg,sb1
 ,tg,sb1,
 ,tg,,

/,tg
/,tg,
/,tg,sb1
/,tg,sb1,
/,tg,,

,tg
,tg,
,tg,sb1
,tg,sb1,
,tg,,
  

+ tg                    ! regexp doesn't match
+ tg sb1                ! ""

 //hw/tools
 //hw/tools sb1
 //hw/tools,
 //hw/tools,sb1

///hw/tools
///hw/tools sb1
///hw/tools,
///hw/tools,sb1

//hw/tools
//hw/tools sb1
//hw/tools,
//hw/tools,sb1



========================
Friday June 21 2013
--
(string-match "/home/scratch\.dpanariti.*/sb.hw\\(/\\|$\\)" "/home/scratch.dpanariti_t124_2/sb1/sb1hw/")
(string-match "/home/scratch\.dpanariti.*/sb.hw\\/.*hw/ap\\(_tlit[0-9]\\)?" 
              "/home/scratch.dpanariti_t124_2/sb1/sb1hw/hw/ap_tlit1")

(string-match
 "/home/scratch\.dpanariti.*/sb.hw\\(/\\|$\\)"
 "/home/scratch.dpanariti_t124_2/sb1/sb1hw/hw/ap_tlit1/drv/drvapi/runtest_common/runtest_cpu.cpp"
)
0

0

nil


0

0


nil

nil



/home/scratch.dpanariti_t124_2/sb1/sb1hw/hw/ap_tlit1
/home/scratch.dpanariti_t124_2/sb1/sb1hw

cscope-database-regexps
nil

(setq cscope-database-regexps
      '(
        ("/home/scratch\.dpanariti.*/sb.hw\\/.*hw/ap\\(_tlit[0-9]\\)?"
;;         (t)
         ("/home/scratch\.dpanariti.*/sb.hw\\(/\\|$\\)")
         )
         )
        )
(("/home/scratch.dpanariti.*/sb.hw\\(/\\|$\\)" (t) ("/home/scratch.dpanariti.*/sb.hw\\/.*hw/ap\\(_tlit[0-9]\\)?")))

((t ("/home/scratch.dpanariti.*/sb.hw\\(/\\|$\\)") ("/home/scratch.dpanariti.*/sb.hw\\/.*hw/ap\\(_tlit[0-9]\\)?")))

        
;; works for surface_wr? which is odd, because it's not in ap
(setq cscope-database-regexps
      '(
        ( "/home/scratch.dpanariti_t124_2/sb1/sb1hw/hw/ap_tlit1"
         ( "/home/scratch.dpanariti_t124_2/sb1/sb1hw")
         )
         )
        )

;; works for ap files, not other.
(setq cscope-database-regexps
      '(
        ( "/home/scratch.dpanariti_t124_2/sb1/sb1hw"
          ( "/home/scratch.dpanariti_t124_2/sb1/sb1hw/hw/ap_tlit1")
         )
         )
        )

;; works for neither.
(setq cscope-database-regexps
      '(
        ( "/home/scratch.dpanariti_t124_2/sb1/sb1hw")
        ( "/home/scratch.dpanariti_t124_2/sb1/sb1hw/hw/ap_tlit1")
        )
      )

;; YOPP!
;; Create/modify when sandbox changes.
(setq cscope-database-regexps
      '(
        ( "/home/scratch.dpanariti_t124_2/sb1/sb1hw/.*"
          (t)
          ("/home/scratch.dpanariti_t124_2/sb1/sb1hw/hw/ap_tlit1/")
          ( "/home/scratch.dpanariti_t124_2/sb1/sb1hw/")
          )
        )
      )


;;installed (defun dp-nv-make-cscope-database-regexps ()
;;installed   (let ((ap (dp-me-expand-dest "ap" (dp-current-sandbox-name)))
;;installed         (sb (dp-current-sandbox-regexp)))
;;installed     `(
;;installed       (,sb
;;installed        (t)
;;installed        (,ap)
;;installed        (,sb)))))

(cl-pp (dp-nvidia-make-cscope-database-regexps))


(("/home/scratch.dpanariti_t124_2/sb1/sb1hw/" (t)
  ("/home/scratch.dpanariti_t124_2/sb1/sb1hw/hw/ap_tlit1")
  ("/home/scratch.dpanariti_t124_2/sb1/sb1hw/")))nil





(("/home/scratch.dpanariti_t124_2/sb1/sb1hw/" (t)
  ("/home/scratch.dpanariti_t124_2/sb1/sb1hw/hw/ap_tlit1")
  ("/home/scratch.dpanariti_t124_2/sb1/sb1hw/")))nil


(dp-current-sandbox-regexp)
"/home/scratch.dpanariti_t124_2/sb1/sb1hw/"

nil

"/home/scratch.dpanariti_t124_2/sb1/sb1hw/"

nil

"/home/scratch.dpanariti_t124_2/sb1/sb1hw/"
(dp-current-sandbox-name)
nil

"sb1"

(setq cscope-database-regexps (dp-nv-make-cscope-database-regexps))
(("/home/scratch.dpanariti_t124_2/sb1/sb1hw/" (t) ("/home/scratch.dpanariti_t124_2/sb1/sb1hw/hw/ap_tlit1") ("/home/scratch.dpanariti_t124_2/sb1/sb1hw/")))

(("/home/scratch.dpanariti_t124_2/sb1/sb1hw/" (t)
  ("/home/scratch.dpanariti_t124_2/sb1/sb1hw/hw/ap_tlit1")
  ("/home/scratch.dpanariti_t124_2/sb1/sb1hw/")))


(cl-pp cscope-database-regexps)

(("/home/scratch.dpanariti_t124_2/sb1/sb1hw/.*" (t)
  ("/home/scratch.dpanariti_t124_2/sb1/sb1hw/../ap_tlit1/")
  ("/home/scratch.dpanariti_t124_2/sb1/sb1hw/")))nil


(setq dpl1 '(("x") ("y")))
(("x") ("y"))

`( (a b)
   ,dpl1
)
((a b) (("x") ("y")))




========================
Monday June 24 2013
--

;;works,save (defstruct dp-data-file-ret
;;works,save   file
;;works,save   rest-of-list)

;;works,save (defstruct dp-data-file-descriptor
;;works,save   dir
;;works,save   app-args
;;works,save   matching-file                         ; Part of return value.
;;works,save   )

;;works,save (defstruct dp-data-file-path-element
;;works,save   cwd-match-regexp                    ; This selects which descriptor to use.
;;works,save   data-files                ; data file descriptors to search for data files.
;;works,save   )

;;works,save (defstruct dp-data-file-path-descriptor
;;works,save   data-file-name                        ; Data file name.
;;works,save   path-elements                         ; List of path elements.
;;works,save   )


;;works,save (setq dp-test-data-file-path
;;works,save       (list (make-dp-data-file-path-descriptor
;;works,save              :data-file-name "dpmacs.el"
;;works,save              :path-elements (list (make-dp-data-file-path-element
;;works,save                                    :cwd-match-regexp "/home/dpanariti/lisp/devel/"
;;works,save                                    :data-files (list (make-dp-data-file-descriptor
;;works,save                                                       :dir "/home/dpanariti/lisp"
;;works,save                                                       :app-args nil
;;works,save                                                       :matching-file 'unset)))))
;;works,save             (make-dp-data-file-path-descriptor
;;works,save              :data-file-name "dpmisc.el"
;;works,save              :path-elements (list (make-dp-data-file-path-element
;;works,save                                    :cwd-match-regexp "/home/dpanariti/"
;;works,save                                    :data-files (list (make-dp-data-file-descriptor
;;works,save                                                       :dir "/home/dpanariti/lisp"
;;works,save                                                       :app-args nil
;;works,save                                                       :matching-file 'unset)))))
;;works,save             ))

;;works,save (defun* dp-find-directory-relative-data-file (path-descriptors &optional start-dir dump-nodes-p)
;;works,save   "Stolen from the idea of `cscope-database-regexps' in xcscope.el."
;;works,save   (setq-ifnil start-dir default-directory)
;;works,save   (let (data-file-name
;;works,save         potential-data-file
;;works,save         path-elements
;;works,save         descriptors)
;;works,save     (while path-descriptors
;;works,save       (setq path-descriptor (car path-descriptors)
;;works,save             path-descriptors (cdr path-descriptors))
;;works,save       (setq data-file-name (dp-data-file-path-descriptor-data-file-name
;;works,save                             path-descriptor))
;;works,save       (setq path-elements (dp-data-file-path-descriptor-path-elements path-descriptor))
;;works,save       (while path-elements
;;works,save         (setq path-element (car path-elements)
;;works,save               path-elements (cdr path-elements))
;;works,save         (when dump-nodes-p
;;works,save           (message "path-element: %s" path-element))
;;works,save         (when (string-match (dp-data-file-path-element-cwd-match-regexp
;;works,save                              path-element)
;;works,save                             start-dir)
;;works,save           (setq descriptors (dp-data-file-path-element-data-files path-element))
;;works,save           (while descriptors
;;works,save             (setq descriptor (car descriptors)
;;works,save                   descriptors (cdr descriptors))
;;works,save             (when dump-nodes-p
;;works,save               (message "descriptor: %s" descriptor)
;;works,save               (setq potential-data-file (expand-file-name
;;works,save                                          (dp-data-file-path-descriptor-data-file-name
;;works,save                                           path-descriptor)
;;works,save                                          (dp-data-file-descriptor-dir descriptor)))
;;works,save               (when (file-exists-p potential-data-file)
;;works,save                 (return-from
;;works,save                     dp-find-directory-relative-data-file
;;works,save                   (list potential-data-file path-descriptors))))))))))

(defstruct dp-data-file-ret
  file
  rest-of-list)

(defstruct dp-data-file-descriptor
  dir
  app-args
  )

(defstruct dp-data-file-path-element
  cwd-match-regexp                    ; This selects which descriptor to use.
  data-files                ; data file descriptors to search for data files.
  )

(defstruct dp-data-file-path-descriptor
  data-file-name                        ; Data file name.
  path-elements                         ; List of path elements.
  )


(setq dp-test-data-file-path
      (list (make-dp-data-file-path-descriptor
             :data-file-name "dpmacs.el"
             :path-elements (list (make-dp-data-file-path-element
                                   :cwd-match-regexp "/home/dpanariti/lisp/devel/"
                                   :data-files (list (make-dp-data-file-descriptor
                                                      :dir "/home/dpanariti/lisp"
                                                      :app-args nil)))))
            (make-dp-data-file-path-descriptor
             :data-file-name "dpmisc.el"
             :path-elements (list (make-dp-data-file-path-element
                                   :cwd-match-regexp "/home/dpanariti/"
                                   :data-files (list (make-dp-data-file-descriptor
                                                      :dir "/home/dpanariti/lisp"
                                                      :app-args nil)))))
            ))


(defun* dp-find-directory-relative-data-file (path-descriptors &optional start-dir dump-nodes-p)
  "Stolen from the idea of `cscope-database-regexps' in xcscope.el."
  (setq-ifnil start-dir default-directory)
  (let (data-file-name
        potential-data-file
        path-elements
        descriptors)
    (while path-descriptors
      (setq path-descriptor (car path-descriptors)
            path-descriptors (cdr path-descriptors))
      (setq data-file-name (dp-data-file-path-descriptor-data-file-name
                            path-descriptor))
      (setq path-elements (dp-data-file-path-descriptor-path-elements path-descriptor))
      (while path-elements
        (setq path-element (car path-elements)
              path-elements (cdr path-elements))
        (when dump-nodes-p
          (message "path-element: %s" path-element))
        (when (string-match (dp-data-file-path-element-cwd-match-regexp
                             path-element)
                            start-dir)
          (setq descriptors (dp-data-file-path-element-data-files path-element))
          (while descriptors
            (setq descriptor (car descriptors)
                  descriptors (cdr descriptors))
            (when dump-nodes-p
              (message "descriptor: %s" descriptor)
              (setq potential-data-file (expand-file-name
                                         (dp-data-file-path-descriptor-data-file-name
                                          path-descriptor)
                                         (dp-data-file-descriptor-dir descriptor)))
              (when (file-exists-p potential-data-file)
                (return-from
                    dp-find-directory-relative-data-file
                  (make-dp-data-file-ret
                   :file potential-data-file 
                   :rest-of-list path-descriptors))))))))))

(dp-find-directory-relative-data-file dp-test-data-file-path nil t)
[cl-struct-dp-data-file-ret "/home/dpanariti/lisp/dpmacs.el" 
                            ([cl-struct-dp-data-file-path-descriptor "dpmisc.el" 
                                                                     ([cl-struct-dp-data-file-path-element "/HOME/DPANARITI/" 
                                                                                                           ([cl-struct-dp-data-file-descriptor "/home/dpanariti/lisp" nil unset])])])]


("/home/dpanariti/lisp/dpmacs.el" ([cl-struct-dp-data-file-path-descriptor "dpmisc.el" ([cl-struct-dp-data-file-path-element "/home/dpanariti/" ([cl-struct-dp-data-file-descriptor "/home/dpanariti/lisp" nil unset])])]))


("/home/dpanariti/lisp/dpmisc.el" nil)

("/home/dpanariti/lisp/dpmisc.el" nil)





========================
Thursday July 11 2013
--

(apply 'format "hello" nil)
"hello"


;;installed (defun dp-format-with-date (fmt &rest args)
;;installed   "Like `format' except %%S will be replace with the current date in yyyy-mm-dd format."
;;installed   (interactive)
;;installed   (with-case-folded nil
;;installed     (when (string-match "%%S" fmt)
;;installed       (setq fmt (replace-match (time-stamp-yyyy-mm-dd) nil t fmt))))
;;installed   (apply 'format fmt args))

(dp-format-with-date "%%S.txt")
"2013-07-11.txt"
(dp-format-with-date "YADDA-%%S.txt")
"YADDA-2013-07-11.txt"

"YADDA-2013-07-11.txt"
"YADDA-2013-07-11.txt"
(dp-format-with-date "%%s.txt")
"%s.txt"

"%%s.txt"

"2013-07-11.txt"
(dp-format-with-date "%S.txt")

"%S.txt"






"%%S.txt"

"%S.txt"

(progn
  (setenv "DP_WORK_STATUS_DIR" "/home/dpanariti/work/status")
  (setenv "DP_WORK_STATUS_TEMPLATE_FILE_NAME" "template")
  (setenv "DP_WORK_STATUS_FILE_NAME_FORMAT" "status-%s.txt")
)

(car '(- nil -))
-

nil

;;installed (defun dp-dated-status-report (&optional date-str status-dir-name template-file-name 
;;installed                                status-file-name-format)
;;installed   (interactive "P")
;;installed   ;; `expand-file-name' only uses the second parameter if the first is not absolute.
;;installed   (setq-ifnil status-dir-name (or (getenv "DP_WORK_STATUS_DIR")
;;installed                                   (expand-file-name "~/work/status"))
;;installed               template-file-name (expand-file-name (or (getenv "DP_WORK_STATUS_TEMPLATE_FILE_NAME")
;;installed                                                        "template.txt")
;;installed                                                    status-dir-name)
;;installed               status-file-name-format (expand-file-name (or (getenv "DP_WORK_STATUS_FILE_NAME_FORMAT")
;;installed                                                             "%s-status.txt")
;;installed                                                         status-dir-name))
;;installed   (setq date-str
;;installed         (cond
;;installed          ((eq '- date-str)
;;installed           (read-from-minibuffer "Date: " (time-stamp-yyyy-mm-dd)))
;;installed          ((eq nil date-str)
;;installed           (time-stamp-yyyy-mm-dd))
;;installed          (t date-str)))
;;installed   (find-file (format status-file-name-format date-str))
;;installed   (when (dp-buffer-empty-p)
;;installed     (insert-file template-file-name)
;;installed     (while (re-search-forward "@DATE@" nil t)
;;installed       (replace-match date-str))
;;installed     (goto-char (point-min))
;;installed     (re-search-forward "0)")
;;installed     (end-of-line)
;;installed     (newline-and-indent)
;;installed     (indent-relative)))
dp-dated-status-report



(dp-dated-status-report '-)
#<marker in no buffer 0x99bc2>










========================
Wednesday July 17 2013
--
"^\\(\\s-*\\)\\(\\S-+\\)\\(\\s-+\\)\\(\\S-+\\)\\(\\s-*$\\)"
(defvar dp-p4-client-spec-font-lock-keywords
  (list
   ;;        1          2          3          4          5
   (cons "^\\(\\s-*\\)\\(\\S-+\\)\\(\\s-+\\)\\(\\S-+\\)\\(\\s-*$\\)"
         (list
          (list 2 'dp-remote-buffer-face nil)
          (list 4 'dp-journal-selected-face nil)))))
(cl-pp dp-p4-client-spec-font-lock-keywords)

(("^\\(\\s-*\\)\\(\\S-+\\)\\(\\s-+\\)\\(\\S-+\\)\\(\\s-*$\\)" (2 dp-remote-buffer-face
                                                                 nil)
  (4 dp-journal-selected-face nil)))nil



(expand-file-name "/a/b" "/q/r/s")
"/a/b"

"/q/r/s/a/b"

"/home/dpanariti/lisp/devel/q/r/s/a/b"

"/a/b"





========================
Wednesday July 24 2013
--

(dp-shell-command-to-list "go2env.py -E" "
")

nil
(getenv "new-test-val1")
"for-xemacs-test"

nil

"for-xemacs-test"


0


(eval '("(setenv \"bubba-test\" \"nyuck/\")"
        "(setenv \"bubba-bubba\" \"I, bubblius\")"))

(eval-region "(setenv \"bubba-test\" \"nyuck/\")")
"(setenv \"bubba-test\" \"nyuck/\")"

;;installed (defun dp-go-setenv ()
;;installed   "Set all of the `go' environment variables.
;;installed This is needed because the new sandbox relative utilities count on environment variables.
;;installed @todo XXX Fix this in the scripts. But for now, doing it here is ttttrivial."
;;installed   (interactive)
;;installed   (with-temp-buffer
;;installed     (call-process "go2env.py" nil t nil "-E")
;;installed     (eval-buffer)))
a
(dp-listify-things '(a b c) nil 'a)
((a b c) (a))

(hide-ifdef-define
(defun dp-hide-ifdef-define (var)
  (interactive (list (dp-prompt-with-symbol-near-point-as-default 
                      "#define name:" 
                      :symbol-type 'S
                      :require-match-p nil)))
  (hide-ifdef-define var))
dp-hide-ifdef-define




========================
Friday September 20 2013
--
(defun* dp-colorize-regexp-matches (regexp &optional color end-regexp
                                    (shrink-wrap-p 
                                     dp-colorize-lines-shrink-wrap-p-default)
                                    roll-colors-p non-matching-p)
  (interactive "sregexp: ")
  (when (or (not regexp)
         (string= regexp ""))
    (setq regexp isearch-string))
  (dp-colorize-matching-lines regexp 
                              color 
                              end-regexp 
                              shrink-wrap-p 
                              roll-colors-p 
                              non-matching-p
                              nil))

(defun* mmm-ify
    (&rest all &key classes handler
	   submode match-submode
           (start (point-min)) (stop (point-max))
           front back save-matches (case-fold-search t)
           (beg-sticky (not (number-or-marker-p front)))
           (end-sticky (not (number-or-marker-p back)))
           include-front include-back
           (front-offset 0) (back-offset 0)
	   (front-delim nil) (back-delim nil)
	   (delimiter-mode mmm-delimiter-mode)
	   front-face back-face
           front-verify back-verify
           front-form back-form
	   creation-hook
           face match-face
	   save-name match-name
	   (front-match 0) (back-match 0)
	   end-not-begin
           ;insert private
           &allow-other-keys
           )
  "Create submode regions from START to STOP according to arguments.
If CLASSES is supplied, it must be a list of valid CLASSes. Otherwise,
the rest of the arguments are for an actual class being applied. See
`mmm-classes-alist' for information on what they all mean."
  ;; Make sure we get the default values in the `all' list.
  (setq all (append
             all
             (list :start start :stop stop
		   :beg-sticky beg-sticky :end-sticky end-sticky
		   :front-offset front-offset :back-offset back-offset
		   :front-delim front-delim :back-delim back-delim
		   :front-match 0 :back-match 0
		   )))
  (cond
   ;; If we have a class list, apply them all.
   (classes
    (mmm-apply-classes classes :start start :stop stop :face face))
   ;; Otherwise, apply this class.
   ;; If we have a handler, call it.
   (handler
    (apply handler all))
   ;; Otherwise, we search from START to STOP for submode regions,
   ;; continuining over errors, until we don't find any more. If FRONT
   ;; and BACK are number-or-markers, this should only execute once.
   (t
    (progn
     (goto-char start)
     (multiple-value-bind
         (beg end front-pos back-pos matched-front matched-back
              matched-submode matched-face matched-name invalid-resume
              ok-resume)
         (apply #'mmm-match-region :start (point) all)
       (dmessage "beg>%s<, end>%s<, front-pos>%s<" beg end front-pos)

       (loop
         while beg
         if end	       ; match-submode, if present, succeeded.
         do
         (condition-case nil
             (progn
               (mmm-make-region
                (or matched-submode submode) beg end
                :face (or matched-face face)
                :front front-pos :back back-pos
                :evaporation 'front
                :match-front matched-front :match-back matched-back
                :beg-sticky beg-sticky :end-sticky end-sticky
                :name matched-name
                :delimiter-mode delimiter-mode
                :front-face front-face :back-face back-face
                :creation-hook creation-hook
                )
               (goto-char ok-resume))
           ;; If our region is invalid, go back to the end of the
           ;; front match and continue on.
           (mmm-error (goto-char invalid-resume)))
         ;; If match-submode was unable to find a match, go back to
         ;; the end of the front match and continue on.
         else do (goto-char invalid-resume)))))))


(cl-pp mmm-classes-alist)

((dp-universal :front "^{%\\([^/].*?\\)%}" :back "{%/~1%}" :insert ((?/ dp-universal "Submode: " @ "{%" str "%}" @ "
" _ "
" @ "{%/" str "%}" @)) :match-submode dp-mmm-univ-get-mode :save-matches 1)
 (universal :front "{%\\([a-zA-Z-]+\\)%}" :back "{%/~1%}" :insert ((?/ universal "Submode: " @ "{%" str "%}" @ "
" _ "
" @ "{%/" str "%}" @)) :match-submode mmm-univ-get-mode :save-matches 1))nil


((dp-universal :front "^{%\\([^/].*?\\)%}" :back "{%/~1%}" :insert ((?/ dp-universal "Submode: " @ "{%" str "%}" @ "
" _ "
" @ "{%/" str "%}" @)) :match-submode dp-mmm-univ-get-mode :save-matches 1) (universal :front "{%\\([a-zA-Z-]+\\)%}" :back "{%/~1%}" :insert ((?/ universal "Submode: " @ "{%" str "%}" @ "
" _ "
" @ "{%/" str "%}" @)) :match-submode mmm-univ-get-mode :save-matches 1) (dp-universal :front "^{%\\([^/].*?\\)%}" :back dp-mmm-univ-back :insert ((?/ dp-universal "Submode: " @ "{%" str "%}" @ "
" _ "
" @ "{%/" str "%}" @)) :match-submode dp-mmm-univ-get-mode :save-matches 1))

(progn
  (setq mmm-classes-alist nil)
  (mmm-add-classes
   `((universal
      :front "{%\\([a-zA-Z-]+\\)%}"
      :back "{%/~1%}"
      :insert ((?/ universal "Submode: " @ "{%" str "%}" @ "\n" _ "\n"
                   @ "{%/" str "%}" @))
      :match-submode mmm-univ-get-mode
      :save-matches 1
      )))

  (mmm-add-classes
   `((dp-universal
      :front "^{%\\([^/].*?\\)%}"
      :back dp-mmm-back-quoted-regexp
      :insert ((?/ dp-universal "Submode: " @ "{%" str "%}" @ "\n" _ "\n"
                   @ "{%/" str "%}" @))
      :match-submode dp-mmm-univ-get-mode
      :save-matches 1
      )))
  mmm-classes-alist)
((dp-universal :front "^{%\\([^/].*?\\)%}" :back "{%/~1%}" :insert ((?/ dp-universal "Submode: " @ "{%" str "%}" @ "
" _ "
" @ "{%/" str "%}" @)) :match-submode dp-mmm-univ-get-mode :save-matches 1) (universal :front "{%\\([a-zA-Z-]+\\)%}" :back "{%/~1%}" :insert ((?/ universal "Submode: " @ "{%" str "%}" @ "
" _ "
" @ "{%/" str "%}" @)) :match-submode mmm-univ-get-mode :save-matches 1))

(cl-pe
 '(multiple-value-bind
   (beg end front-pos back-pos matched-front matched-back
        matched-submode matched-face matched-name invalid-resume
        ok-resume)
   (values 1 2 3 4)
   (princf "beg>%s<" beg)))

(let* ((#:G276968 (multiple-value-list-internal 0 11 (values 1 2 3 4)))
       (beg (prog1 (car #:G276968) (setq #:G276968 (cdr #:G276968))))
       (end (prog1 (car #:G276968) (setq #:G276968 (cdr #:G276968))))
       (front-pos (prog1 (car #:G276968) (setq #:G276968 (cdr #:G276968))))
       (back-pos (prog1 (car #:G276968) (setq #:G276968 (cdr #:G276968))))
       (matched-front (prog1
                          (car #:G276968)
                        (setq #:G276968 (cdr #:G276968))))
       (matched-back (prog1
                         (car #:G276968)
                       (setq #:G276968 (cdr #:G276968))))
       (matched-submode (prog1
                            (car #:G276968)
                          (setq #:G276968 (cdr #:G276968))))
       (matched-face (prog1
                         (car #:G276968)
                       (setq #:G276968 (cdr #:G276968))))
       (matched-name (prog1
                         (car #:G276968)
                       (setq #:G276968 (cdr #:G276968))))
       (invalid-resume (prog1
                           (car #:G276968)
                         (setq #:G276968 (cdr #:G276968))))
       (ok-resume (prog1 (car #:G276968) (setq #:G276968 (cdr #:G276968)))))
  (princf "beg>%s<" beg))nil


(cl-pe '(multiple-value-list
        '(1 2 3 4)))

(multiple-value-list
 (values 1 2 3))
(1 2 3)

 '(a b))
((a b))

(multiple-value-list-internal 0 multiple-values-limit '(1 2 3 4))
((1 2 3 4))



(1 2 3 4)

(a)




(multiple-value-list-internal 0 8 (values 1 2 3 4))
(1 2 3 4)

(1 2 3 4)


(let ((v (values 1 2 3 4)))
  (princf "v>%s<" v)
  (multiple-value-bind
      (beg end front-pos back-pos matched-front matched-back
           matched-submode matched-face matched-name invalid-resume
           ok-resume)
      v
    (princf "v>%s<" v)
    (princf "beg>%s<, end>%s<" beg end)))
v>1<
v>1<
beg>1<, end>nil<
nil

v>1<
v>1<
beg>1<, end>nil<
nil






(multiple-value-bind
   (beg end front-pos back-pos matched-front matched-back
        matched-submode matched-face matched-name invalid-resume
        ok-resume)
   (values (list 'a 'b 'c 'd))
  (princf "beg>%s<" beg))
beg>(a b c d)<
nil

beg>a<
nil


(defun* mmm-match-region
    (&key start stop front back front-verify back-verify
          include-front include-back front-offset back-offset
          front-form back-form save-matches match-submode match-face
	  front-match back-match end-not-begin
	  save-name match-name
          &allow-other-keys)
  "Find the first valid region between point and STOP.
Return \(BEG END FRONT-POS BACK-POS FRONT-FORM BACK-FORM SUBMODE FACE
NAME INVALID-RESUME OK-RESUME) specifying the region.  See
`mmm-match-and-verify' for the valid values of FRONT and BACK
\(markers, regexps, or functions).  A nil value for END means that
MATCH-SUBMODE failed to find a valid submode.  INVALID-RESUME is the
point at which the search should continue if the region is invalid,
and OK-RESUME if the region is valid."
  (when (mmm-match-and-verify front start stop front-verify)
    (let ((beg (mmm-match->point include-front front-offset front-match))
	  (front-pos (if front-delim
			 (mmm-match->point t front-delim front-match)
		       nil))
          (invalid-resume (match-end front-match))
          (front-form (mmm-get-form front-form)))
      (let ((submode (if match-submode
                         (condition-case nil
                             (mmm-save-all
                              (funcall match-submode front-form))
                           (mmm-no-matching-submode
                            (return-from
                                mmm-match-region
                              (values beg nil nil nil nil nil nil nil nil
                                      invalid-resume nil))))
                       nil))
	    (name (cond ((functionp match-name)
			 (mmm-save-all (funcall match-name front-form)))
			((stringp match-name)
			 (if save-name
			     (mmm-format-matches match-name)
			   match-name))))
            (face (cond ((functionp match-face)
                         (mmm-save-all
                          (funcall match-face front-form)))
                        (match-face
                         (cdr (assoc front-form match-face))))))
        (when (mmm-match-and-verify
               (if save-matches
                   (mmm-format-matches back)
                 back)
               beg stop back-verify)
          (let* ((end (mmm-match->point (not include-back)
					back-offset back-match))
		 (back-pos (if back-delim
			       (mmm-match->point nil back-delim back-match)
			     nil))
		 (back-form (mmm-get-form back-form))
		 (ok-resume (if end-not-begin 
				(match-end back-match)
			      end)))
            (values beg end front-pos back-pos front-form back-form
                                submode face name
                                invalid-resume ok-resume)))))))


(cl-pe
 '(values 1 2 3 4))

(values 1 2 3 4)nil
zzz_all_zzz
(:start 39928 :stop 39952 :front "{%\\([a-zA-Z-]+\\)%}" :back "{%/~1%}" :insert ((?/ universal "Submode: " @ "{%" str "%}" @ "
" _ "
" @ "{%/" str "%}" @)) :match-submode mmm-univ-get-mode :save-matches 1 :face nil :start 39928 :stop 39952 :beg-sticky t :end-sticky t :front-offset 0 :back-offset 0 :front-delim nil :back-delim nil :front-match 0 :back-match 0)

(with-current-buffer "daily-2013-09.jxt"
  (mmm-match-region :start (point) zzz_all_zzz))

nil

nil

nil

nil
(defun* fuckingfuck
    (&rest all &key classes handler
	   submode match-submode
           (start (point-min)) (stop (point-max))
           front back save-matches (case-fold-search t)
           (beg-sticky (not (number-or-marker-p front)))
           (end-sticky (not (number-or-marker-p back)))
           include-front include-back
           (front-offset 0) (back-offset 0)
	   (front-delim nil) (back-delim nil)
	   (delimiter-mode mmm-delimiter-mode)
	   front-face back-face
           front-verify back-verify
           front-form back-form
	   creation-hook
           face match-face
	   save-name match-name
	   (front-match 0) (back-match 0)
	   end-not-begin
           ;insert private
           &allow-other-keys
           )
  (setq all (append
             all
             (list :start start :stop stop
		   :beg-sticky beg-sticky :end-sticky end-sticky
		   :front-offset front-offset :back-offset back-offset
		   :front-delim front-delim :back-delim back-delim
		   :front-match 0 :back-match 0
		   )))

(cond
 (t (progn
      (multiple-value-bind
          (beg end front-pos back-pos matched-front matched-back
               matched-submode matched-face matched-name invalid-resume
               ok-resume)
          (dumbfun)
        (princf "beg>%s<, end>%s<, front-pos>%s<" beg end front-pos))))))
fuckingfuck

fuckingfuck
(fuckingfuck)
beg>a<, end>bb<, front-pos>ccc<
nil

beg>a<, end>bb<, front-pos>ccc<
nil

beg>a<, end>bb<, front-pos>ccc<
nil

(mmm-ify)





(defun* fuckingfuck
    (&rest all &key classes handler
	   submode match-submode
           (start (point-min)) (stop (point-max))
           front back save-matches (case-fold-search t)
           (beg-sticky (not (number-or-marker-p front)))
           (end-sticky (not (number-or-marker-p back)))
           include-front include-back
           (front-offset 0) (back-offset 0)
	   (front-delim nil) (back-delim nil)
	   (delimiter-mode mmm-delimiter-mode)
	   front-face back-face
           front-verify back-verify
           front-form back-form
	   creation-hook
           face match-face
	   save-name match-name
	   (front-match 0) (back-match 0)
	   end-not-begin
           ;insert private
           &allow-other-keys
           )
  "Create submode regions from START to STOP according to arguments.
If CLASSES is supplied, it must be a list of valid CLASSes. Otherwise,
the rest of the arguments are for an actual class being applied. See
`mmm-classes-alist' for information on what they all mean."
  ;; Make sure we get the default values in the `all' list.
  (setq all (append
             all
             (list :start start :stop stop
		   :beg-sticky beg-sticky :end-sticky end-sticky
		   :front-offset front-offset :back-offset back-offset
		   :front-delim front-delim :back-delim back-delim
		   :front-match 0 :back-match 0
		   )))
  (cond
   ;; If we have a class list, apply them all.
   (classes
    (mmm-apply-classes classes :start start :stop stop :face face))
   ;; Otherwise, apply this class.
   ;; If we have a handler, call it.
   (handler
    (apply handler all))
   ;; Otherwise, we search from START to STOP for submode regions,
   ;; continuining over errors, until we don't find any more. If FRONT
   ;; and BACK are number-or-markers, this should only execute once.
   (t
    (progn
     (goto-char start)
     (multiple-value-bind
         (beg end front-pos back-pos matched-front matched-back
              matched-submode matched-face matched-name invalid-resume
              ok-resume)
         (apply #'mmm-match-region :start (point) all)
       (dmessage "beg>%s<, end>%s<, front-pos>%s<" beg end front-pos)

       (loop
         while beg
         if end	       ; match-submode, if present, succeeded.
         do
         (condition-case nil
             (progn
               (mmm-make-region
                (or matched-submode submode) beg end
                :face (or matched-face face)
                :front front-pos :back back-pos
                :evaporation 'front
                :match-front matched-front :match-back matched-back
                :beg-sticky beg-sticky :end-sticky end-sticky
                :name matched-name
                :delimiter-mode delimiter-mode
                :front-face front-face :back-face back-face
                :creation-hook creation-hook
                )
               (goto-char ok-resume))
           ;; If our region is invalid, go back to the end of the
           ;; front match and continue on.
           (mmm-error (goto-char invalid-resume)))
         ;; If match-submode was unable to find a match, go back to
         ;; the end of the front match and continue on.
         else do (goto-char invalid-resume)))))))
fuckingfuck


(fuckingfuck)



(defun* mmm-ify
    (&rest all &key classes handler
	   submode match-submode
           (start (point-min)) (stop (point-max))
           front back save-matches (case-fold-search t)
           (beg-sticky (not (number-or-marker-p front)))
           (end-sticky (not (number-or-marker-p back)))
           include-front include-back
           (front-offset 0) (back-offset 0)
	   (front-delim nil) (back-delim nil)
	   (delimiter-mode mmm-delimiter-mode)
	   front-face back-face
           front-verify back-verify
           front-form back-form
	   creation-hook
           face match-face
	   save-name match-name
	   (front-match 0) (back-match 0)
	   end-not-begin
           ;insert private
           &allow-other-keys
           )
  "Create submode regions from START to STOP according to arguments.
If CLASSES is supplied, it must be a list of valid CLASSes. Otherwise,
the rest of the arguments are for an actual class being applied. See
`mmm-classes-alist' for information on what they all mean."
  ;; Make sure we get the default values in the `all' list.
  (setq all (append
             all
             (list :start start :stop stop
		   :beg-sticky beg-sticky :end-sticky end-sticky
		   :front-offset front-offset :back-offset back-offset
		   :front-delim front-delim :back-delim back-delim
		   :front-match 0 :back-match 0
		   )))
  (cond
   ;; If we have a class list, apply them all.
   (classes
    (mmm-apply-classes classes :start start :stop stop :face face))
   ;; Otherwise, apply this class.
   ;; If we have a handler, call it.
   (handler
    (apply handler all))
   ;; Otherwise, we search from START to STOP for submode regions,
   ;; continuining over errors, until we don't find any more. If FRONT
   ;; and BACK are number-or-markers, this should only execute once.
   (t
    (mmm-save-all
     (goto-char start)
     (multiple-value-bind
         (beg end front-pos back-pos matched-front matched-back
              matched-submode matched-face matched-name invalid-resume
              ok-resume)
         (apply #'mmm-match-region :start (point) all)
       (dmessage "beg>%s<, end>%s<, front-pos>%s<" beg end front-pos)
       (loop
         while beg
         if end	       ; match-submode, if present, succeeded.
         do
         (condition-case nil
             (let ((b beg))
               (setq beg nil)
               (dmessage "looping, beg>%s<" beg)
               (dmessage "YOPP!")
               (mmm-make-region
                (or matched-submode submode) b end
                :face (or matched-face face)
                :front front-pos :back back-pos
                :evaporation 'front
                :match-front matched-front :match-back matched-back
                :beg-sticky beg-sticky :end-sticky end-sticky
                :name matched-name
                :delimiter-mode delimiter-mode
                :front-face front-face :back-face back-face
                :creation-hook creation-hook
                )
               (dmessage "YOPP!2")
               (goto-char ok-resume)
               (setq beg nil)
               (dmessage "end of loop, beg>%s<" beg))
           ;; If our region is invalid, go back to the end of the
           ;; front match and continue on.
           (dmessage "mmm-error!")
           (mmm-error (goto-char invalid-resume)))
         ;; If match-submode was unable to find a match, go back to
         ;; the end of the front match and continue on.
         else do (goto-char invalid-resume)))))))


========================
Tuesday September 24 2013
--
(defun dp-setup-hide-ifdef-for-T3D.so (&optional extras)
  (interactive)
  (setq hide-ifdef-lines t
        hide-ifdef-env nil)
  (let ((defs (append dp-T3D-hide-ifdef-default-.so-defs extras)))
    (loop for (def op) in defs do
      (funcall op def)))
  (hide-ifdef-set-define-alist "t3d"))

(append '((a b) (c d)) nil (list (list 1 2) (list 8 9)))
((a b) (c d) (1 2) (8 9))


(1 2 3 a b c)


========================
Thursday October 10 2013
--


========================
Thursday October 17 2013
--

(cl-pp (dp-nvidia-make-cscope-database-regexps))

(("/home/scratch.dpanariti_t124_3/sb4/sb4hw/" (t)
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132")
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/"))
 ("/home/scratch.traces02/mobile/traces/system/so" ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/")))nil


(cl-pp cscope-database-regexps)

(("/home/scratch.dpanariti_t124_3/sb4/sb4hw/" (t)
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/Default_ap_tree")
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/"))
 ("/home/scratch.traces02/mobile/traces/system/so" ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/")))nil



;; (defun dp-me-code-db-locations ()
;;   (let* ((locstr (or (getenv "DP_NV_ME_DB_LOCS")
;;                      "//hw/ap_t132 //sw //arch //hw/class //hw/kepler1_gklit3 //dev //hw/tools"))
;;          (locs (split-string locstr))
;;          expansion
;;          result)
;;     (loop for loc in locs do
;;       (progn
;;         (setq expansion (dp-me-expand-dest loc (dp-current-sandbox-name)))
;;         (setq result
;;               (cons (list 
;;                      ".*"               ; match re
;;                      (list expansion))  ; db loc
;;                     result))))
;;     result))

(defun dp-me-code-db-locations ()
  (let* ((locstr (or (getenv "DP_NV_ME_DB_LOCS")
                     "//hw/ap_t132 //sw //arch //hw/class //hw/kepler1_gklit3 //dev //hw/tools"))
         (locs (split-string locstr))
         expansion
         result)
    (loop for loc in locs do
      (progn
        (setq expansion (dp-me-expand-dest loc (dp-current-sandbox-name)))
        (setq result
              (cons
               (list expansion)                ; db loc
              result))))
    (list
     `(,(dp-me-expand-dest "sb" (dp-current-sandbox-name))
       ,@result))))
dp-me-code-db-locations

(cl-pe (dp-me-code-db-locations))

(
 ("/home/scratch.dpanariti_t124_3/sb4/sb4hw" 
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/tools")
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/dev")
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/kepler1_gklit3")
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/class")
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/arch")
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/sw")
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132")))nil


(cl-pp
(setq cscope-database-regexps
      (dp-me-code-db-locations)))

(("/home/scratch.dpanariti_t124_3/sb4/sb4hw" ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/tools")
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/dev")
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/kepler1_gklit3")
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/class")
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/arch")
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/sw")
  ("/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132")))nil



;;installed (defun dp-nvidia-make-cscope-database-regexps ()
;;installed   "Compute value for `cscope-database-regexps'"
;;installed   (let* ((locstr (or (getenv "DP_NV_ME_DB_LOCS")
;;installed                      (concat
;;installed                       "ap sw arch //hw/class"
;;installed                       ;; NB! Make sure every item is separated by spaces.
;;installed                       " //hw/kepler1_gklit3 dev //hw/tools")))
;;installed          (locs (split-string locstr))
;;installed          (sb-name (dp-current-sandbox-name))
;;installed          expansion
;;installed          result)
;;installed     (list
;;installed      (append
;;installed       (list (dp-me-expand-dest "sb" sb-name))
;;installed       (delq nil (mapcar (function
;;installed                          (lambda (loc)
;;installed                            (list (dp-me-expand-dest loc sb-name))))
;;installed                         locs))))))

;; OLDE
(defun dp-nvidia-make-cscope-database-regexps ()
  "Compute value for `cscope-database-regexps'"
  (let* ((locstr (or (getenv "DP_NV_ME_DB_LOCS")
                     (concat
                      "ap sw arch //hw/class"
                      "//hw/kepler1_gklit3 dev //hw/tools")))
         (locs (split-string locstr))
         expansion
         result)
    (loop for loc in locs do
      (progn
        (setq expansion (dp-me-expand-dest loc (dp-current-sandbox-name)))
        (setq result
              (cons
               (list expansion)         ; db loc
              result))))
    (list
     `(,(dp-me-expand-dest "sb" (dp-current-sandbox-name))
       ,@result))))


========================
Monday October 28 2013
--



dp-shells-shell-buffer-list
(#<buffer "*shell*<5>">)


(sort dp-shells-shell-buffer-list 'dp-buffer-less-p)
(#<buffer "*shell*<5>">)


(dp-shells-find-matching-shell-buffers nil ".*")
(#<buffer "*shell*<5>"> #<buffer "*shell*<1>"> #<buffer "*shell*<3>"> #<buffer "*shell*<2>"> #<buffer "*shell*<4>">)

(cl-pp (sort (dp-shells-find-matching-shell-buffers nil ".*") 'dp-buffer-less-p))

(#<buffer "*shell*<1>"
          >
          #<buffer
          "*shell*<2>"
          >
          #<buffer
          "*shell*<3>"
          >
          #<buffer
          "*shell*<4>"
          >
          #<buffer
          "*shell*<5>"
          >)nil

(memq (get-buffer "*shell*<3>")
      (sort (dp-shells-find-matching-shell-buffers nil ".*") 'dp-buffer-less-p))
(#<buffer "*shell*<3>"> #<buffer "*shell*<4>"> #<buffer "*shell*<5>">)

(#<buffer "*shell*<5>">)



(get-buffer "*shell*<5>")
#<buffer "*shell*<5>">

(dp-shell-buffer-p (get-buffer "*shell*<5>"))
(dp-shell shell)

(nth 1
(memq (get-buffer "*shell*<5>")
      (sort (dp-shells-find-matching-shell-buffers nil ".*") 'dp-buffer-less-p))
)
nil



========================
Tuesday November 12 2013
--

(#<buffer "*shell*<1>"> #<buffer "*shell*<22>"> #<buffer "*shell*<2>"> #<buffer "*shell*<3>">)

(defun dp-buffer-less-by-name-p (buf1 buf2)
  (string-lessp (buffer-name buf1)
                (buffer-name buf2)))

(defun dp-shell-buffer-num-comp (buf1 buf2 op)
  (funcall op 
           (symbol-value-in-buffer 'dp-shell-num buf1)
           (symbol-value-in-buffer 'dp-shell-num buf2)))

(get-buffer "*shell*<22>")
#<buffer "*shell*<22>">

(dp-shell-buffer-num-comp (get-buffer "*shell*<22>")
                          (get-buffer "*shell*<2>")
                          '>=)
t

nil

t

t

nil

nil




========================
Wednesday November 20 2013
--
(defun dp-defface-p (face-name)
  (and (symbolp face-name)
       (get face-name 'face-defface-spec)
       (custom-face-get-spec face-name)
       face-name))
dp-defface-p


              
(dp-defface-p 'dp-debug-like-face)
dp-debug-like-face

(dp-colorize-region (dp-defface-p 'dp-debug-like-facex)
                    (- (point) 100) (point))
#<extent [190425, 190525) dp-extent-search-key2 dp-extent-search-key dp-colorized-region-color-num dp-colorized-p dp-extent dp-extent-id dp-colorized-region in buffer elisp-devel.el 0x67950>

#<extent [190425, 190525) dp-extent-search-key2 dp-extent-search-key dp-colorized-region-color-num dp-colorized-p dp-extent dp-extent-id dp-colorized-region in buffer elisp-devel.el 0x6792f>

#<extent [190424, 190524) dp-extent-search-key2 dp-extent-search-key dp-colorized-p dp-extent dp-extent-id dp-colorized-region in buffer elisp-devel.el 0x67906>

nil




========================
Thursday November 21 2013
--
(defun dp-stringize-args (&rest r)
  (message "YOPP! r>%s<" r)
  (setq dpv-blah2 (format "%s" r)))
dp-stringize-args
(setq dpv-blah (princ "HAHA" 'dp-stringize-args))
"HAHA"

(1 2 3)



dpv-blah2
"(?\\))"


(1 2 3)
(listp dpv-blah)
t

nil

(1 2 3)

(1 2 3)
dp-editor-identification-data
(dp-short-hostname)
"sc-xterm-19"

(setq dp-editor-identification-data '((host-name . "sc-xterm-19") (sandbox-name . "sb4") (pid . 24789))
((host-name . "sc-xterm-19") (sandbox-name . "sb4") (pid . 24789))



(with-temp-file "/home/dpanariti/tmp/with-temp-file"
  (prin1 dp-editor-identification-data (current-buffer))
  (insert "\n"))
nil

((host-name . "bubba") (sandbox-name . "sb4") (pid . 24789))

((host-name . "bubba") (sandbox-name . "sb4") (pid . 24789))


((host-name . "bubba") (sandbox-name . "sb4") (pid . 24789))

(dp-with-all-output-to-string
  (cl-pp dp-editor-identification-data))
"
((host-name . \"bubba\")
 (sandbox-name . \"sb4\")
 (pid . 24789))
"

"
((host-name . \"bubba\")
 (sandbox-name . \"sb4\")
 (pid . 24789))
"
"
((host-name . \"bubba\")
 (sandbox-name . \"sb4\")
 (pid . 24789))
"



"((host-name . bubba) (sandbox-name . sb4) (pid . 24789))"



  (insert (format "'%s\n" dp-editor-identification-data)))
nil

nil

"((host-name . bubba) (sandbox-name . sb4) (pid . 24789))"


((host-name . "bubba") (sandbox-name . "sb4") (pid . 24789))

((host-name . bubba) (sandbox-name . sb4) (pid . 24789))((host-name . "bubba") (sandbox-name . "sb4") (pid . 24789))

nil

nil

(cons "bubba" dp-editor-identification-data)
("bubba" (sandbox-name . "sb4") (pid . 24789))

(dp-add-editor-identification-data 'host-name "bubba")
((host-name . "bubba") (sandbox-name . "sb4") (pid . 24789))

(eval-expr "'(a b)")
"'(a b)"
(caar (read-from-string "(a b)"))
a

quote

(quote (a b))

((quote (a b)) . 6)

"'(a b)"
eval-expr
file; ((host-name . bubba) (sandbox-name . sb4) (pid . 24789))
dp-editor-identification-data
(equal dp-editor-identification-data
       '((host-name . "bubba") (sandbox-name . "sb4") (pid . 24789)))
t


(defun dp-compare-ipc-file (file-name)
  (setq-ifnil file-name (dp-editing-server-ipc-file))
  (equal (car (read-from-string (dp-read-file-as-string file-name)))
         dp-editor-identification-data))

(setq dpv-xxx (princ dp-editor-identification-data))
((host-name . bubba) (sandbox-name . sb4) (pid . 24789))((host-name . "bubba") (sandbox-name . "sb4") (pid . 24789))
dpv-xxx
((host-name . "bubba") (sandbox-name . "sb4") (pid . 24789))

(format "%s" dp-editor-identification-data)
"((host-name . bubba) (sandbox-name . sb4) (pid . 24789))"


((host-name . bubba) (sandbox-name . sb4) (pid . 24789))((host-name . "bubba") (sandbox-name . "sb4") (pid . 24789))

((host-name . bubba) (sandbox-name . sb4) (pid . 24789))
nil

(eval (car (read-from-string (dp-read-file-as-string "/home/dpanariti/tmp/with-temp-file"))))

(list ((host-name . bubba) (sandbox-name . sb4) (pid . 24789)))

(equal 
 (car (read-from-string (dp-read-file-as-string "/home/dpanariti/tmp/with-temp-file")))
;;((host-name . "bubba") (sandbox-name . "sb4") (pid . 24789))


 dp-editor-identification-data
;;((host-name . "bubba") (sandbox-name . "sb4") (pid . 24789))

)
t

nil

nil

(eval dp-editor-identification-data)
dp-editor-identification-data
((pid . 24789) (sandbox-name . "sb4") (host-name . "sc-xterm-19"))



(dp-compare-ipc-file (dp-editing-server-ipc-file))
nil

dp-
t



(dp-creat-editing-server-ipc-file)
nil

nil

nil

(setq dp-editor-identification-data '((host-name . "sc-xterm-19") (sandbox-name . "sb4") (pid . 24789)))
((host-name . "sc-xterm-19") (sandbox-name . "sb4") (pid . 24789))


((host-name . "sc-xterm-19") (sandbox-name . "sb4") (pid . 24789))

dp-editor-identification-data
((host-name . "sc-xterm-19") (sandbox-name . "sb4") (pid . 24789))


((host-name . "bubba") (sandbox-name . "sb4") (pid . 24789))


(dp-creat-editor-identification-data)
((pid . 24789) (sandbox-name . "sb4") (host-name . "sc-xterm-19"))
dp-editor-identification-data
((pid . 24789) (sandbox-name . "sb4") (host-name . "sc-xterm-19"))

dp-editor-identification-data
((sandbox-name) (pid . 16772) (host-name . "sc-xterm-19"))

((sandbox-name) (pid . 16772) (host-name . "sc-xterm-19"))

((sandbox-name . "sb4") (pid . 16772) (host-name . "sc-xterm-19"))

((sandbox-name . "sb4") (pid . 16772) (host-name . "sc-xterm-19"))

((sandbox-name . "sb3") (pid . 16772) (host-name . "sc-xterm-19"))

((sandbox-name . "sb3") (pid . 16772) (host-name . "sc-xterm-19"))

(dp-creat-editing-server-ipc-file)
nil

nil

nil


(dp-compare-ipc-file)
t
dp-editor-identification-data
((sandbox-name . "sb4") (pid . 16772) (host-name . "sc-xterm-19"))

nil

t

nil

t

t

nil

(loop for (a b) on '((1 . 2 ) (a . b))
  do
  (princf "a>%s<, b>%s<" a b))
a>(1 . 2)<, b>(a . b)<
a>(a . b)<, b>nil<
nil

(loop for c in '((1 . 2 ) (a . b))
  do
  (princf "c>%s<" c))
c>(1 . 2)<
c>(a . b)<
nil

c>((1 . 2) (a . b))<
c>((a . b))<
nil






(defun dp-simple-assoc-cmp (a1 a2)
  "Compare two simple alists, independent of order.
Simple means that the values are comparable with `equal'."
  (when (equal (length a1) (length a2))
    (not
     (loop for a1-el in a1
       do
       (unless (equal (cdr a1-el)
                      (cdr (assoc (car a1-el) a2)))
         (return 'neq))))))
(let
    ((a1 '((d . b) (1 . 2)))
     (a2 '((1 . 2) (a . b))))
  (dp-simple-assoc-cmp a1 a2))
nil

t

nil


neq





========================
Monday December 16 2013
--

(defun dp-looking-at-regexp (regexp &rest rest)
  (let ((start-pos (point)))
    (save-excursion
      (when (and (apply 're-search-forward regexp rest)
                 (= start-pos (match-beginning 0)))
        (match-beginning 0)))))






========================
Thursday January 02 2014
--

(format-kbd-macro 'bubq)
"C-s booboo: RET M-x bubba RET"

dp-tgen-elf-load-option
"-chipargs '-elf_load /home/denver/release/sw/components/mts/1.0/cl28625566/debug_arm/denver/bin/mts.elf@0xe0000000:/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132/drv/mpcore/t132/ObjLinux_MPCoreXC/boot_page_table.axf:/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132/diag/testgen/dp-rtl-tests/top_peatrans_gpurtl-2013-11-21T08.33.48-0800/cpu_surface_write_read/override.elf@0xe0000000:/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132/diag/testgen/dp-rtl-tests/top_peatrans_gpurtl-2013-11-21T08.33.48-0800/cpu_surface_write_read/t132/ObjLinux_MPCoreXC/cpu_surface_write_read.Cortex-A8.axf:/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132/diag/testgen/dp-rtl-tests/top_peatrans_gpurtl-2013-11-21T08.33.48-0800/cpu_surface_write_read/t132/ObjLinux_ARM7TDMIXC/cpu_surface_write_read.ARM7TDMI.axf:' "

"/home/scratch.dpanariti_t124_2/sb5/sb5hw/hw/ap_t132/diag/testgen/dp-rtl-tests/top_peatrans_gpurtl-2013-12-17T07.20.54-0800/cpu_surface_write_read/"

/home/scratch.dpanariti_t124_3/sb4/sb4hw/hw/ap_t132/drv/mpcore/t132/objlinux_mpcorexc/boot_page_table.axf
----------------------------------------
/home/scratch.dpanariti_t124_3/sb4/sb4hw/
(dp-current-sandbox-path)
"/home/scratch.dpanariti_t124_2/sb5/sb5hw"

(getenv "PWD")
"/home/dpanariti"

default-directory
"/home/dpanariti/lisp/devel/"

(defun bubba ()
  (interactive)
  (with-current-buffer "cpu_surface_write_read.mods.sh"
    (princf "default-directory>%s<" default-directory)
    (dp-tgen-generate-elf-load-option dp-vx)))

booboo:


========================
Friday January 17 2014
--



========================
Wednesday January 29 2014
--



========================
Thursday January 30 2014
--

;;installed (dp-deflocal dp-shells-save-buffer-flag-p t
;;installed   "Should this buffer be saved when a `dirty buffer' action in a shell window is executed.
;;installed E.g. *grep, make, etc.")

;;installed (defun dp-shells-save-buffer-p ()
;;installed   dp-shells-save-buffer-flag-p)


========================
Tuesday March 04 2014
--

(defvar dp-cscope-current-dir-only-regexps
  nil)

(defvar dp-cscope-force-current-dir-only-old-regexps nil)

(defun dp-cscope-force-current-dir-only (&optional restore-p)
  (interactive "P")
  (if restore-p
      (setq cscope-database-regexps dp-cscope-force-current-dir-only-old-regexps)
    (setq dp-cscope-force-current-dir-only-old-regexps cscope-database-regexps
          cscope-database-regexps dp-cscope-current-dir-only-regexps)))

(setq old-cscope-database-regexps cscope-database-regexps)
(("/home/scratch.dpanariti_t124_2/sb5/sb5hw" ("/home/scratch.dpanariti_t124_2/sb5/sb5hw/hw/ap_t132") ("/home/scratch.dpanariti_t124_2/sb5/sb5hw/arch") ("/home/scratch.dpanariti_t124_2/sb5/sb5hw/sw/dev") ("/home/scratch.dpanariti_t124_2/sb5/sb5hw/sw/mods") ("/home/scratch.dpanariti_t124_2/sb5/sb5hw/sw/tools") ("/home/scratch.dpanariti_t124_2/sb5/sb5hw/hw/class") ("/home/scratch.dpanariti_t124_2/sb5/sb5hw/hw/tools")))

(setq cscope-database-regexps nil)
nil

(setq dp-cscope-force-current-dir-only-old-regexps old-cscope-database-regexps)



(cl-pe '(setq-if-unbound blag "blrogh" orgh "bubba"))

(progn
  (if (boundp 'blag) blag (setq blag "blrogh"))
  (if (boundp 'orgh) orgh (setq orgh "bubba")))nil



(if (boundp 'blag) blag (setq blag "blrogh"))nil



(if (boundp 'blag) blag (setq arg "blrogh"))nil

(cl-pe '(setq-ifnil-or-unbound blag "blrogh"))

(if (progn nil (and (boundp 'blag) blag)) blag (setq arg "blrogh"))nil


(cl-pe '(setq-ifnil blag "blrogh"))

(if blag blag (setq blag "blrogh"))nil
(if blag blag (setq blag "blrogh"))nil

(cl-pe '(setq-if-unbound cscope-database-regexps
                 (funcall dp-make-cscope-database-regexps-fun)))

(if (boundp 'cscope-database-regexps)
    cscope-database-regexps
  (setq cscope-database-regexps (funcall dp-make-cscope-database-regexps-fun)))
nil






========================
Wednesday May 28 2014
--

"//[^:#]+[^ 	
]"
dp-ws+newline-regexp-not
"[^ 	
]"
dp-p4-location-regexp-ext
"\\(//[^:#]+\\)\\([^ 	
]*\\)"

dp-p4-location-regexp
"//[^:#]+"


(progn
  (re-search-forward (concat dp-p4-location-regexp-ext))
  (princf "ms0: %s, ms1: %s, ms2: %s" 
          (match-string 0) 
          (match-string 1)
          (match-string 2))) //perforce/sucks#3

 //perforce/sucks#3
(progn
  (condition-case nil
      (error 'error)
    (error
     (message "Don't cry.")))
  (princf "I made it."))
I made it.
nil


========================
Wednesday July 02 2014
--
(defun dp-get-file-info-to-path (cfi-path file-name)
  (interactive)                         ; For testing.
  (let ((file-basename (file-name-nondirectory file-name)))
    (mapcar (function 
             (lambda (path)
               (if (string-match "\\(^\\|[^%]\\)%s" path)
                   (format path file-basename)
                 (replace-in-string path "%%s" "%s"))))
            cfi-path)))

(dp-get-file-info-to-path '("a/b" "/%s/b" "a%%sb") "BUBBA")
("a/b" "/BUBBA/b" "a%sb")


(replace-in-string "123a" "a" "QQQ")
"123QQQ"

nil

========================
2014-07-16T16:32:17
--

(defun dp-shell-command-to-echo-area)

========================
Thursday July 24 2014
--
(defun dp-use-line-too-long-font-p ()
  nil)
(dp-use-line-too-long-font-p)
nil




(cl-pe '
(when (and
       t
       (dp-funcall-if 'dp-use-line-too-long-font-p
           nil
         'q)))

)

(when (and t
           (if (functionp 'dp-use-line-too-long-font-p)
               (funcall 'dp-use-line-too-long-font-p)
             'q))
  'ayup)
nil

anope

ayup

ayup

nil

nil

nil




(if (and t
         (if (functionp 'dp-use-line-too-long-font-p)
             (funcall 'dp-use-line-too-long-font-p)
           'q))
    'yopp
  'yipp)
yopp



(if (and t
         (if (functionp 'dp-use-line-too-long-font-p)
             (funcall 'dp-use-line-too-long-font-p quote a)
           'q))
    nil)nil




(fboundp 'anddlfkd)
nil


(cl-pe '
(if-and-fboundp 'orxxdcx
    'then
'else))

(if (and (fboundp 'orxxdcx) (symbol-function 'orxxdcx)) 'then 'else)
else



(if (and (fboundp 'or) (symbol-function 'or)) 'then 'else)
then



(if (and (fboundp 'dp-next-line) (symbol-function 'dp-next-line)) 'then 'else)
then




(symbol-function 'x)



else

(cl-pe '(when (and
               (not buffer-read-only)
               (if-and-fboundp 'dp-use-line-too-long-font-p
                   (dp-use-line-too-long-font-p)
                 t))                    ; default to using it.
         'when))

(if (and (not buffer-read-only)
         (if (and (fboundp 'dp-use-line-too-long-font-p)
                  (symbol-function 'dp-use-line-too-long-font-p))
             (dp-use-line-too-long-font-p)
           t))
    'when)
nil





