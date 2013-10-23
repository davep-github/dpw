
STATIC_LINK_FLAG = -Wl,-static
LFLAGS += $(STATIC_LINK_FLAG)

buf-tee: buf-tee.cxx
	$(CXX) $(UCXXFLAGS) -g -static -o obj/buf-tee buf-tee.cxx

eko: eko.c
	$(CXX) -o $@ $<
