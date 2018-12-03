;;;
;;; $Id: dp-vars.el,v 1.27 2005/06/13 08:20:07 davep Exp $
;;;
;;; Configurable variables.
;;; Defined and initialized here.  
;;; Can be overridden in one of the spec-macs files or in the
;;; custom file.
;;;

(defgroup dp-vars nil
  "My personal customizable variables."
  :group 'local)

(defgroup dp-whitespace-vars nil
  "My vars dealing with whitespace."
  :group 'dp-vars)

;;
;; email sig stuff
(defcustom dp-sig-source nil
  "*Source for the email signature:
nil     --> no sig
stringp --> signature text to insert
other   --> form to be eval'd
            (e.g. '(dp-insert-cmd-sig \"fortune\" \"-s\"))"
  :group 'dp-vars)

;; look into dp-mail for other options or to create options.
(defcustom dp-mailer 'mu4e
  "*Whom art thyne mailur?"
  :group 'dp-vars
  :type 'symbol)

(defcustom dp-mail-include-sig-p t
  "*Add sigs to outgoing email?"
  :group 'dp-vars
  :type 'boolean)

(defcustom dp-allow-owner-to-eval-p t
  "*Should the user be allowed to automatically eval his own Local Variables?"
  :group 'dp-vars
  :type 'boolean)

(defcustom dp-mailer-setup nil
  "*Func to call for additional mailer setup."
  :group 'dp-vars
  :type 'function)

(defcustom dp-mail-fullname "David A. Panariti"
  "*DON'T SET THIS HERE. SET IT IN THE LOCAL SPEC_MACS.
Full name for email."
  :group 'dp-vars
  :type 'string)

(defcustom dp-mail-domain nil
  "*DON'T SET THIS HERE. SET IT IN THE LOCAL SPEC_MACS.
Domain to which to send email."
  :group 'dp-vars
  :type 'string)

(defcustom dp-mail-user nil
  "*DON'T SET THIS HERE. SET IT IN THE LOCAL SPEC_MACS.
Username of email account."
  :group 'dp-vars
  :type 'string)

(defcustom dp-mail-outgoing-host 
  "*DON'T SET THIS HERE. SET IT IN THE LOCAL SPEC_MACS."
  "*DON'T SET THIS HERE. SET IT IN THE LOCAL SPEC_MACS.
Username of email account"
  :group 'dp-vars
  :type 'string)

(defcustom dp-mail-incoming-host nil
  "Not used yet."
  :group 'dp-vars
  :type 'string)

;;
;; switch to control font locking.
(defcustom dp-fontify-p t
  "*Are we interested in fontification?"
  :group 'dp-vars
  :type 'boolean)

;;
;; switch to disable all spelling
(defcustom dp-use-spell-p t
  "*Are we interested in using any kind of spelling?"
  :group 'dp-vars
  :type 'boolean)

;;
;; switch to control use of flyspell.
(defcustom dp-use-flyspell-p t
  "*Are we interested in using flyspell?"
  :group 'dp-vars
  :type 'boolean)

;;
;; switch to control preference of other windows, if one exists.
(defcustom dp-likes-other-open-windows-p nil
  "*Do we prefer other existing windows when available?"
  :group 'dp-vars
  :type 'boolean)

;;
;; switch to control preference of other windows, if one exists.
(defcustom dp-likes-other-windows-p nil
  "*Do we prefer other windows when available?"
  :group 'dp-vars
  :type 'boolean)

;;
;; set up the default to stick everything in sent_mail.  This will
;; likely be overridden in the spec-macs.
;; this is unused when mew is used.
(defcustom dp-fcc-alist '((nil ("to") "sent_mail"))
  "*Regexps for determining which folder gets the fcc."
  :group 'dp-vars
  :type 'list)

;;
;; mostly unneeded with mew
(defcustom dp-metamail-buffer "*metamail*"
  "*Buffer into which we place MIME contents extracted by dp-metamail."
  :group 'dp-vars
  :type 'string)

(defcustom dp-rcs-headers '("Header")
  "*Default RCS headers to insert."
  :group 'dp-vars
  :type '(repeat string))

(defcustom dp-function-comment-file "~/etc/function-comment-header.c"
  "*Value says it all, this is inserted by \\[fc]"
  :group 'dp-vars
  :type '(file :must-match t))

(defcustom dp-class-function-comment-file "~/etc/class-function-comment-header.c"
  "*Value says it all, this is inserted by \\[cfc]"
  :group 'dp-vars
  :type '(file :must-match t))

(defcustom digital-header-file "~/etc/digital.h"
  "*Digital^H^H^H^H^H^HCompaq^H^H^H^H^H HP disclaimer, copyright, etc."
  :group 'dp-vars
  :type '(file :must-match t))

(defcustom dp-per-dir-abbrev-files 
  '("./.dp-local-abbrevs")              ; Allow local abbrevs per dir.
  "*Local, per-dir abbrev files."
  :group 'dp-vars
  :type '(repeat (file :must-match t :tag "abbrev file")))

(defcustom dp-abbrev-files
  (nconc '("~/.go.emacs" "~/etc/mailiases.el")
	 dp-per-dir-abbrev-files)
  "*Files to be loaded by `dp-abbrevs'."
  :group 'dp-vars
  :type '(repeat (file :must-match t :tag "abbrev file")))

;;
;; dated note file location
(defcustom dp-note-base-dir "~/notes"
  "*Dated note file location.  Used by many notes functions."
  :group 'dp-vars
  :type 'directory)

(defcustom dp-note-index-dir (or (getenv "DP_NOTE_INDEX_DIR")
				 "~/stuff/indices/notes")
  "*Dated note file index location.  Used by notes indexing/searching functions."
  :group 'dp-vars
  :type 'directory)

(defcustom dp-mail-index-dir (or (getenv "DP_MAIL_INDEX_DIR")
				 "~/stuff/indices/mh")
  "*MH/Mew mail index location.  Used by mail indexing/searching functions."
  :group 'dp-vars
  :type 'directory)

(defcustom dp-port-index-dir (or (getenv "DP_PORT_INDEX_DIR")
				 "~/stuff/indices/ports")
  "*Port index location.  Used by port indexing/searching functions."
  :group 'dp-vars
  :type 'directory)

(defcustom dp-go-back-ring-max 64
  "*Max size of ring of markers to go back to."
  :group 'dp-vars
  :type 'integer)

(defcustom dp-use-ffap-p t
  "*Replace find-file with find-file-at-point, aka ffap."
  :group 'dp-vars
  :type 'boolean)

(defcustom dp-less-program "lesspipe-new.sh"
  "*Program to interpret files into ASCII."
  :group 'dp-vars
  :type 'string)

(defcustom dp-get-file-owner-program 
  "ls -l %s | awk '{print $3}'"
  "*Program to get the owner of a file."
  :group 'dp-vars
  :type 'string)

(defcustom dp-default-endicator-xpm-file nil
  "Default xpm file to add as buffer endicator glyph.
nil --> use builtin image of chuck."
  :group 'dp-vars
  :type '(choice (const :tag "Builtin (chuckie)" nil)
		 (file :must-match t :tag "pixmap file")))

(defcustom dp-use-buffer-endicator-p (dp-xemacs-p)  ; FSF canna handle this.
  "*Put something special to indICATE the END of the buffer."
  :group 'dp-vars
  :type 'boolean)

(defcustom dp-cleanup-buffers-mode-list
  '(help-mode
    completion-list-mode
    Manual-mode
    hyper-apropos-mode
    hyper-apropos-help-mode
    Dictionary
    Custom
    Info-mode
    debugger-mode)
  "List of major modes of buffers to be deleted by `dp-cleanup-buffers'."  
  :group 'dp-vars 
  :type '(repeat (symbol :tag "Major mode")))

(defcustom dp-preferred-web-search-site
  "http://www.google.com"
  "*Preferred site for doing web searches."
  :group 'dp-vars
  :type 'string)

;; google's looks like this:
;; http://www.google.com/search?hl=en&ie=ISO-8859-1&q=aqualonde
(defcustom dp-preferred-web-search-url+query
  (concat dp-preferred-web-search-site "/search?hl=en&ie=ISO-8859-1&q=%s")
  "*Preferred site for doing web searches with %s to hold query."
  :group 'dp-vars
  :type 'string)

(defcustom dp-preferred-web-search-browser-function
  'w3m
  "*Function to call with `dp-preferred-web-search-site' to do web searches."
  :group 'dp-vars
  :type 'function)

(defcustom dp-passwords-file "~/etc/passwords.asc"
  "*Holds passwords encrypted by pgp."
  :group 'dp-vars
  :type '(file :must-match t))

(defcustom dp-std-format-time-string-format "%a %b %e %T %Z %Y"
  "Gives a date/time like so: Mon Dec 18 13:40:01 EST 2006 -- tc-le5"
  :group 'dp-vars
  :type 'string)

(defcustom dp-prefer-ipython-shell-p t
  "*Use ipython if we can find it?"
  :group 'dp-vars
  :type 'boolean)

(defcustom dp-highlight-point-in-new-buffer/window-p t
  "*A rose is a rose."
  :group 'dp-vars
  :type 'boolean)

(defcustom dp-spell-programs '("aspell" "ispell" "hunspell")
  "*Candidate programs for spelling.  Checked in order."
  :group 'dp-vars
  :type '(repeat string))

(defcustom dp-code-indexer-data-files 
  '("TAGS" 
    "tags" 
    "cscope.files"
    "cscope.out"
    "cscope.in.out"
    "cscope.po.out"
    "ID"
    "GTAGS"
    "GRTAGS"
    "GPATH")
  "*Files used to support code indexing, eg: tags, cscope, etc.
These should be regexp quoted."
  :group 'dp-vars
  :type '(repeat string))

(defcustom dp-gtags-cscope-findstring-options-env-var-name "GLOBAL_FS_OPTS"
  "*The environment variable name to pass opts to  gtags-cscope findstring()."
  :type 'string
  :group 'cscope)

(defcustom dp-gtags-cscope-ignore-case-strings-p t
  "*Should we ignore case searching for strings when using gtags-cscope?"
  :type 'boolean
  :group 'cscope)

(defcustom dp-gtags-cscope-gtags-ignore-case-option "--ignore-case"
  "*Option to tell GNU global gtags to ignore case when searching for strings."
  :type 'string
  :group 'cscope)

(defcustom dp-cscope-program "gtags-cscope"
  "*The pathname of the cscope executable to use."
  :type 'string
  :group 'cscope)

(defvar dp-using-gtags-cscope-p 
  (string= dp-cscope-program "gtags-cscope")
  "Um, well, are, we..., um... like using gtags-cscope?")

(defcustom dp-ssh-host-name-completion-list '()
  "*List of common hostnames provided for your completing pleasure.
Elemental Format: \(host-name . plist-or-t)
PLIST-OR-T if not t, is a plist.  The only current (ie: 2008-10-06T14:23:05)
property is 'ip-addr whose value is a string containing a dotted ip qaddress.
A good thing to add to in a spec-macs file."
  :group 'dp-vars
  :type '(repeat string))

;; e.g. "^/home/davep/work/ll/rsvp"
(defcustom dp-implied-read-only-filename-regexp-list '()
  "*List of regexps to determine which files are forced to be read only.
Each new buffer's file name as returned by `expand-file-name' is matched
against the list of regexps."
  :group 'dp-vars
  :type '(repeat string))

(defcustom dp-local-debug-like-patterns '()
  "Additional debug like patterns used by `dp-mk-debug-like-patterns'"
  :group 'dp-vars
  :type '(repeat string))

(defcustom dp-highlight-excluded-buffers '(" \\*Minibuf-[0-9]+")
  "Don't highlight the current line upon window change in buffers matching these patterns."
  :group 'dp-vars
  :type '(repeat string))

(defcustom dp-ask-to-change-bm-protect-status-p nil
  "*A rose is a rose."
  :group 'dp-vars
  :type 'boolean)

(defcustom dp-use-xgtags-p t
  "*A rose is a rose."
  :group 'dp-vars
  :type 'boolean)

(defcustom dp-use-gtags-p (not dp-use-xgtags-p)
  "*A rose is a rose."
  :group 'dp-vars
  :type 'boolean)

;; Needs must make it work.  Seems to interact poorly with my stuff.
;; Advices?
(defcustom dp-use-ggtags-p nil
  "*A rose is a rose."
  :group 'dp-vars
  :type 'boolean)

(defcustom dp-use-etags-p nil
  "*A rose is a rose."
  :group 'dp-vars
  :type 'boolean)

(defcustom dp-wants-ansi-color-p nil
  "*Convert ANSI escape sequences to faces in comint and derived modes.
Unfortunately there are a lot of font problems: different sizes, not all
fixed width, etc.
Things are looking better with this (quite nice, readable and legible) font:
-*-Bitstream Vera Sans Mono-medium-r-*-*-*-100-*-*-*-*-*-*"
  :group 'dp-vars
  :type 'boolean)

;;;;;;;;;;;;;;;;;;;;;;;
;; fsf/x emacs difference
;;
;;;
;;; These are just symbols.
;;; We define and get definitions of faces later.
;;; 
(defcustom dp-colorize-region-faces
  '(dp-cifdef-face0
    dp-cifdef-face1
    dp-cifdef-face3
    dp-cifdef-face5
    dp-journal-function-args-face
    dp-journal-medium-example-face
    dp-journal-high-example-face
    dp-journal-selected-face
    dp-journal-topic-face dp-journal-topic-stamp-face
    dp-journal-timestamp-face dp-journal-datestamp-face
    dpj-view-grep-hit-face
    dp-journal-todo-face dp-journal-done-face
    dp-journal-low-problem-face
    dp-journal-medium-problem-face
    dp-journal-high-problem-face
    dp-journal-low-example-face
    dp-journal-high-question-face dp-journal-low-todo-face
    dp-journal-medium-todo-face dp-journal-high-todo-face
    dp-journal-cancelled-action-item-face
    dp-journal-completed-action-item-face
    dp-journal-function-face
    dp-journal-embedded-lisp-face dp-journal-alt-0-face
    dp-journal-alt-1-face
    dp-journal-unselected-face
    dp-cifdef-face2
    dp-cifdef-face4
    dp-cifdef-face6)
  "List of faces to use when highlighting regions.
@todo Is there any way to extract these names from the defface data?
Look at `face-list'.  grep for \"dp-.*\" ??"
  :group 'dp-faces
  :type '(repeat face))

(defcustom dp-faces-regexp "dpj?-.*\\(face\\|color\\)"
  "Regexp to recognize my faces."
  :group 'dp-faces
  :type 'regexp)

;;;
;;; CEDET package activation control <:cedet:>
;;;

(defcustom dp-main-project-root nil
  "Needed by CEDET, et. al."
  :group 'dp-vars 
  :type 'directory)

(defcustom dp-main-project-includes nil
  "Needed by CEDET, et. al."
  :group 'dp-vars 
  :type '(repeat directory))

(defcustom dp-wants-xemacs-cedet-hacks-et-al-p nil
  "*Which parts of the CEDET package do I want?
One symbol per part to be enabled.
Used by XEmacs, which needs many, many fugly hacks."
  :group 'dp-vars
  :type '(repeat (symbol :tag "CEDET component")))

(defcustom dp-activate-semantic-et-al-at-startup-p
  (and 
   (memq 'semantic 
	 dp-wants-xemacs-cedet-hacks-et-al-p)
   t)
  "*Do I want to activate the CEDET package when XEmacs starts?
Since it's XEmacs support is a bit lacking, I often want to make hacks before
it loads."
  :type 'boolean
  :group 'dp-vars)

(defcustom dp-activate-ede-at-startup-p
  (and (memq 'ede dp-wants-xemacs-cedet-hacks-et-al-p) t)
  "*Do I want to activate the EDE package when XEmacs starts?
Since its XEmacs support is a bit lacking, I often want to make hacks before
it loads."
  :type 'boolean
  :group 'dp-vars)

;;;
;;; Emms
;;;
(defcustom dp-wants-emms-p t ; XXX @todo change back to: t
  "*Should the Emacs Multimedia System be enabled?"
  :type 'boolean
  :group 'dp-vars)

(defcustom dp-wants-emms-started-at-startup-p t ; ibid t
  "*Should the Emacs Multimedia System be started?"
  :type 'boolean
  :group 'dp-vars)

(defcustom dp-emms-player-names
  '(emms-player-mpd) 
  "*Which music player(s) should emms use? 
For now (2010-05-22T08:26:49) I'm just using the symbols corresponding to the Emms support files so I can just `require' them in a loop. "
  :type '(repeat (symbol :tag "Emms player name"))
  :group 'dp-vars)

;;;
;;; C/C++
;;;
(defcustom dp-c*-insert-doxy-cmd-p nil
  "*Should an `indent-for-comment' command try to insert a logical doxygen command?"
  :type 'boolean
  :group 'dp-vars)

(defcustom dp-c*-doxy-command-prefix "!<"
  "That text with which introduces a doxygen command."
  :group 'dp-vars
  :type 'string)

(defcustom dp-global-c*-use-too-long-face t
  "*Use a special font lock pattern and face to highlight overlong lines."
  :type 'boolean
  :group 'dp-vars)

(defcustom dp-global-c*-use-too-long-warning-face t
  "*Use a special face to highlight lines as they are about to become
overlong."
  :type 'boolean
  :group 'dp-vars)

(defcustom dp-c-add-nl-after-open-paren-default-p t
  "*Should a newline be added after the open parenthesis of a function 
definition?.
This provides for uniform parameter indentation and maximum space for each
parameter. e.g
t:
int some_descriptive_function_name(
  int a,
  const char* some_string_for_some_arcane_purpose_which_is_too_complex,
  Some_arcane_type_t& for_some_even_more arcane_purpose)
{
  blah()
Lovely, isn't it?


And for vile, tasteless heathens, nil yields:
int some_descriptive_function_name(int a,
                                   const char* some_string_for_some_arcane_purpose_which_is_too_complex,
                                   Some_arcane_type_t& for_some_even_more arcane_purpose)
{
  blah()
An offense to the senses.
"
  :type 'boolean
  :group 'dp-vars)

(defcustom dp-use-dedicated-make-windows-p nil
  "*Shall we dedicated windows to compilation(make) buffers.
At one time it seemed like a good idea, but it's really become a PITA.
But it's also a PITA to have the window used for other files while looking
for compilation errors. In this case, I only want dedicated-ness to prevent
other-window functions to select it. Perhaps there's... another way."
  :type 'boolean
  :group 'dp-vars)
  

(defcustom dp-default-2-window-min-width 180
  "*Min width to allow splitting into 2 vertical windows."
  :group 'dp-vars
  :type 'integer)

(defcustom dp-default-2-window-min-height 150
  "*Min height to allow splitting into 2 horizontal windows."
  :group 'dp-vars
  :type 'integer)

(defcustom dp-2w-frame-width 180
  "Default frame width for 2w -- 2 vertical windows 80 columns wide.  
Also used by split window advice to determine when to force a horizontal
split."
  :group 'dp-vars
  :type 'integer)

(defcustom dp-dse-buffer-suffix-format "<dse/%d>"
  "Used to add identifying suffix to buffer name.
Can see it in the ibuffer and mode line, although the BG color tells us, too."
  :group 'dp-vars
  :type 'string)

(defcustom dp-dse-buffer-suffix-regexp "<dse/[0-9]+>"
  "How to ID a dse buffer name.
We need to add digits if we are dse'ing >1 file/buffer with the same name."
  :group 'dp-vars
  :type 'string)

(defcustom dp-dc-evaluator "dc"
  "Program to use to evaluate an RPN string.
dc(1) is assumed so anything else used needs must be compatible."
  :group 'dp-vars
  :type 'string)

;; <:new vars go here:>
(provide 'dp-vars)
;;
;;
