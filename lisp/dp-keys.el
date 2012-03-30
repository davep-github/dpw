;;;
;;; $Id: dp-keys.el,v 1.72 2005/07/03 08:20:10 davep Exp $
;;;
;;; My general/global keybindings.
;;;

;;
;; use, e.g., (read-kbd-macro "C-c C-a")
;; to show key sequences.
;; Style notes:
;;\/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ \/ 
;; NB use ?x for char in key sequences so that it is easier to search for them.
;; ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

(eval-when-compile
  (require 'cl)
  (load "cl-macs"))

(require 'dp-deps)

(defun dp-define-keys (kmap keys)
  "Convenience function to bind a list of KEYS to KMAP.
KMAP is a keymap.
KEYS is a list: \(key def key2 def2 ...\)."
  (if kmap
      (loop for (key def) on keys by 'cddr 
        do (define-key kmap key def))     
    (dp-define-buffer-local-keys keys)))

(defun dp-define-local-keys (keys &optional no-error-p)
  "Call `dp-define-keys' passing KEYS using `current-local-map' as KMAP."
  (if (current-local-map)
      (dp-define-keys (current-local-map) keys)
    (unless no-error-p
      (error 'invalid-argument "No local keymap is defined."))))
  
;; Takes the place of:
;;reference; (define-prefix-command 'dp-kb-prefix t)
;;reference; (defvar dp-Ccd-map (symbol-function 'dp-kb-prefix)
;;reference; "Keymap for my dp-* commands.
;;reference; NB: C-dC-c is a prefix for C/C++ commands.
;;reference; NB: C-dc is a prefix for colorization commands.")
;; Combined becomes -->
(defun dp-define-key-submap (prefix-sym parent-map map-root-key-seq &rest keys)
  "Define a key submap under PARENT-MAP accessed by MAP-ROOT-KEY-SEQ.
Bind any keys in KEYS via `dp-define-keys'."
  (define-prefix-command prefix-sym)
  (let ((new-map (symbol-value prefix-sym)))
    (define-key parent-map map-root-key-seq prefix-sym)
    (when keys
      (dp-define-keys new-map keys))
    new-map))

(global-set-key [(control left)] 'backward-word)
(global-set-key [(control right)] 'forward-word)
(global-set-key [(control next)] 'dp-end-of-buffer)
(global-set-key [(control end)] 'dp-end-of-buffer)
(global-set-key [(end)] 'dp-brief-end)
(global-set-key [(control ?e)] 'dp-brief-end)
(global-set-key [home] 'dp-brief-home)
(global-set-key [(control ?a)] 'dp-brief-home)
(global-set-key [(control prior)] 'dp-beginning-of-buffer)
(global-set-key [(control home)] 'dp-beginning-of-buffer)
(global-set-key [(meta ?k)] 'dp-delete-to-end-of-line)
(global-set-key [(meta ?w)] 'save-buffer)
;; I've probably never used these bindings... probably not even to test.
;;(global-set-key [(control meta next)] 'end-of-buffer-other-window)
;;(global-set-key [(control meta prior)] 'beginning-of-buffer-other-window)
(global-set-key [(control meta next)] 'dp-other-frame)
(global-set-key [(control meta prior)] 'dp-other-frame-up)


(global-set-key [(control ?x) ?K] 'dp-find-function-on-key)
;;(global-set-key [(meta ?e)] 'find-file-at-point)
(global-set-key [(meta ?e)] 'dp-ffap)
(global-set-key [(control ?x) (control ?f)] 'find-file-at-point)
(global-set-key [(control ?x) (meta ?b)] 'dp-edit-corresponding-file)
(global-set-key [(control ?x) ?4 (meta ?b)] 'dp-edit-cf-other-window)

(global-set-key [(meta ?r)] 'insert-file)
(global-set-key [(control ?t)] 'dp-point-to-top)
(global-set-key [(control meta ?t)] 'dp-point-to-bottom)
(global-set-key [(control ?l)] 'dp-center-to-top)
(global-set-key [(control meta ?l)] 'dp-center-to-top-other-window)
(global-set-key [(meta ?a)] 'dp-toggle-mark)
(global-set-key "\C-x4\ee" 'ffap-other-window)
(global-set-key "\C-x8\ee" (kb-lambda 
                               (dp-2-vertical-windows-do-cmd 
                                'ffap-other-window)))
(global-set-key "\C-x8f" (kb-lambda 
                             (dp-2-vertical-windows-do-cmd 
                              'ffap-other-window)))
(global-set-key "\C-x8b" (kb-lambda 
                               (dp-2-vertical-windows-do-cmd
                                'dp-switch-to-buffer t)))
(global-set-key [(control ?x)(meta ?=)] 'dp-balance-horizontal-windows)
(global-set-key [kp-subtract] 'dp-kill-region)
(global-set-key "\C-w" 'dp-kill-region)
(global-set-key [(control meta ?w)] 'dp-kill-region-append)
(global-set-key [(control meta ?k)] (kb-lambda
                                        (dp-mark-to-end-of-line)
                                        (dp-kill-region-append)))
(global-set-key [(meta kp-subtract)] 'dp-kill-region-append)
(global-set-key [(kp-add)] 'dp-kill-ring-save)
(global-set-key [(control insert)] 'dp-kill-ring-save)
(global-set-key [(control meta insert)] 'dp-kill-ring-save-append)
(global-set-key [(meta kp-add)] 'dp-kill-ring-save-append)
(global-set-key [(meta ?o)] 'dp-kill-ring-save)
(global-set-key [(control meta ?o)] 'dp-kill-ring-save-append)
(global-set-key [(meta ?p)] 'dp-parenthesize-region)
(global-set-key [(meta backspace)] 'dp-delete-word)
(global-set-key [(control backspace)] 'dp-backward-delete-word)
(global-set-key [(control ?o)] 'dp-one-window++)
(global-set-key [(control ?x) ?1] 'dp-one-window++)
(global-set-key [(control ?x) ?t] 'dp-toggle-truncate)
(global-set-key [(meta delete)] 'dp-x-copy-to-kill-selection)

(if (boundp 'global-window-system-map)
    (define-key global-window-system-map "\C-z" 'dp-shell))
;; Yes, I used a VAX once.
(global-set-key "\C-z" 'dp-shell)
(global-set-key "\C-x4\C-z" 'dp-shell-other-window)
;; Rarely -- if ever -- used; so move it and take it's more comfortable
;; binding for something oft used.
(global-set-key [(control meta ?z)] 'zap-to-char)
(global-set-key [(meta ?z)] 'dp-shell-cycle-buffers)

(global-set-key "\C-cg" 'dp-gdb)

;;(global-set-key "\C-z" 'dp-lterm)

;; Tag keys now defined in dp-ptools.el
				 
(global-set-key [(meta ?b)] 'dp-buffer-menu)
(global-set-key [(control x) (control b)] 'dp-list-buffers)
(global-set-key [(meta ?h)] 'help-command)
(global-set-key [(meta h) (meta k)] 'dp-ff-key)
(global-set-key [(meta up)] 'dp-other-window-up)
(global-set-key [(meta down)] 'other-window)
(global-set-key [insert] 'dp-yank)
;;was a waste of a meta-<char>
;; Waaaay too many things usurp this key sequence.
;;(global-set-key [(control meta i)] 'overwrite-mode)
(global-set-key [(meta ?I)] 'overwrite-mode)
(global-set-key [(meta ?O)] 'overwrite-mode)
(global-set-key [(meta ?i)] 'tab-to-tab-stop)
(global-set-key [(meta ?d)] 'dp-delete-entire-line)
(global-set-key [(control delete)] 'kill-region)
;;;(global-set-key [(meta ?s)] 're-search-forward)
(global-set-key [delete] 'dp-delete)
(global-set-key "\C-d" 'dp-delete)
;; New versions, less goop.
(global-set-key [(control up)] 'dp-scroll-down)
(global-set-key [(control down)] 'dp-scroll-up)
(global-set-key [(control meta up)] 'dp-scroll-down-other-window)
(global-set-key [(control meta down)] 'dp-scroll-up-other-window)
;; I don't use the extra junk in my versions.
;; Ah, but I can't tag 'em as isearch-commands this way.
; (global-set-key [(control up)] (kb-lambda (scroll-down 1)))
; (global-set-key [(control down)] (kb-lambda (scroll-up 1)))

;;reassigned; (global-set-key [(control meta up)] (kb-lambda 
;;reassigned;                                         (dp-scroll-down nil 'half-page-p)))
;;reassigned; (global-set-key [(control meta down)] (kb-lambda 
;;reassigned;                                           (dp-scroll-up nil 'half-page-p)))
;; dipshit belkin kvm doesn't pass f7!
(global-set-key [f6] 'dp-toggle-kb-macro-def)
(global-set-key [f7] 'dp-toggle-kb-macro-def)
(global-set-key [f8] 'call-last-kbd-macro)
(global-set-key [f9] 'call-last-kbd-macro)
(global-set-key [(meta ?[)] 'dp-find-matching-paren)
(global-set-key [(meta ?])] 'dp-pop-go-back)
(global-set-key [(control meta ?])] 'dp-goto-last-edit)
(global-set-key [(meta -)] 'dp-maybe-kill-this-buffer)
(global-set-key [(control -)] 'negative-argument)
(global-set-key [(meta ?')] 'dp-dupe-chars-prev-line)
(global-set-key [(meta ?\")] 'dp-dupe-words-prev-line)
(global-set-key [(control x) (control \')] 'dp-copy-up-to-char)
(global-set-key [(control meta \;)] 'dp-fix-comment-and-move-down)

;; only bind this in places where it makes sense, like the minibuffer
;; anywhere else??? Seems useful everywhere.
(global-set-key [(control space)]  'dp-expand-abbrev)
(global-set-key [(meta ?g)] 'dp-goto-line)
(global-set-key [(meta ?n)] 'dp-next-error)
(global-set-key [(meta insert)] 'dp-sel2:paste)
(global-set-key [(control meta y)] 'dp-sel2:paste)
(global-set-key [(control meta space)] 'dp-one-space)

;;; retrain...
;;;(global-set-key [(control return)] 'join-line)
;;;(global-set-key  [(control return)] (kb-lambda (error "Use M-j!")))

(global-set-key [(meta return)] 'dp-open-newline)
(global-set-key [(control return)] 'dp-open-above)
;; imwheel key sequences from mouse.
;; C-M-( the ( confuzes the reader
;; ?? things were wierd under debian... do these work there?
;;(global-set-key [(control meta 40)] 'dp-scroll-down)
(global-set-key [(control meta ?\()] 'dp-scroll-down)
;; C-M-)
;;(global-set-key [(control meta 41)] 'dp-scroll-up)
(global-set-key [(control meta ?\))] 'dp-scroll-up)

(global-set-key [button4] 'dp-scroll-down)
(global-set-key [button5] 'dp-scroll-up)

;; cannot map these... get button[89] not defined.
;;;(global-set-key [button8] 'dp-scroll-down)
;;;(global-set-key [button9] 'dp-scroll-up)

;;(global-set-key [(control meta ?g] 'dp-sel2:bm)

(defvar dp-select-thing (if (fboundp 'id-select-thing)
                            'dp-id-select-thing
                          'dp-mark-sexp)
  "How we select sexps...  Or better.")
(fset 'dp-select-thing dp-select-thing)

(global-set-key [(shift tab)] 'dp-indent-line-and-move-down)
(global-set-key [(meta shift tab)] 'dp-delete-indentation-and-move-down)
(global-set-key [(control tab)] 'dp-one-tab)
(global-set-key [(control meta tab)] 'dp-phys-tab)
(global-set-key [(iso-left-tab)] 'dp-indent-line-and-move-down)
(global-set-key [(meta iso-left-tab)] 'dp-delete-indentation-and-move-down)
(global-set-key [(insert)] 'dp-yank)
(global-set-key [(meta y)] 'dp-yank)
(global-set-key [(control y)] 'yank-pop)
;; this works better with more X progs, aterm in particular.
(global-set-key [(shift insert)] 'dp-x-insert-selection)
(global-set-key [(meta m)] 'back-to-indentation)
(global-set-key [(meta space)] 'dp-select-thing) 
;; I've never really used it.  Give it a less comfortable binding and free up
;; a more comfortable one.
(global-set-key [(control meta space)] 'just-one-space)

; (global-set-key [(control meta m)] (if (fboundp 'id-select-thing)
; 					   'id-select-thing
; 					 'dp-mark-sexp))
; I always mark first
;;;(global-set-key [(control meta c)] 'dp-copy-sexp)
;;;(global-set-key [(control meta c)] 'dp-copy-rectangle-as-killed)
(global-set-key [(control x) r (meta o)] 'dp-copy-rectangle-as-killed)
(global-set-key [(meta c)] 'dp-toggle-capitalization)

;;(global-set-key [(control =)] 'dp-dump-char)
(global-set-key [(control =)] 'what-cursor-position)
(global-set-key [(meta j)] 'join-line)
(global-set-key [(meta ?9)] 'dp-insert-parentheses)
(global-set-key [(meta ?0)] 'up-list)
(global-set-key [(control meta ?0)] (kb-lambda
                                       (up-list)
                                       (newline-and-indent)))

(global-set-key [(control meta ?9)] 'down-list)

(global-set-key "\C-x4hi" (kb-lambda 
                              (when (one-window-p 'NOMINI)
                                (split-window))
                              (other-window 1)
                            (call-interactively 'info)))
(global-set-key [(control h) ?i] 'dp-info)
;;(global-set-key [(control x) 4 h (control m)] '2man)
(global-set-key "\C-x4h\C-m" '2man)
;;(global-set-key "\C-=" 'dp-what-cursor-position)
(global-set-key [(control ?=)] 'dp-what-cursor-position)
(global-set-key "\C-x5o" 'dp-other-frame)
(global-set-key "\C-x\C-q" 'dp-rw/ro-region)
;; Like my screen (1 )key sequence.  Kowtow to habits.
(global-set-key "\C-x\C-n" 'dp-switch-to-next-buffer)
(global-set-key "\C-x\C-p" 'dp-switch-to-previous-buffer)
(global-set-key [(control meta -)] 'delete-window)
(global-set-key [(control meta ?!)] 'dp-shell-command-in-minibuffer)

;;; <:add-new "normal"/global binding:>

;; Beginning to use C-cj as journal command prefix.
;; Prefer C-dj below.
;; Trying to put as much as possible on C-cd
;; XXX !<@todo make \C-cj its own map; like Ccd map.
(global-set-key "\C-cjd" 'dp-journal)	
(global-set-key "\C-cjj" 'dp-journal)	
(global-set-key "\C-cjc" 'dpj-new-topic)
(global-set-key "\C-cjb" 'dpj-mk-external-bookmark)

;; Beginning to use C-cC-d as dp-* command prefix.
;; dp prefixed keys; dp keys prefix; dp key prefix
;;!<@todo ?Sometimes? some of these keys don't get defined.
;;!<@todo `eval-defun` by hand works.

(defconst dp-Ccd-map
  (dp-define-key-submap 'dp-kb-prefix global-map
                        ;; Prefix for all keys in this map.
                        [(control c) ?d]
                        [(control next)] 'dp-eob-all-windows

                        [(control ?b)] 'dp-copy-breakpoint-command-as-kill
                        [(control ?/)] (kb-lambda 
                                           (setq display-buffer-function nil))
                        [(control ?f)] 'dp-face-at
                        [(meta ?c)] 'dp-id-select-and-copy-thing
                        [?b] 'dp-point-to-bottom

                        [(meta n)] (kb-lambda 
                                       (dp-goto-next-dp-extent-from-point '(4)))
                        [tab] (kb-lambda 
                                  (dp-goto-next-dp-extent-from-point '(4)))

                        [(control ?p)] 'dp-shell-resync-dirs
                        [(control ?r)] 'dp-rotate-windows
                        [(control ?s)] 'dp-find-or-create-sb
                        [(control ?v)] 'dp-symbol-info
                        [(control ?d)] 'dired ; For when I type the wrong thing
                        [(control ?e)] 'dp-embedded-lisp-eval@point
                        [(meta control ?x)] 'dp-embedded-lisp-eval@point
                        ;; Copying is more common than just selecting.
                        [?k] 'dp-copy-to-end-of-line 
                        [(control ?k)] 'dp-mark-to-end-of-line

                        [(control left)] 'dp-slide-window-left
                        [(control meta ?p)] 'dp-set-extent-priority
                        [(control ?q)] 'dp-rw/ro-region
                        [(control right)] 'dp-slide-window-right
                        [(meta ?-)] 'dp-maybe-kill-other-window-buffer
                        [(meta ?a)] 'dp-auto-it
                        [(meta ?v)] 'dp-show-variable-value-and-copy
                        [(meta \')] 'dp-dupe-n-chars-prev-line
                        [(meta \;)] 'dp-comment-out-sexp
                        [(meta ?p)] 'dp-parenthesize-region
                        [(meta ?s)] 'dp-try-to-fix-effin-isearch
                        ;; Use M-u since M-u is my `undo' binding.
                        [(meta ?u)] 'dp-undo-till-unmodified
                        [(meta ?x)] 'repeat-complex-command
                        [(shift tab)] 'dp-goto-next-dp-extent-from-point
                        [?e] 'dp-extents-at
                        [?G] 'dp-set-or-goto-bm
                        [?`] 'dp-bq-rest-of-line
                        [?f] 'dp-show-buffer-file-name
                        [?g] 'dp-sel2:bm
                        [?i] 'dp-ifdef-region
                        [?M] 'dp-edit-spec-macs
                        [?n] 'dp-goto-next-dp-extent-from-point
                        [?p] 'dp-python-shell
                        [?q] 'dp-calc-eval-region
                        [?r] 'dp-rotate-windows ; ?r make more sense w/new prefix
                        [?v] 'dp-show-variable-value
                        [?x] 'dp-cx-file-mode
                        [left] 'dp-shift-windows
                        [right] 'dp-shift-windows
                        [(control ?\\)] 'align

                        ;; <:add-new-ccd-bindings:>
                        )               ; Close paren for `dp-define-key-submap'
  "Keymap for my dp-* commands.
Submaps of this map are defined below.")

;;;(define-key dp-Ccd-map "\C-/" (kb-lambda (setq display-buffer-function nil)))

;; major-mode'ed temp buffers.
(defun dp-keys-define-init-submaps ()
  (defconst dp-temp-buffer-mode-map 
    (dp-define-key-submap 'dp-temp-buffer-mode-prefix dp-Ccd-map
                          ;; Key in parent map which accesses this map.
                          [?t]     
                          ;; List of bindings to define in this map.
                          [?c] 'dp-make-temp-c++-mode-buffer
                          [?t] 'dp-make-temp-text-mode-buffer
                          [?f] 'dp-make-temp-fundie-mode-buffer
                          [?p] 'dp-make-temp-python-mode-buffer
                          [?e] 'dp-make-temp-emacs-lisp-mode-buffer
                          [?i] 'dp-make-temp-lisp-interaction-mode-buffer
                          [?*] 'dp-make-temp-*mode-buffer
                          [??] 'dp-make-temp-*mode-buffer
                          [?.] 'dp-make-temp-*mode-buffer
                          [?=] 'dp-make-temp-*mode-buffer
                          [return] 'dp-make-temp-*mode-buffer
                          [(control ?m)] 'dp-make-temp-*mode-buffer)
    ;; <:cdd map temp buffer bindings:>
    "Keymap to control my major-mode'ed temp buffers.")
  
  ;; <:cdsS map:>
  (defconst dp-ssh-mode-map 
    (dp-define-key-submap 'dp-ssh-mode-prefix dp-Ccd-map 
                          [?S]     ; Key in parent map which accesses this map.
                          ;; Optional list of sequences
                          ;; to define.
                          ;; No relation to above.
                          [?s] 'dp-ssh)
    ;; <:cdd map ssh bindings:>
    "SSH function submap.")
  
  ;; <:cdss map:>
  (defconst dp-s-mode-map 
    (dp-define-key-submap 'dp-s-mode-prefix dp-Ccd-map
                          ;; Key in parent map which accesses this map.
                          [?s]     
                          ;; List of bindings to define in this map.
                          [?s] 'dp-search-path
                          [?S] 'dp-ssh)
    
    ;; <:cdd map s bindings:>
    "s function submap. ?s is just a key that had nothing on it.")

  ;; We'll set lots of aliases and see which stick with me.
  (defconst dp-space-mode-map
    (dp-define-key-submap 'dp-space-mode-prefix dp-Ccd-map
                          [? ] ;; Key in parent map which accesses this map.
                          ;; List of bindings to define in this map.
                          [?C] 'dp-whitespace-buffer-ask-to-cleanup
                          [?c] 'dp-whitespace-checker
                          [?w] 'dp-whitespace-checker
                          [(control ? )] 'dp-whitespace-cleanup-line-by-line
                          [(meta ? )] 'dp-whitespace-cleanup-buffer
                          [?i] 'dp-show-indentation
                          ;; shift tab cleans up whitespace now as well.
                          [?l] 'dp-whitespace-cleanup-line
                          [? ] 'dp-whitespace-next-and-cleanup
                          [?n] 'dp-whitespace-next-violation)
    ;; <:cdd map space bindings:>
    "[space] key function submap. Space map for whitespace type functions.
Hopefully [space] is mnemonic.")

  (defconst dp-J-mode-map 
    (dp-define-key-submap 'dp-J-mode-prefix dp-Ccd-map
                          ;; Key in parent map which accesses this map.
                          [?J]     ; Key in parent map which accesses this map.
                          ;; List of bindings to define in this map.
                          [?a] 'dp-jobs-adl-applied-for
                          [?m] 'dp-jobs-adl-mismatch
                          [?r] 'dp-jobs-adl-removed)
    ;; <:cdJ keymap Job (employment-wise) function:>
    "J[obs] function submap.")
  
  ;;
  ;;
  ;; My C/C++ mode bindings.
  ;;
  ;;CO; (define-prefix-command 'dp-c-mode-prefix)
  ;;CO; (defconst dp-c-mode-map dp-c-mode-prefix
  ;;CO;   "Keymap for my C/C++ mode commands.")
  ;;CO; (define-key dp-Ccd-map "\C-c" 'dp-c-mode-prefix)
  ;;CO; (define-key dp-c-mode-map [?a] 'dp-c-goto-access-label)
  ;;CO; (define-key dp-c-mode-map [?d] 'dp-insert-debugging-code-tag)
  (defconst dp-c-mode-map 
    (dp-define-key-submap 'dp-c-mode-prefix dp-Ccd-map 
                          ;; Key in parent map which accesses this map.
                          [(control ?c)]
                          ;; Mappings to define in this map
                          [?a] 'dp-c-goto-access-label
                          [?d] 'dp-insert-debugging-code-tag
                          )
    ;; <:cdd map cxx bindings:>
  "C<xx> mode key map.")
  
  ;;
  ;; Colorization stuff. <:color:>
  ;;
  (defconst dp-color-map
    (dp-define-key-submap 'dp-color-mode-prefix dp-Ccd-map
                          [?c]     ; Key in parent map which accesses this map.
                          [?c] 'dp-colorize-region
                          [(control ?c)] 'dp-colorize-pluck-color
                          [?m] 'dp-colorize-matching-lines
                          [(control ?s)] 
                          'dp-colorize-matching-lines-from-isearch
                          [?b] 'dp-colorize-bracketing-regexps
                          [?l] 'dp-colorize-region-line-by-line
                          [(control ?n)] 'dp-goto-next-colorized-region
                          ;; We'll consider invisible a color.
                          [?h] 'dp-hide-region
                          [(meta ?h)] 'dp-hide-excluding
                          [?s] 'dp-show-region
                          [?u] (kb-lambda
                                   (dp-uncolorize-region nil nil (C-u-p)))
                          [(meta u)] (kb-lambda
                                         (dp-uncolorize-region (point-min) 
                                                               (point-max)
                                                               nil (C-u-p)))
                          [?p] 'dp-set-colorized-extent-priority)
    ;; <:cdd map colorization bindings:>
    "My color mode keys.")
  
  ;;
  ;; Various extended yank commands.
  ;;
  (defconst dp-yank-map
    (dp-define-key-submap 'dp-yank-prefix dp-Ccd-map
                          [?y]     ; Key in parent map which accesses this map.
                          [?c] 'dp-insert-cwd
                          [(control ?s)] 'dp-insert-isearch-string)
    ;; <:cdd map yank bindings:>

    "Keymap for my extended yank commands.")
  
  ;;
  ;; Original key bindings map. <:original key bindings|orig:>
  ;;
  (defconst dp-original-bindings-map
    (dp-define-key-submap 'dp-original-bindings-prefix dp-Ccd-map [?O])
    "Keymap where I save a changed (aka mangled) key's original binding.
@todo Make a new function, say `dp-mangle-key-bindings', and use it for all
of my remapped keys.  Then, theorectally, all bindings will be available in
this map.  The function will put the old binding in the new map iff it's not
already in there.")
  
  ;;
  ;; Journal stuff.
  ;;
  (defconst dp-journal-map
    (dp-define-key-submap 'dp-journal-prefix dp-Ccd-map
                          [?j]
                          [?j] 'dp-journal
                          [?c] 'dpj-new-topic
                          [?b] 'dpj-mk-external-bookmark
                          [?i] 'dpj-insert
                          [?1] 'dpj-tidy-journals
                          [?o] 'dpj-outdent
                          [(iso-left-tab)] 'dpj-outdent
                          [?0] (kb-lambda
                                   (error "Use \C-dj1 my boy!."))
                          [?l] 'dpj-kill-link
                          [?J] 'dpj-'dpj-edit-journal-file)
    ;; <:cdd map journal bindings:>
    "Keymap for my journal commands.")
  
  ;;
  ;; Window management stuff.  Enough here to make it worthwhile?
  ;; Commands will be more intuitive and remomorable[sic].
  ;;
  (defconst dp-window-map
    (dp-define-key-submap 'dp-window-prefix dp-Ccd-map
                          [?w]
                          ;; Yeah, I should do a buncha submaps, but I won't.
                          ;; Nope.  I refuse. Not gun duit.  Read my lips: "No
                          ;; new mapses.
                          ;; Some of these bindings are longer than some
                          ;; abbreviated commands
                          [(control next)] 'dp-eob-all-windows
                          [(meta ?n)] 'dp-pop-window-config
                          [?s ?r] 'dp-save-wconfig-by-name-or-ring
                          [?s ?n] 'wconfig-add-by-name
                          [?r ?p] (kb-lambda-rest
                                      "Get by name if C--, else ring-pop."
                                      (call-interactively
                                       (if (Cu--p)
                                           'wconfig-restore-by-name
                                         'dp-pop-window-config)))
                          [?r ?n] 'wconfig-restore-by-name
                          [?r ?y] 'dp-pop-window-config
                          [?d ?p] 'wconfig-delete-pop
                          [?d ?n] 'wconfig-delete-by-name
                          ;; Bindings for some useful layouts.
                          ;; Try to pick some chars that look like or are
                          ;; otherwise mnemonic for the layout.
                          ;; "Point" at the split
                          [?<] 'dp-2+1-wins  ; |-| |
                          [?>] 'dp-1+2-wins  ; | |-|
                          ;; I hate shifting, and tags does it this way so
                          ;; pthrrrpppthhh!
                          [?,] 'dp-2+1-wins  ; |-| |
                          [?.] 'dp-1+2-wins  ; | |-|
                          ;; |-|
                          ;; | |
                          [?H] 'dp-2-over-1-wins
                          [?6] 'dp-2-over-1-wins  ; Shifting sucks.
                          [?y] 'dp-2-over-1-wins  ; Y has 2 over 1 strokes.
                          [?v] 'dp-2-over-1-wins
                          ;; | |
                          ;; |-|
                          ;; We need a lambda to mirror the ?y
                          [?h] 'dp-1-over-2-wins
                          [?^] 'dp-1-over-2-wins
                          ;; the mode line and scroll bars look like a t.
                          [?t] 'dp-1-over-2-wins
                          ;; |-|-|
                          [?+] 'dp-2x2-windows
                          [?=] 'dp-2x2-windows  ; unshifted +
                          [?4] 'dp-2x2-windows
                          ;; Kill HIM, Thunder. -- D.LoPan
                          [?q] 'dp-quit-other-window)
    ;; <:cdd map window bindings:>
    "Keymap for my window commands.")
  
    (defconst dp-dict-mode-map 
      (dp-define-key-submap 'dp-dict-mode-prefix dp-Ccd-map
                            ;; Key in parent map which accesses this map.
                            [?d]
                            [?s] 'dictionary-search
                            [?l] 'dictionary-lookup-definition
                            [?m] 'dictionary-match-words)
      ;; <:cdd map dictionary bindings:>
      "Keymap for dictionary commands.")

    (defconst dp-music-player-map
      (dp-define-key-submap 'dp-music-player-prefix dp-Ccd-map
                            ;; Key in parent map which accesses this map.
                            [?m]     
                            ;; List of bindings to define in this map.
                            [space] 'emms-player-mpd-pause
                            [?m] 'dp-emms-playlist-mode-go
                            [?l] 'emms-playlist-mode-go
                            ;; !<@todo XXX Configure emms to use mpd rather
                            ;; than calling the mpd stuff directly.
                            [?p] 'emms-player-mpd-pause  ; Really pause/play.
                            [up] 'emms-player-mpd-previous
                            [down] 'emms-player-mpd-next
                            [?i] 'emms-player-mpd-show
                            [?S] 'emms-player-mpd-stop
                            [?s] 'emms-player-mpd-start
                            ;; <: dp music player bindings :>
                            )
      "Keymap to control my music player. using MPD as of: 2010-05-21T17:45:13")
    
    ;;template;     <: insert new key submaps here template:>
    
;;template;     (defconst dp-<SOME-MODE>-map 
;;template;       (dp-define-key-submap 'dp-SOME-MODE-prefix dp-Ccd-map
;;template;                             ;; Key in parent map which accesses this map.
;;template;                             [?<MODE-PREFIX-KEY])
;;template;       "Keymap for <SOME-MODE> commands.")

)

;; !<@todo XXX change this? This works once because of the defconsts
(dp-keys-define-init-submaps)

;; This is, of course, remapped in a shell buffer.
(global-set-key [(control ?c) ?z] (kb-lambda (dp-kb-binding-moved arg 'dp-ssh)))
(global-set-key [(control ?c) (control ?g)] 
  (kb-lambda 
      (dp-kb-binding-moved arg 'dp-sel2:bm)))
(global-set-key [(control ?c) (control ?z)] 
  (kb-lambda 
      (dp-kb-binding-moved arg 'dp-python-shell)))
(global-set-key [(control meta n)] 
  (kb-lambda
      (dp-goto-next-dp-extent-from-point '(4))))
(global-set-key [(meta ?Q)] 'align)

;; ???
;; Last file name opened.
;; Current directory.
;; ? latest M-x (text of command)
;; ? latest rcc () (expr for command)


;; @todo These seem to need to be here (vs in the local cc-mode map).
;; When I put them in `dp-c-like-mode-common-hook', I couldn't use the other
;; C-cC-d commands (dp-*colorize-region), so for now I'll put them in the
;; global map.
;; @todo ??? Should I define C-cC-dc as my c-mode prefix?

(global-set-key [(control meta b)] 'dp-mk-external-file-link)
(global-set-key [(control x) (control ?`)] 'dp-bq)
(global-set-key [(control \\)] 'dp-embedded-lisp-eval@point)
(global-set-key [(control x) (meta n)] 'bury-buffer)

;;
;; replace binding to upcase-region with much more sensible 
;;  upcase-region-or-word 
;;  but only when available.
(defun dp-replace-binding (old new)
  "Find key sequence for definition OLD and set to NEW definition.
TODO: add prompting for functions analogous to `local-set-key' et.al."
  (let ((seq (where-is-internal old)))
    (when (and seq (fboundp new))
      (global-set-key (car seq) new)
      (message "binding %s to %s" (car seq) new))))

(defun dp-copy-key-binding (old-key-seq new-key-seq)
  "Find definition on OLD-KEY-SEQ and put on NEW-KEY-SEQ."
  (let ((defn (key-binding old-key-seq)))
    (local-set-key new-key-seq defn)))

(defun dp-bump-key-binding (key-seq new-def new-seq &optional keymap)
  "Copy binding for KEY-SEQ to NEW-SEQ and then bind KEY-SEQ to NEW-DEF.
This is NOT idempotent, so we skip if KEY-SEQ and NEW-DEF are bound."
  ;; Don't do this if new-seq and new-def are already bound.
  (setq-ifnil keymap (current-local-map))
  (if (equal new-def (key-binding key-seq))
      (message "new-def(%s) is already on key-seq(%s)"
               new-def key-seq)
    (dp-copy-key-binding key-seq new-seq)
    (define-key keymap key-seq new-def)))

(dp-replace-binding 'upcase-region 'upcase-region-or-word)
(dp-replace-binding 'downcase-region 'downcase-region-or-word)

;; or just force to C-xC-u???
(let ((seq (where-is-internal 'upcase-region)))
  (if (and seq (fboundp 'upcase-region-or-word))
      (global-set-key (car seq) 'upcase-region-or-word)))

;;
;; Slick-editor(ish)-style bookmark keys.
;; M-<digit> goes to the <digit>-th bookmark if it is set,
;; otherwise it sets the <digit>-th bookmark to (point)
;;
(defun dp-def-bm-key (digit)
  ;; M-<digit> set bm if unset, goto bm otherwise
  (global-set-key (format "\e%d" digit)
    `(lambda () 
        (interactive "_") (dp-set-or-goto-bm ,digit :reset nil)))
  ;; unconditionally set bm
  (global-set-key (read-kbd-macro (format "C-M-%d" digit))
    `(lambda () 
        (interactive "_") (dp-set-or-goto-bm ,digit :reset t))))

(dolist (key '(1 2 3 4 5 6 7 8))
  (dp-def-bm-key key))

;; With crappy Belkin KVM the
;; keyboard is a bit hosed.  left shift key is fubared, so
;; we make meta 9 and 0 generate parens.
;;(global-set-key [(meta ?9)] (kb-lambda (self-insert-internal ?()))
;;(global-set-key [(meta ?0)] (kb-lambda (self-insert-internal ?))))
;;(global-set-key [(meta ?0)] (kb-lambda (dp-set-or-goto-bm 1 :reset t)))

(global-set-key "\C-xb" 'dp-switch-to-buffer)
(global-set-key "\C-x4b" 'dp-switch-to-buffer-other-window)

(provide 'dp-keys)
