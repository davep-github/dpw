.PHONY: all restart dump clean

FVWM_RC_FILES := \
	.fvwm2rc \
	bindings \
	decorations \
	functions \
	globalfeel \
	iconstyles \
	menus \
	modules \
	startup \
	styles

FVWM_RC_INFILES := $(addsuffix .in,$(FVWM_RC_FILES))

SED_CFG_FILE := defs.sed

all: rc_files

rc_files: $(SED_CFG_FILE) $(FVWM_RC_FILES)
	rm -rf last-gen
	mkdir last-gen
	mv $(FVWM_RC_FILES) last-gen
	cat $(SED_CFG_FILE) | sed-replace -d "$(DP_DOMAIN)" $(FVWM_RC_INFILES)
	chmod a-w $(FVWM_RC_FILES)

restart: all
	FvwmCommand Restart

clean:
	rm -f $(FVWM_RC_FILES)

dump:
	echo "FVWM_RC_FILES>$(FVWM_RC_FILES)<"
	echo "FVWM_RC_INFILES>$(FVWM_RC_INFILES)<"

# Don't work in quotes.
#cpp_bites_here_all: defs.h
#	for cfile in $(FVWM_RC_INFILES); do \
#		chmod u+w $$cfile ; \
#		cpp -I . $$cfile.in 2>/dev/null > $$cfile ; \
#		chmod a-w $$cfile ; \
#	done;
