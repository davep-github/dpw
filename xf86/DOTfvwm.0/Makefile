
FVWM_RC_FILES := \
	.fvwm2rc.in \
	bindings.in \
	decorations.in \
	functions.in \
	globalfeel.in \
	iconstyles.in \
	menus.in \
	modules.in \
	startup.in \
	styles.in

SED_CFG_FILE := defs.sed

all: $(SED_CFG_FILE)
	cat $(SED_CFG_FILE) | sed-replace $(FVWM_RC_FILES)



cpp_bites_here_all: defs.h
	for cfile in $(FVWM_RC_FILES); do \
		chmod u+w $$cfile ; \
		cpp -I . $$cfile.in 2>/dev/null > $$cfile ; \
		chmod a-w $$cfile ; \
	done;
