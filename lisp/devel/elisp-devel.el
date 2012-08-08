
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
  (interactive "P")
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

find . -type f -print0 | xargs -r0 fgrep

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

