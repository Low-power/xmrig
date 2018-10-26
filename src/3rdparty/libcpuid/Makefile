CFLAGS += -DVERSION=\"0.4.0\" -Wall -Os

SOURCES = \
    cpuid_main.c \
    asm-bits.c \
    recog_amd.c \
    recog_intel.c \
    libcpuid_util.c

OBJECTS = $(addsuffix .o,$(basename $(SOURCES)))

libcpuid.a:	$(OBJECTS)
	$(AR) -r $@ $^

clean:
	rm -f $(OBJECTS) libcpuid.a
