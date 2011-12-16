#
# $Id: Makefile,v 1.18 2005/06/27 08:20:16 davep Exp $
#

.PHONY: al autoloads cl customloads gen generated_files gf af

# what emacs is called on your system
EMACS = xemacs

# How to make a directory
# need a -p if you want to make the parents!
MKDIR = mkdir

# Various other stuff used
RM    = rm -f
CP    = cp

# where the Info file should go
INFODIR = /usr/yokel/info

# where the lisp files should go
LISPDIR = $$HOME/lisp

# Change this to be where your .emacs file is stored
DOTEMACS      = $$HOME/.emacs

# Change this to be how to convert texinfo files into info files
# examples:
#	$(EMACS) -batch -q -f batch-texinfo-format
#	makeinfo
MAKEINFO      = makeinfo

TEMPFILE=bcomper.el

def_target: generated_files

############## no user servicable parts beyond this point ###################
# Have to preload a few things to get a nice clean compile

#DEPS = -l ../.emacs
DEPS = -l dp-deps.el

# compile with noninteractive and relatively clean environment
BATCHFLAGS = -batch -q -no-site-file

.el.elc:
	$(EMACS) $(BATCHFLAGS) $(DEPS) -f batch-byte-compile $<


#cc-mode.elc 
#sel-paste.elc

OBJECTS = \
	dpmisc.elc \
	dp-buffer-menu.elc \
	dp-cal.elc \
	dp-colorize-ifdefs.elc \
	dp-common-abbrevs.elc \
	dp-compat.elc \
	dp-debug.elc \
	dp-dict.elc \
	dp-dot-emacs.elc \
	dp-dot-mew.elc \
	dp-flyspell.elc \
	dp-fsf-early.elc \
	dp-fsf-fsf-compat.elc \
	dp-hooks.elc \
	dp-id-utils.elc \
	dp-ilisp.elc \
	dp-journal.elc \
	dp-makefile-mode.elc \
	dp-mew-config.elc \
	dp-mew.elc \
	dp-mail.elc \
	dp-mmm.elc \
	dp-sel2.elc \
	dp-shells.elc \
	dp-sudo-edit3.elc \
	dp-supercite.elc \
	dp-templates.elc \
	dp-xemacs-early.elc \
	dp-xemacs-fsf-compat.elc \
	dp-xemacs-late.elc \
	dpmacs.elc


SRCS := $(patsubst %.elc,%.el,$(OBJECTS))
Q_SRCS := $(subst dp,"dp,$(SRCS))
Q_SRCS := $(subst .el,.el",$(Q_SRCS))

first: generated_files

q:
	echo 'Q_SRCS>${Q_SRCS}<'


all:	$(OBJECTS) tags generated_files

elc: $(OBJECTS)

byte_recompile_directory_prep brdp rdp:
	rm -f $(OBJECTS)
	touch $(OBJECTS)
	sleep 2
	touch $(SRCS)

dpmisc.elc: dpmisc.el
dp-buffer-menu.elc: dp-buffer-menu.el
dp-cal.elc: dp-cal.el
dp-colorize-ifdefs.elc: dp-colorize-ifdefs.el
dp-common-abbrevs-orig.elc: dp-common-abbrevs-orig.el
dp-common-abbrevs.elc: dp-common-abbrevs.el
dp-compat.elc: dp-compat.el
dp-debug.elc: dp-debug.el
dp-dict.elc: dp-dict.el
dp-dot-emacs.elc: dp-dot-emacs.el
dp-dot-mew.elc: dp-dot-mew.el
dp-flyspell.elc: dp-flyspell.el
dp-fsf-early.elc: dp-fsf-early.el
dp-fsf-fsf-compat.elc: dp-fsf-fsf-compat.el
dp-hooks.elc: dp-hooks.el
dp-id-utils.elc: dp-id-utils.el
dp-ilisp.elc: dp-ilisp.el
dp-journal.elc: dp-journal.el
dp-mail.elc: dp-mail.el
dp-makefile-mode.elc: dp-makefile-mode.el
dp-mew-config.elc: dp-mew-config.el
dp-mew.elc: dp-mew.el
dp-mhe.elc: dp-mhe.el
dp-mmm.elc: dp-mmm.el
dp-sel2.elc: dp-sel2.el
dp-shells.elc: dp-shells.el
dp-sudo-edit3.elc: dp-sudo-edit3.el
dp-supercite.elc: dp-supercite.el
dp-templates.elc: dp-templates.el
dp-xemacs-early.elc: dp-xemacs-early.el
dp-xemacs-fsf-compat.elc: dp-xemacs-fsf-compat.el
dp-xemacs-late.elc: dp-xemacs-late.el
dpmacs.elc: dpmacs.el

bcomp-test.elc: bcomp-test.el

clean:
	$(RM) $(OBJECTS)
	$(RM) *~
	$(RM) TAGS

../.emacs.elc: ../.emacs
	$(EMACS) $(BATCHFLAGS) -f batch-byte-compile $<


tags:
	extagtree $(PWD)/dp*.el

# This runs with one invocation of xemacs.  That should be faster. 
el: $(TEMPFILE) dpmacs.el
	@echo 'Compiling EL files ... '
	@echo 'PLEASE IGNORE WARNINGS IF DISPLAYED. TAKE IT EASY!'
	$(EMACS) -batch -q -no-site-file -l ./$(TEMPFILE) -f ---compile
	@echo 'Compiling EL files of Mew ... done'

$(TEMPFILE) tf: $(OBJECTS)
	@echo '(setq load-path (cons "." load-path))' > $(TEMPFILE)
	@echo '(defun ---compile () (mapcar (function (lambda (x) (byte-compile-file x))) (list ${Q_SRCS} )))' >> $(TEMPFILE)

AUTOLOAD_PKG  = auto-dp
AUTOLOAD_FILE = $(AUTOLOAD_PKG)-autoloads.el
CUSTOM_LOAD_FILE = custom-load.el
GENERATED_FILES = $(AUTOLOAD_FILE) $(CUSTOM_LOAD_FILE)

CONTRIB = $(LISPDIR)/contrib

###$(CONTRIB)/hugs-mode.el
AUTOLOAD_FILES = $(LISPDIR)/dp*.el

autoloads al autos:
	rm -f $(AUTOLOAD_FILE)
	xemacs -batch -eval '(setq generated-autoload-file (concat "./" "$(AUTOLOAD_FILE)") autoload-package-name "$(AUTOLOAD_PKG)")' -f batch-update-autoloads $(AUTOLOAD_FILES)

# Older version(s) made an auto-autoloads.el file which had to be renamed.
#mv auto-autoloads.el $(AUTOLOAD_FILE)

customloads cl customs:
	rm -f $(CUSTOM_LOAD_FILE)
	xemacs -batch -l cus-dep.el -f Custom-make-dependencies $(LISPDIR)

aal generated_files gen gf gfs loads lds af alfs als: autoloads customloads

clean-generated-files clean-gens cgs:
	rm -f $(GENERATED_FILES)

