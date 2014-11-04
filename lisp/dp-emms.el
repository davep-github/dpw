;; EMMS is not working during startup. Who is fubar?

;; EMMS setup
;; Add the following to your config.
(add-to-list 'load-path (dp-mk-contrib-subdir "emms"))
(setq emms-directory (expand-file-name "emms-data.d" dp-ephemeral-dir))
(if (not (dp-optionally-require 'emms-setup))
    (progn
      (defun dp-emms-setup ()
        "Could not `require' `emms-setup'."
        (interactive)
        ;; Closure really needed.
        ;; I hate `this or that' is broken, with no way tell which or what.
        (ding)
        (dmessage "The emms system enabled: %s; emms package present: %s."
                  dp-emms-enable-p (dp-optionally-require 'emms-setup)))
      (defun dp-emms-startup ()
        "Startup stub when emms not present."
        (message "The emms is not available for startup.")))
  (defun dp-emms-setup ()
    "Real `dp-emms-setup'. Sets up EMMS as I desire."
    (interactive)
    ;;(emms-standard)
    (emms-all)
    ;; Undo that which `emms-all' does that I like not.
    ;; ??? Better to call `emms-all' and undo what I don't want?
    ;; Or copy and trim `emms-all'.
      
    (emms-mode-line-blank)
    (emms-lyrics 0)
    (emms-playing-time 0)
    ;;(emms-devel)                      ; Latest features.
    (loop for player-name in dp-emms-player-names do
      (when (dp-optionally-require player-name)
        ;; To get track info from MusicPD, do the following.
        ;; !<@todo XXX The following must be a function of the player name.
        (add-to-list 'emms-info-functions 'emms-info-mpd)
        (add-to-list 'emms-player-list player-name)
        ;; If you use absolute file names in your m3u playlists (which is most
        ;; likely), make sure you set `emms-player-mpd-music-directory' to the
        ;; value of "music_directory" from your MusicPD config.  There are
        ;; additional options available as well, but the defaults should be
        ;; sufficient for most uses.
        (setq emms-player-mpd-music-directory (concat 
                                               (getenv "HOME") "/Music/")
              emms-playlist-buffer-name "*Mvsik*")))
      
    ;; You can set `emms-player-mpd-sync-playlist' to nil if your master
    ;; EMMS playlist contains only stored playlists.
      
    ;; If at any time you wish to replace the current EMMS playlist buffer
    ;; with the contents of the MusicPD playlist, type
    ;; M-x emms-player-mpd-connect.
      
    ;; Adjust `emms-player-mpd-server-name' and
    ;; `emms-player-mpd-server-port' to match the location and port of
    ;; your MusicPD server.
    (setq emms-player-mpd-server-name "localhost"
          emms-player-mpd-server-port "6600"
          emms-show-format "Now playing: %s"
          emms-mode-line-mode-line-function nil
          ;; Put the song name on the title bar only. 
          ;; It's too long for the mode line.
          ;; emms-mode-line-titlebar-function 'emms-mode-line-playlist-current
          emms-mode-line-titlebar-function nil
          ;; Looks like some mvsikal notes?
          ;;emms-mode-line-format "  q_q_ %s  _p_p" ;
          ;;emms-mode-line-format "  -=|[ %s ]|=- "
          emms-mode-line-format "   -- %s" ; Sometimes simple works best.
          ;;                    "12345678"
          )
    (add-hook 'emms-player-started-hook 'emms-show))
    
  (defun dp-emms-random-album (&optional arg)
    "Choose a random album."
    (interactive "P")
    (let ((args (if arg
                    (read-from-minibuffer "args: ")
                  "")))
      (shell-command-to-string (format "mpc-random-album %s" args))
      (emms-player-mpd-connect)))
  
  (defun dp-emms-startup ()
    "Start up the previously set up emms."
    (dp-emms-setup)
    (add-hook 'emms-playlist-mode-hook 'dp-emms-playlist-mode-hook)
    ;; Turn the mode-line off around our call to `emms-player-mpd-connect'
    (emms-mode-line 0) 
    (emms-player-mpd-connect)
    (emms-mode-line 1)))                ; "We need this to make it go." )

;; Keeping this out here gives us more control and makes debugging a bit
;; easier.
(when dp-wants-emms-started-at-startup-p
  ;; This can hose things if mpd isn't up.
(condition-case error-info
    (dp-emms-startup)
  (error "EMMS had start-up problems. Please try again later." )))

(defun dp-emms-playlist-mode-go ()
  (interactive)
  (emms-player-mpd-connect)
  (call-interactively 'emms-playlist-mode-go))
                          
;;
;; These are globally bound emms keys.
;; I don't think that global bindings should be context sensitive. So always
;; bind them regardless of emms' state. This will cause errors if emms is not
;; set up and started. A better thing would be to bind to something that
;; gives a clue as to what's up.
(global-set-key [(control meta ?m)] 'dp-emms-playlist-mode-go)
(global-set-key [(control meta ?p)] 'emms-player-mpd-pause)
(define-key emms-playlist-mode-map [?g] 'emms-player-mpd-connect)
(define-key emms-playlist-mode-map [?R] 'dp-emms-random-album)
;; Too many modes have good bindings for C-p
;;(global-set-key [(control ?p)] 'emms-player-mpd-pause)

(provide 'dp-emms)
