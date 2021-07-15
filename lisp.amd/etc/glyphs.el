(defun dpj-setup-invisible-glyph (&optional file color)
  "Set up the glyph for dp-journal mode to use to indicate invisible text."
  (if file
      `[xpm :file ,file]
    `[xpm :data ,(format "\
/* XPM */
static char * delete_xpm[] = {
/* width height num_colors chars_per_pixel */
\"33 18 3 1\",
/* colors */
\" 	c white\",
\".	c none\",
\"X	c %s\",
/* pixels */
/*1...5....0....5....0....5....0...*/
\".................................\",
\".................................\",
\".................................\",
\"....XX ........XX ...............\",
\"....XXXX .....XX ................\",
\".....XXXX ...XX .................\",
\".......XXX .X ...................\",
\"........XXXXX ...................\",
\".........XXX ....................\",
\"........XXXXX ...................\",
\".......XXX .XX ..................\",
\"......XXX ...XX .................\",
\".....XXX .....X .................\",
\".....XXX ......X ..XXX..XXX..XXX.\",
\"......X ............XXX..XXX..XXX\",
\"................X ...X ...X ...X \",
\".................................\",
\".................................\"};" (or color "red"))
			 ]))

(defun dp-add-buffer-endicator2 (&optional file)
  "Add a glyph to denote EOF.
Copped from the XEmacs FAQ."
  (interactive)
  (let ((ext (make-extent (point-min) (point-max)))
	(graphic (if file
		     `[xpm :file ,file]
		   '[xpm :data "\
/* XPM */
static char * chuck_xpm[] = {
\"25 28 12 1\",
\" 	s None	c None\",
\".	c #FFFF65956595\",
\"X	c #CF3C30C230C2\",
\"o	c #820700000000\",
\"O	c black\",
\"+	c #659565956595\",
\"@	c #CF3CCF3C6595\",
\"#	c white\",
\"$	c #c0c0c0\",
\"%	c grey\",
\"&	c #30C265959A69\",
\"*	c blue\",
\"                         \",
\"        .X      .        \",
\"       .X       .o       \",
\"      ..Xo.OO   XXo      \",
\"      .X.XXXooOXXXO      \",
\"      .X+X@XXooXXOO      \",
\"      XX#$$XXooOOO       \",
\"      %O@O#XXOOOO        \",
\"      .OoO#XXoOO         \",
\"   @ O..O$$XXooO         \",
\"  @ @O.XXXXXoOOO         \",
\" @ @@XoX..XOooO          \",
\"  @@@XXXOOOooO           \",
\"    oX+XXOOooo           \",
\"     +@O@XXXXo           \",
\"     o.Oo.@oO+           \",
\"      ooO..@oO           \",
\"        O+oOOOo       Oo \",
\"        .OoOooO        o \",
\"        ..XXooOOo    ooo \",
\"       ..o.+XooOOooOoo   \",
\"      O.oO  XXoOO+       \",
\" ##@O@OOOO    OoO+O      \",
\" $#&&&&o*+    &*+O       \",
\"    &&*Oo&  ##&+O&       \",
\"     &&+&&%#%&&&&+       \",
\"          %&&&*+         \",
\"                         \"};"
			 ])))

    (set-extent-property ext 'start-closed t)
    (set-extent-property ext 'end-closed t)
    (set-extent-property ext 'detachable nil)
    (set-extent-property ext 'dp-buffer-endicator t) ; tag for identification
    (set-extent-end-glyph ext (make-glyph `( ,graphic
					    [string :data "[END]"])))
    (setq dp-buffer-endicator ext)
    ))

