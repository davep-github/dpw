#############################################################################
# <:lisp:>
#
CORE_LISP_FILES := \
	lisp/*.el \
	lisp/Makefile
LISP_FILES := \
	$(CORE_LISP_FILES)
LISP_PARENT := $(HOME)
LISP_DEST := $(HOME)/inb
ifndef LISP_PREFIX
#LISP_PREFIX := $(addsuffix $(suffix $(LISP_PARENT)), $(notdir $(LISP_PARENT)))
LISP_PREFIX := $(shell namify-path -s '%' $(LISP_PARENT)/)
endif

mk_archive_name := $(LISP_DEST)/$(HOST)%$(LISP_PREFIX)mylisp.tar.$(ZIP_EXT)
archive_name := $(call mk_archive_name)

mylisp:
	echo "LISP_PARENT: $(LISP_PARENT)"
	echo "LISP_PREFIX: $(LISP_PREFIX)"
	echo "sld>$(sld)<"
	(cd $(LISP_PARENT) && \
	  (cd lisp && svn up ) && \
	   tar cvf - $(LISP_FILES) \
		| $(ZIPPER) $(ZIP_ARGS) \
		>| $(archive_name))
	@echo "archive_name>$(archive_name)<"

LLLISP_PARENT=$(HOME)/lisp.d/to-ll
lllisp:
	echo "LLLISP_PARENT: $(LLLISP_PARENT)"
	$(MAKE) LISP_PARENT=$(LLLISP_PARENT) mylisp

VLISP_PARENT=$(HOME)
vlisp:
	echo "VLISP_PARENT: $(VLISP_PARENT)"
	echo "BN: $(BN)"
	echo "BS: $(BS)"
	$(MAKE) LISP_PARENT=$(VLISP_PARENT) mylisp

mylisptest:
	echo "( cd $(LISP_PARENT) ; tar cvf - $(LISP_FILES) \
		| $(ZIPPER) $(ZIP_ARGS) \
		>| $(archive_name))"

mylisp.zip:
	( cd $(HOME) ; $(ZZIPPER) mylisp.$(ZZIP_EXT) $(LISP_FILES) )

core-lisp: 
	( cd $(HOME) ; tar cvf - $(CORE_LISP_FILES) \
		| $(ZIPPER) $(ZIP_ARGS) >| my-core-lisp.tar.$(ZIP_EXT))

mylisp.tgz:
	( cd $(HOME) ; tar cvf - $(LISP_FILES) | gzip -c >| ~/inb/$(HOST)-mylisp.tar.gz)

svnup:
	( echo "PATH>$(PATH)"; cd $(HOME)/lisp; svn up )
