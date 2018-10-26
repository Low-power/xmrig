# I still don't want to use cmake(1)

DEFINES += -DHAVE_SYSLOG_H -DNDEBUG -DRAPIDJSON_SSE2 -DUNICODE -DXMRIG_NO_API -DXMRIG_NO_HTTPD -D_GNU_SOURCE -D__STDC_FORMAT_MACROS
# Linking to OpenSSL creates license issues, disable it for now
DEFINES += -DXMRIG_NO_TLS
INCLUDE_PATHS += -Isrc/3rdparty/libcpuid -Isrc -Isrc/3rdparty
CFLAGS += $(DEFINES) $(INCLUDE_PATHS) -Wall -O3
CXXFLAGS += $(DEFINES) $(INCLUDE_PATHS) -D_GLIBCXX_USE_NANOSLEEP -D_GLIBCXX_USE_SCHED_YIELD -Wall -fno-exceptions -maes -std=gnu++0x -O3 -DNDEBUG -funroll-loops -fvariable-expansion-in-unroller -fmerge-all-constants -fbranch-target-load-optimize2
#CXXFLAGS += -Dnullptr=__null -Dconstexpr=const "-Dalignas(b)=" -Doverride= -fpermissive
CXXFLAGS += "-Dalignas(b)=__attribute__((__aligned__))"
LIBS += -luv

SOURCES = \
    src/api/NetworkState.cpp \
    src/App.cpp \
    src/common/config/CommonConfig.cpp \
    src/common/config/ConfigLoader.cpp \
    src/common/config/ConfigWatcher.cpp \
    src/common/crypto/Algorithm.cpp \
    src/common/crypto/keccak.cpp \
    src/common/log/ConsoleLog.cpp \
    src/common/log/FileLog.cpp \
    src/common/log/Log.cpp \
    src/common/net/Client.cpp \
    src/common/net/Job.cpp \
    src/common/net/Pool.cpp \
    src/common/net/strategies/FailoverStrategy.cpp \
    src/common/net/strategies/SinglePoolStrategy.cpp \
    src/common/net/SubmitResult.cpp \
    src/common/Platform.cpp \
    src/core/Config.cpp \
    src/core/Controller.cpp \
    src/Mem.cpp \
    src/net/Network.cpp \
    src/net/strategies/DonateStrategy.cpp \
    src/Summary.cpp \
    src/workers/CpuThread.cpp \
    src/workers/Handle.cpp \
    src/workers/Hashrate.cpp \
    src/workers/MultiWorker.cpp \
    src/workers/Worker.cpp \
    src/workers/Workers.cpp \
    src/xmrig.cpp

SOURCES += \
    src/crypto/c_groestl.c \
    src/crypto/c_blake256.c \
    src/crypto/c_jh.c \
    src/crypto/c_skein.c

ifdef WIN32
SOURCES += \
        res/app.rc \
        src/App_win.cpp \
        src/common/Platform_win.cpp \
        src/Mem_win.cpp
LIBS += -lws2_32 -lpsapi -liphlpapi -luserenv
endif
ifdef APPLE
SOURCES += \
        src/App_unix.cpp \
        src/common/Platform_mac.cpp \
        src/Mem_unix.cpp
else
SOURCES += \
        src/App_unix.cpp \
        src/common/Platform_unix.cpp \
        src/Mem_unix.cpp
LIBS += -lpthread -lrt
endif

# Need for FreeBSD
#LIBS += -lkvm

ifdef WITH_ASM
SOURCES += src/crypto/Asm.cpp
ifdef WIN32
SOURCES += src/crypto/asm/win64/cnv2_main_loop.S
else
SOURCES += src/crypto/asm/cnv2_main_loop.S
endif
else
DEFINES += -DXMRIG_NO_ASM
endif	# WITH_ASM

ifdef WITH_LIBCPUID
SOURCES += src/core/cpu/AdvancedCpuInfo.cpp src/core/cpu/Cpu.cpp
LIBS += -lcpuid
else
DEFINES += -DXMRIG_NO_LIBCPUID
SOURCES += src/common/cpu/Cpu.cpp
ifeq ($(ARCH),arm)
SOURCES += src/common/cpu/BasicCpuInfo_arm.cpp
else
SOURCES += src/common/cpu/BasicCpuInfo.cpp
endif
endif

ifdef HAVE_SYSLOG
DEFINES += -DHAVE_SYSLOG_H
SOURCES += src/common/log/SysLog.cpp
endif

OBJECTS = $(addsuffix .o,$(basename $(SOURCES)))

xmrig:	$(OBJECTS)
	$(CXX) $(LDFLAGS) $^ -o $@ $(LIBS)

clean:
	rm -f $(OBJECTS)
