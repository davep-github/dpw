;;;
;;; !<@todo XXX Move any generic fsf-compat functions to
;;; dp-xemacs-fsf-compat.el

(defvar dp-semantic-enabled-file-name-p-pred-list
  (list (paths-construct-path (list dp-$HOME-truename "projects" ""))
        "/work")
  "List of predicates, any one of which will enable Semantic in a buffer if
  it returns non-nil.
We use default by default style, this overrides it.")

(defun dp-semantic-disable-non-work-paths (file-name)
  "An easy way to disable semantic for all non-work dirs."
  (not (dp-in-work-dir-p file-name)))

(defvar dp-semantic-disabled-file-name-p-pred-list
  '("phonebook.py$"
    (paths-construct-path (list dp-$HOME-tr "bin" "")) ; "" gives trailing /
    (paths-construct-path (list dp-$HOME-tr "etc" ""))
    dp-semantic-disable-non-work-paths)
  "List of predicates, any one of which will disable Semantic in a buffer if
  it evaluates to non-nil.
This needs to interact with the enable function.
For now it'll be: if disabled, it's disabled.
But something like if enabled but not by default then disable.")


(defvar dp-semantic-files
  '(semantic-adebug
    semantic-analyze-complete
    semantic-analyze-debug
    semantic-analyze
    semantic-analyze-fcn
    semantic-analyze-refs
    semantic-ast
    semantic-chart
    semantic-complete
    semantic-ctxt
    semanticdb-debug
    semanticdb-ebrowse
    semanticdb
    semanticdb-el
    semanticdb-file
    semanticdb-find
    semanticdb-global
    semanticdb-mode
    semanticdb-ref
    semanticdb-search
    semanticdb-typecache
    semantic-debug
    semantic-decorate
    semantic-decorate-include
    semantic-decorate-mode
    semantic-dep
    semantic-doc
    ;;??; semantic-ede-grammar
    semantic-edit
    semantic
    semantic-elp
    semantic-example
    semantic-find
    semantic-format
    semantic-fw
    semantic-grammar
    semantic-grammar-wy
    semantic-html
    semantic-ia
    semantic-ia-sb
    semantic-ia-utest
    semantic-idle
    semantic-imenu
    semantic-lex
    semantic-lex-spp
    semantic-loaddefs
    semantic-load
    semantic-mru-bookmark
    semantic-regtest
    semantic-sb
    semantic-scope
    semantic-sort
    semantic-tag
    semantic-tag-file
    semantic-tag-ls
    semantic-tag-write
    semantic-texi
    semantic-utest-c
    semantic-util
    semantic-util-modes
    senator))

(defvar dp-semantic-long-distance-runarounds
  '(semantic-complete-jump
    semantic-complete-jump-local
    senator-next-tag
    senator-previous-tag
    senator-go-to-up-reference)
  "Functions that move point enough to warrant a `dp-push-go-back'.
Each can be a symbol or a list.
When element is a list, it looks thus:
\(func-sym [doc [reason]]).
DOC is the docstring for the advice.
For REASON, see `dp-push-go-back'.")

(defun dp-advise-long-distance-runarounds (&optional movers)
  (interactive)
  (setq-ifnil movers dp-semantic-long-distance-runarounds)
  (loop for m in movers
    do (progn
         (unless (listp m)
           (setq m (list m)))
         (dp-advise-for-go-back (nth 0 m) (nth 1 m) (nth 2 m)))))

(defun* dp-semantic-en/dis-abled-p (pred
                                    &optional file-name
                                    (verbose-p nil))
  "Return result of PRED applied to FILE-NAME.
PRED can be:
t --> t
string holding regex
a symbol referring to a function
OR a list of the above."
  (when verbose-p
    (dmessage "enter: dp-semantic->%s<-file-p(%s, pred: %s)"
              verbose-p buffer-file-truename pred))
  (setq file-name (if file-name
                      (expand-file-name file-name)
                    buffer-file-truename))
  (when verbose-p
    (dmessage "dp-semantic->%s<-abled-p(%s, pred: %s)"
              verbose-p buffer-file-truename pred))
  (let ((abled?
         (cond
          ;; Always ON
          ((eq pred t)
           (prog1
               file-name
             (when verbose-p
               (dmessage "Semantic forced %s for %s" verbose-p file-name))))
          ;; Does FILE-NAME match regexp string?
          ((stringp pred)
           (string-match pred file-name))
          ;; `dp-semantic-en/dis-abled-file-name-p-pred' can also be a list.
          ;; Recurse for each element until one returns non-nil or all items
          ;; have been tested.
          ;; It also handles, indirectly via recursion, the auto-*-alist
          ;; functionality.
          ((and pred (listp pred))
           (let ((pred pred)
                 ret)
             (while (and pred (not ret))
               ;; Call ourselves recursively when we're a non-nil list.
               (setq ret (dp-semantic-en/dis-abled-p (car pred)
                                                     file-name verbose-p)
                     pred (cdr pred)))
             ret))
          ;; Element is `fboundp'.  Call it and return its results.
          ((fboundp pred)
           (let ((msg "Semantic %s")
                 (state "Unknown")
                 (ret (if (funcall 'pred file-name verbose-p)
                          (prog1 file-name
                            (setq state "on"))
                        (prog1 nil
                          (setq state "off")))))
             (when verbose-p
               (message msg (concat verbose-p ": " state " for: " file-name)))
             ret))
          ;; Default.  We don't understand the predicate so assume it is nil.
          (t
           (when verbose-p
             (message "dp-semantic->%s<-file-name-p(%s): %s by cond default."
                      verbose-p verbose-p file-name))
           nil)))
        (msg (format "file-name %s is" file-name)))
    (when verbose-p
      (message "dp-semantic->%s<-abled-p(%s): %s %s."
               verbose-p file-name
               (if abled? "is" "IS NOT")
               verbose-p))
    abled?))

(defun* dp-semantic-en/dis-abled-file-name-p (&optional file-name
                                              (verbose-p nil vsetp)
                                              enable-pred disable-pred)
  (setq-ifnil enable-pred dp-semantic-enabled-file-name-p-pred-list
              disable-pred dp-semantic-disabled-file-name-p-pred-list)
  ;; Enable pred allow us to disable things that otherwise would be disabled
  ;; by a broad disable predicate E.g I don't want all stuff in my home dir
  ;; to be cedet'ed but it's a PITA to list all of the disabled ones, so I
  ;; use a broad disable overridden by a more specific enable.  Eg more
  ;; specific: disable /home/davep except /home/davep/projects.
  ;; So:
  ;; !<@todo XXX No, I don't know what is best so at this time, this seems
  ;; best, but I may wont to evolve it over time hence the todo

  (cond
   (t (dp-semantic-en/dis-abled-p enable-pred file-name
                                  (if vsetp
                                      verbose-p
                                    "ENABLED")))
   ((dp-semantic-en/dis-abled-p disable-pred file-name "ERRORERROR1")
   nil)
   ((dp-semantic-en/dis-abled-p enable-pred file-name "ERRORERROR2")
    t)
   (t nil)))

(dp-deflocal dp-cedet-semantic-inhibited-p 'unset
  "Have we played this game before?")

(defun* dp-semantic-inhibit-hook (&optional (verbose-p t))
  "Prevent Semantic from working on these files."
  (if (memq dp-cedet-semantic-inhibited-p '(t nil))
      (progn
        (message "short circuit: (%s): not an EDE project."
                 dir-name)
        dp-cedet-semantic-inhibited-p)
    (setq dp-cedet-semantic-inhibited-p
          (if dp-cedet-semantic-inhibited-p
              nil                       ; Not enabled.
            (when verbose-p
              (message "enter dp-semantic-inhibit-hook(%s)" buffer-file-truename))
            ;; My routines return an enabled state. (not) --> inhibit state.
            (let ((ret (not (dp-semantic-en/dis-abled-file-name-p))))
              (when verbose-p
                (if ret                 ; Enabled?
                    (message "dp-semantic-inhibit-hook returns: %s inhibited."
                             ret)
                  ;; Disabled
                  (message "dp-semantic-inhibit-hook returns: %s NOT inhibited."
                           buffer-file-truename))))))))

(defun dp-cedet-toggle-semantic-inhibit (&optional command-flag)
  "Toggle or set mode as per `dp-toggle-var'."
  (interactive "P")
  (dp-toggle-var command-flag 'dp-cedet-semantic-inhibited-p))

(dp-deflocal dp-cedet-ede-ignored-p 'unset
  "Have we played this game before?")

(defun dp-ede-project-ignore-hook (dir-name)
  "Which projects to ignore."
  ;; Ignore these projects...
  ;;;fixing; (not (dp-work-dir-name-p dir-name)))
  (if (memq dp-cedet-ede-ignored-p '(t nil))
      (progn
        (message "short circuit: (%s): not an EDE project."
                 dir-name)
        dp-cedet-ede-ignored-p
        )
    (setq dp-cedet-ede-ignored-p
          (if (not (dp-semantic-en/dis-abled-file-name-p dir-name))
              (progn
                (setq dp-cedet-ede-ignored-p t)
              (message "dp-ede-project-ignore-hook(%s): not an EDE project."
                       dir-name))
            (setq dp-cedet-ede-ignored-p nil)
            (message "dp-ede-project-ignore-hook(%s): OK." dir-name)
            nil))))

(defun dp-cedet-toggle-ede-ignore (&optional command-flag)
  "Toggle or set mode as per `dp-toggle-var'."
  (interactive "P")
  (dp-toggle-var command-flag 'dp-cedet-ede-ignored-p))


(add-hook 'dp-post-dpmacs-hook (lambda ()
                                (add-hook 'ede-project-ignore-hook
                                          'dp-ede-project-ignore-hook)))

(defconst dp-CEDET-EDE-root (dp-mk-dropping-dir "ede.d")
  "Root for droppings from CEDET's EDE project manager.")

(defconst dp-EDE-project-placeholder-cache-file
  (paths-construct-path '("projects-cache.ede") dp-CEDET-EDE-root)
  "EDE's Project Placeholder Cache File.")

(defconst dp-EDE-simple-save-directory
  (paths-construct-path '("simple.d") dp-CEDET-EDE-root))

(defconst dp-use-def-CEDET-distribution nil
  "Should we use the distribution's CEDET stuff, or some special version.
It's mainly an FSF Emacs tool and can need some XEmacs specific fixes. ")

(defun dp-mk-cedet-child (file-name)
  (dp-mk-contrib-site-pkg-child "cedet" file-name))

(defvar dp-ecb-root (dp-mk-contrib-pkg-child "ecb")
  "Where the ecb system lives.")

(defvar dp-cedet-root (dp-mk-contrib-site-pkg-child "cedet")
  "Where the cedet system lives.")

(defun dp-setup-ecb ()
  (interactive)
  (unless dp-use-def-CEDET-distribution
    (add-to-list 'load-path dp-ecb-root))
  (dp-setup-cedet)
  (dp-setup-semantic)
  (require 'ecb))

(defun dp-activate-ecb ()
  "Require and load ecb: the emacs class browser."
  (interactive)
  (dp-setup-ecb)
  (ecb-activate))

(defun dp-add-cedet-to-load-path ()
  (interactive)
  (unless dp-use-def-CEDET-distribution
    (dp-add-list-to-list 'load-path (paths-find-recursive-load-path
                                     (list dp-cedet-root) 1))))
;; --vs--
;;CO;     (loop for dir in '("cogre" "common" "ede" "eieio" "semantic" "speedbar" "") do
;;CO;       (add-to-list 'load-path (paths-construct-path (list dp-cedet-root dir))))
;;CO;     (add-to-list 'load-path "/home/davep/lisp/contrib/ecb")))

(defun dp-setup-semantic ()
  (interactive)
  (dp-setup-cedet)
  (add-hook 'semantic-init-hooks (lambda ()
                                   (imenu-add-to-menubar "TOKENS")))
  (setq semantic-load-turn-everything-on t)
  (load-file (dp-mk-cedet-child "semantic/semantic-load.el")))

(defun dp-setup-speedbar ()
  (interactive)
  (require 'semantic-sb)
  (dp-setup-semantic)
  (unless dp-use-def-CEDET-distribution
    (add-to-list 'load-path (dp-mk-cedet-child "speedbar")))
  (load-library "speedbar-loaddefs.el"))

; (defun speedbar ()
;   "Overly complex `speedbar' autoload."
;   (interactive)
;   (dp-setup-speedbar)
;   (call-interactively 'speedbar))

(defun dp-setup-eieio ()
  (interactive)
  (unless dp-use-def-CEDET-distribution
    (add-to-list 'load-path (dp-mk-cedet-child "eieio")))
  (require 'eieio-load))

(defun dp-setup-cedet (&optional really-do-this-p-symbol)
  (interactive)
  (dp-add-cedet-to-load-path)
  ;;  Nothing passed for really-do-this-p-symbol--> t for backward compatibility
  (when (or (eq really-do-this-p-symbol nil)
            (bound-and-true-p really-do-this-p-symbol))
    (unless dp-use-def-CEDET-distribution
      (load-file (dp-mk-cedet-child "common/cedet.el"))
      ;; This thing sets all kinds of bad info directories.
      ;; Filter them by keeping only those with a `dir' file in them.
      (set dp-info-path-var
           (dp-filter-dirs-by-file (symbol-value dp-info-path-var) "dir")))
    ;;(semantic-load-enable-excessive-code-helpers)
    ;;(semantic-load-enable-gaudy-code-helpers)
    ))

(defvar dp-ecb-root (dp-mk-site-package-lisp-dir "ecb")
  "Where the ecb system lives.")

;; `custom-set-variables' wants a list of these:
;;   (SYMBOL VALUE [NOW [REQUEST [COMMENT]]])

(defun dp-semantic-set-vars ()          ; <:set-vars:>
  (setq global-semantic-decoration-mode t
 	global-semantic-highlight-edits-mode nil
 	global-semantic-highlight-func-mode t
        ede-simple-save-directory dp-EDE-simple-save-directory
        ede-project-placeholder-cache-file dp-EDE-project-placeholder-cache-file
;;??; 	global-semantic-idle-completions-mode t
;;??; 	global-semantic-idle-scheduler-mode t
;;??; 	global-semantic-mru-bookmark-mode t
;;??; 	global-semantic-show-parser-state-mode nil
;;??; 	global-semantic-show-unmatched-syntax-mode nil
;;??; 	global-semantic-stickyfunc-mode nil
;;??; 	global-senator-minor-mode t
;;??;         semanticdb-default-file-name "semantic-tag.cache"
;;??; 	semanticdb-default-save-directory
;;??;         "/home/davep/droppings/editors/xemacs/semanticdb.d"
;;??;         semantic-decoration-styles
;;??;         '(("semantic-decoration-on-includes")
;;??;           ("semantic-decoration-on-protected-members" . t)
;;??;           ("semantic-decoration-on-private-members" . t)
;;??;           ("semantic-tag-boundary" . t))
;;??;         semantic-idle-scheduler-verbose-flag nil
;;??; 	semanticdb-global-mode t
        ))


;;CONFIGURE; 11.1 Semanticdb Tag Storage
;;CONFIGURE; ===========================

;;CONFIGURE; Once you have tables of tags parsed from your files, the default action
;;CONFIGURE; is to save them when Emacs exits.  You can control the file name and
;;CONFIGURE; directories where the caches are stored.

;;CONFIGURE;  -- Option: semanticdb-default-file-name
;;CONFIGURE;      File name of the semantic tag cache.

;;CONFIGURE;  -- Option: semanticdb-default-save-directory
;;CONFIGURE;      Directory name where semantic cache files are stored.  If this
;;CONFIGURE;      value is `nil', files are saved in the current directory.  If the
;;CONFIGURE;      value is a valid directory, then it overrides
;;CONFIGURE;      `semanticdb-default-file-name' and stores caches in a coded file
;;CONFIGURE;      name in this directory.

;;CONFIGURE;  -- Option: semanticdb-persistent-path
;;CONFIGURE;      List of valid paths that semanticdb will cache tags to.  When
;;CONFIGURE;      "global-semanticdb-minor-mode" is active, tag lists will be saved
;;CONFIGURE;      to disk when Emacs exits.  Not all directories will have tags that
;;CONFIGURE;      should be saved.  The value should be a list of valid paths.  A
;;CONFIGURE;      path can be a string, indicating a directory in which to save a
;;CONFIGURE;      variable.  An element in the list can also be a symbol.  Valid
;;CONFIGURE;      symbols are `never', which will disable any saving anywhere,
;;CONFIGURE;      `always', which enables saving everywhere, or `project', which
;;CONFIGURE;      enables saving in any directory that passes a list of predicates
;;CONFIGURE;      in `semanticdb-project-predicate-functions'.

;;CONFIGURE;  -- Variable: semanticdb-project-predicate-functions
;;CONFIGURE;      List of predicates to try that indicate a directory belongs to a
;;CONFIGURE;      project.  This list is used when `semanticdb-persistent-path'
;;CONFIGURE;      contains the value `'project'.  If the predicate list is `nil',
;;CONFIGURE;      then presume all paths are valid.

;;CONFIGURE;      Project Management software (such as EDE and JDE) should add their
;;CONFIGURE;      own predicates with "add-hook" to this variable, and semanticdb
;;CONFIGURE;      will save tag caches in directories controlled by them.

;;CONFIGURE;  -- Option: semanticdb-save-database-hooks
;;CONFIGURE;      Hooks run after a database is saved.  Each function is called with
;;CONFIGURE;      one argument, the object representing the database recently
;;CONFIGURE;      written.

(defvar dp-semantic-started-p nil)

(defun dp-require-all-semantic-requires ()
  "Seems like we need more than the loaddef files load.
So, out with the SPAS and load 'em all."
    (loop for req in dp-semantic-files
      do (require req)))

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;
(defun dp-semantic-start (&optional semantic-path)  ; <:start semantic:>
  (interactive)
  (when (fboundp 'dp-semantic-en/dis-abled-file-name-p)
    (add-hook 'semantic-inhibit-functions 'dp-semantic-inhibit-hook))
  (require 'dp-fsf-button-compat)
  (defface custom-button-pressed-face
    (custom-face-get-spec 'dp-journal-embedded-lisp-face)
    "Needed by cedet::senator."
    :group 'faces
    :group 'dp-faces)
  (let ((s-path (or semantic-path (dp-mk-cedet-child "semantic"))))
    (defadvice custom-autoload (before dp-ad-custom-autoload
                                (sym ld
                                     &rest compat-with-fsf)
                                activate)
      "Make a more FSF compatible version by allowing extra parameters.
This makes us less incompatible with some FSF-centric packages such as CEDET.")
    ;;
    ;; Semantic calls this via the alias `semantic-make-overlay'
    (defadvice make-extent (before dp-ad-make-extent
                            (from to
                                  &optional buffer-or-string
                                  &rest compat-with-fsf)
                            activate)
      "Make a more FSF compatible version by allowing extra parameters.
This makes us less incompatible with some FSF-centric packages such as CEDET.")

    (defadvice switch-to-buffer-other-window
      (before dp-ad-switch-to-buffer-other-window
       (buffer
        &rest compat-with-fsf)
       activate)
      "Make a more FSF compatible version by allowing extra parameters.
This makes us less incompatible with some FSF-centric packages such as CEDET.")

    (defun overlay-size (&rest rest)
      (apply 'extent-length rest))

    (defun minibufferp (&optional buffer)
      (flyspell-minibuffer-p (or buffer (current-buffer))))

    (defun hl-line-mode (&optional arg)
      (highline-local-mode 1))

    ;;
    ;;
    (dp-setup-cedet)
    (dp-semantic-set-vars)
    (dp-require-all-semantic-requires)
    (global-semanticdb-minor-mode 1)
    (setq semantic-load-turn-everything-on nil)
    (setq-default semantic-stickyfunc-mode nil
                  global-semantic-stickyfunc-mode nil)
    (load-file (expand-file-name "semantic-load.el" s-path))
    ;;    (require 'semantic-ref)
    (global-semantic-decoration-mode 1)
    ;; NB!  The ctags support requires, for some unknown fucking reason, that
    ;; the tags file be built in it's native mode, not it's etags compatible
    ;; mode.  ?? Does etags + exuberant mode allow this?  In any case, I'm
    ;; just building both kinds.  XEmacs' file is named TAGS (which is
    ;; dicklessly hardcoded) and Semantic's is named tags.  This allows both
    ;; to work.
    (semantic-load-enable-all-exuberent-ctags-support)
    (global-semantic-highlight-func-mode 1)
    (semantic-load-enable-code-helpers)
    (semantic-toggle-decoration-style
     "semantic-decoration-on-private-members" t)
    (semantic-toggle-decoration-style
     "semantic-decoration-on-protected-members" t)
    (semantic-load-enable-all-exuberent-ctags-support)
    ;; The `condition-case'-casing is done somewhere in the Semantic doc or
    ;; code.
    (condition-case appease-byte-compiler
        (progn
          (dmessage "dss: 0")
          (global-semantic-highlight-edits-mode 1)  ; Do I like this?
          (dmessage "dss: 0.0")
          (speedbar-change-initial-expansion-list "Analyze")
          (dmessage "dss: 1")
          (semantic-idle-summary-mode -1)
          (dmessage "dss: 2")
          (global-semantic-idle-summary-mode -1)
          (dmessage "dss: 3")
          (semantic-idle-completions-mode -1)
          (dmessage "dss: 4")
          (global-semantic-idle-completions-mode -1)
          (dmessage "dss: 5"))
      (error
       (warn "Something barfed in dp-semantic-start"))))
  (dp-advise-long-distance-runarounds)
  ;;(define-key km "\C-g" 'abort-recursive-edit)
  ;; Duplicate this onto (meta -) since it's such an ingrained habit.
  (define-key semantic-complete-key-map [(meta ?-)] 'abort-recursive-edit)
  (setq dp-semantic-started-p t))

(defvar dp-ede-started-p nil
  "`dp-ede-start' is in `dp-post-dpmacs-hook' but it doesn't seem to have any
  effect; or at least `global-ede-mode' doesn't seem to result in
  ede-minor-mode being active in semanticized buffers.  It doesn't look like
  anything after it can be overriding it.  There's only a possible call to
  `dp-EDE-setup-main-project` which, here at home where I'm seeing the
  problem is void.")
(defun dp-ede-start ()
  (interactive)
  (dp-setup-cedet)
  (require 'ede)
  (global-ede-mode 1)
  (setq dp-ede-started-p t))

(defun dp-semantic-symref-results-mode-hook ()
  (dp-define-local-keys '([return] push-button)))

(defun dp-senator-minor-mode-hook ()
  (interactive)
  (dp-define-keys senator-prefix-map
                  '([(meta ?/)] senator-complete-symbol
                    [(meta ?.)] semantic-complete-jump
                    [(control ?/)] semantic-analyze-proto-impl-toggle
                    ;; COGRE functions, but they fit in here.
                    [?h] cogre-uml-quick-class  ; Hierarchy.
                  )))

(when dp-activate-semantic-et-al-at-startup-p
  (add-hook 'dp-post-dpmacs-hook 'dp-semantic-start)
  (add-hook 'semantic-symref-results-mode-hook
            'dp-semantic-symref-results-mode-hook)
  (add-hook 'senator-minor-mode-hook 'dp-senator-minor-mode-hook))

(when dp-activate-ede-at-startup-p
  (add-hook 'dp-post-dpmacs-hook 'dp-ede-start t)
  (add-hook 'dp-post-dpmacs-hook
            (lambda ()
              (when (fboundp 'dp-EDE-setup-main-project)
                (dp-EDE-setup-main-project))) t))


(defun dp-cogre-mode-hook ()
  "Setup keys in the COGRE graph window/buffer."
  (dp-working... "dp-cogre-mode-hook..."
    t
    (dp-local-set-keys '([(meta down)] other-window
                         [(meta up)] dp-other-window-up
                         [?q] bury-buffer))))

(add-hook 'dp-post-dpmacs-hook
          (lambda ()
            (add-hook 'cogre-mode-hook 'dp-cogre-mode-hook)))

(defun dp-ede-make-hat-hook (ede-hat-hook)
  (interactive "Ffile-name: ")
  (if (file-exists-p ede-hat-hook)
      (find-file ede-hat-hook)
    ;; File does not exist.  Open using special new C/++ file template and
    ;; then save.
    (let ((dp-c++-new-source-file-template "#include <cstdio>
#include <iostream>

int
main(
  int argc,
  const char* argv[])
{
  // EDE (a part of the CEDET project) needs a file as a root for the project.
  // Why the fuck they can't use a directory name is beyond me.
}
"))
      (find-file ede-hat-hook)
      (set-buffer-modified-p t)
      (save-buffer)))
  (current-buffer))
(provide 'dp-cedet-hacks)
