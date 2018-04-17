# I don't want to use cmake(1) this time

DEFINES += -DHAVE_SYSLOG_H -DNDEBUG -DRAPIDJSON_SSE2 -DUNICODE -DXMRIG_NO_API -DXMRIG_NO_HTTPD -D_GNU_SOURCE -D__STDC_FORMAT_MACROS
INCLUDE_PATHS += -Isrc/3rdparty/libcpuid -Isrc -Isrc/3rdparty
CFLAGS += $(DEFINES) $(INCLUDE_PATHS) -Wall -O3
CXXFLAGS += $(DEFINES) $(INCLUDE_PATHS) -D_GLIBCXX_USE_NANOSLEEP -D_GLIBCXX_USE_SCHED_YIELD -Wall -fno-exceptions -maes -std=gnu++0x -O3 -DNDEBUG -funroll-loops -fvariable-expansion-in-unroller -fmerge-all-constants -fbranch-target-load-optimize2
CXXFLAGS += -Dnullptr=__null -Dconstexpr=const "-Dalignas(b)=" -Doverride= -fpermissive

SOURCES = \
    src/api/Api.cpp \
    src/api/ApiState.cpp \
    src/api/NetworkState.cpp \
    src/App.cpp \
    src/log/ConsoleLog.cpp \
    src/log/FileLog.cpp \
    src/log/Log.cpp \
    src/Mem.cpp \
    src/net/Client.cpp \
    src/net/Job.cpp \
    src/net/Network.cpp \
    src/net/strategies/DonateStrategy.cpp \
    src/net/strategies/FailoverStrategy.cpp \
    src/net/strategies/SinglePoolStrategy.cpp \
    src/net/SubmitResult.cpp \
    src/net/Url.cpp \
    src/Options.cpp \
    src/Platform.cpp \
    src/Summary.cpp \
    src/workers/DoubleWorker.cpp \
    src/workers/Handle.cpp \
    src/workers/Hashrate.cpp \
    src/workers/SingleWorker.cpp \
    src/workers/Worker.cpp \
    src/workers/Workers.cpp \
    src/xmrig.cpp

SOURCES += \
    src/crypto/c_keccak.c \
    src/crypto/c_groestl.c \
    src/crypto/c_blake256.c \
    src/crypto/c_jh.c \
    src/crypto/c_skein.c \
    src/crypto/CryptoNight.cpp

ifdef WIN32
SOURCES += \
        res/app.rc
        src/App_win.cpp \
        src/Cpu_win.cpp \
        src/Mem_win.cpp \
        src/Platform_win.cpp
LIBS += -lws2_32 -lpsapi -liphlpapi -luserenv
endif
ifdef APPLE
SOURCES += \
        src/App_unix.cpp \
        src/Cpu_mac.cpp \
        src/Mem_unix.cpp \
        src/Platform_mac.cpp

else
SOURCES += \
        src/App_unix.cpp \
        src/Cpu_unix.cpp \
        src/Mem_unix.cpp \
        src/Platform_unix.cpp
LIBS += -lpthread -lrt
endif

OBJECTS = $(SOURCES:%.cpp=%.o)
OBJECTS += $(SOURCES:%.c=%.o)

xmrig:	$(OBJECTS)
	$(CXX) $(LDFLAGS) $^ -o $@ $(LIBS)
