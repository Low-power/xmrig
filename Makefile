# I still don't want to use cmake(1)

DEFINES += -DHAVE_SYSLOG_H -DNDEBUG -DRAPIDJSON_SSE2 -DUNICODE -DXMRIG_NO_API -DXMRIG_NO_HTTPD -D_GNU_SOURCE -D__STDC_FORMAT_MACROS
# Linking to OpenSSL creates license issues, disable it for now
DEFINES += -DXMRIG_NO_TLS
INCLUDE_PATHS += -Isrc/3rdparty/libcpuid -Isrc -Isrc/3rdparty
CFLAGS += $(DEFINES) $(INCLUDE_PATHS) -Wall -O3
CXXFLAGS += $(DEFINES) $(INCLUDE_PATHS) -D_GLIBCXX_USE_NANOSLEEP -D_GLIBCXX_USE_SCHED_YIELD -Wall -fno-exceptions -maes -std=gnu++0x -O3 -DNDEBUG -funroll-loops -fvariable-expansion-in-unroller -fmerge-all-constants -fbranch-target-load-optimize2
#CXXFLAGS += -Dnullptr=__null -Dconstexpr=const "-Dalignas(b)=" -Doverride= -fpermissive
CXXFLAGS += "-Dalignas(b)=__attribute__((__aligned__))"
LIBS += -l uv -l pthread

SOURCES = \
    src/base/io/json/Json.cpp \
    src/base/io/json/JsonChain.cpp \
    src/base/io/json/JsonRequest.cpp \
    src/base/io/log/backends/ConsoleLog.cpp \
    src/base/io/log/backends/FileLog.cpp \
    src/base/io/log/Log.cpp \
    src/base/io/Watcher.cpp \
    src/base/kernel/Base.cpp \
    src/base/kernel/config/BaseConfig.cpp \
    src/base/kernel/config/BaseTransform.cpp \
    src/base/kernel/Entry.cpp \
    src/base/kernel/Platform.cpp \
    src/base/kernel/Process.cpp \
    src/base/kernel/Signals.cpp \
    src/base/net/dns/Dns.cpp \
    src/base/net/dns/DnsRecord.cpp \
    src/base/net/http/Http.cpp \
    src/base/net/stratum/BaseClient.cpp \
    src/base/net/stratum/Client.cpp \
    src/base/net/stratum/Job.cpp \
    src/base/net/stratum/Pool.cpp \
    src/base/net/stratum/Pools.cpp \
    src/base/net/stratum/strategies/FailoverStrategy.cpp \
    src/base/net/stratum/strategies/SinglePoolStrategy.cpp \
    src/base/tools/Arguments.cpp \
    src/base/tools/Buffer.cpp \
    src/base/tools/String.cpp \
    src/base/tools/Timer.cpp

ifdef APPLE
SOURCES += \
        src/base/io/json/Json_unix.cpp \
        src/base/kernel/Platform_mac.cpp
else
SOURCES += \
        src/base/io/json/Json_unix.cpp \
        src/base/kernel//Platform_unix.cpp
endif

DEFINES += -D HAVE_SYSLOG_H=1
SOURCES += src/base/io/log/backends/SysLog.cpp

ifdef WITH_HTTP
SOURCES += \
        src/3rdparty/http-parser/http_parser.c \
        src/base/api/Api.cpp \
        src/base/api/Httpd.cpp \
        src/base/api/requests/ApiRequest.cpp \
        src/base/api/requests/HttpApiRequest.cpp \
        src/base/net/http/HttpApiResponse.cpp \
        src/base/net/http/HttpClient.cpp \
        src/base/net/http/HttpContext.cpp \
        src/base/net/http/HttpResponse.cpp \
        src/base/net/http/HttpServer.cpp \
        src/base/net/stratum/DaemonClient.cpp \
        src/base/net/tools/TcpServer.cpp

DEFINES += -D XMRIG_FEATURE_HTTP=1 -D XMRIG_FEATURE_API=1
endif

SOURCES += \
    src/backend/cpu/Cpu.cpp \
    src/backend/cpu/CpuBackend.cpp \
    src/backend/cpu/CpuConfig.cpp \
    src/backend/cpu/CpuLaunchData.h \
    src/backend/cpu/CpuThread.cpp \
    src/backend/cpu/CpuThreads.cpp \
    src/backend/cpu/CpuWorker.cpp

SOURCES += \
    src/backend/common/Hashrate.cpp \
    src/backend/common/Threads.cpp \
    src/backend/common/Worker.cpp \
    src/backend/common/Workers.cpp

SOURCES += \
    src/App.cpp \
    src/core/config/Config.cpp \
    src/core/config/ConfigTransform.cpp \
    src/core/Controller.cpp \
    src/core/Miner.cpp \
    src/net/JobResults.cpp \
    src/net/Network.cpp \
    src/net/NetworkState.cpp \
    src/net/strategies/DonateStrategy.cpp \
    src/Summary.cpp \
    src/xmrig.cpp

SOURCES += \
    src/crypto/cn/c_blake256.c \
    src/crypto/cn/c_groestl.c \
    src/crypto/cn/c_jh.c \
    src/crypto/cn/c_skein.c \
    src/crypto/cn/CnCtx.cpp \
    src/crypto/cn/CnHash.cpp \
    src/crypto/common/Algorithm.cpp \
    src/crypto/common/Coin.cpp \
    src/crypto/common/keccak.cpp \
    src/crypto/common/Nonce.cpp \
    src/crypto/common/VirtualMemory.cpp

SOURCES += \
	src/App_unix.cpp \
	src/crypto/common/VirtualMemory_unix.cpp

# Need for FreeBSD
#LIBS += -lkvm

ifdef WITH_ASM
DEFINES += -D XMRIG_FEATURE_ASM=1
SOURCES += \
	src/crypto/common/Assembly.cpp \
	src/crypto/cn/r/CryptonightR_gen.cpp
ifdef WIN32
SOURCES += \
	src/crypto/asm/win64/cnv2_main_loop.S
	src/crypto/cn/asm/CryptonightR_template.S
else
SOURCES += \
	src/crypto/asm/cnv2_main_loop.S \
	src/crypto/cn/asm/CryptonightR_template.S
endif
else
DEFINES += -D XMRIG_NO_ASM=1
endif	# WITH_ASM

ifdef WITH_LIBCPUID
DEFINES += -D XMRIG_FEATURE_LIBCPUID=1
SOURCES += src/backend/cpu/platform/AdvancedCpuInfo.cpp
#LIBS += -lcpuid
#DEPENDS += src/3rdparty/libcpuid/libcpuid.a
#LIBS += src/3rdparty/libcpuid/libcpuid.a
else
DEFINES += -D XMRIG_NO_LIBCPUID=1
#SOURCES += src/common/cpu/Cpu.cpp
ifeq ($(ARCH),arm)
SOURCES += src/backend/cpu/platform/BasicCpuInfo_arm.cpp
else
SOURCES += src/backend/cpu/platform/BasicCpuInfo.cpp
endif
endif

OBJECTS = $(addsuffix .o,$(basename $(SOURCES)))

xmrig:	$(OBJECTS) $(DEPENDS)
	$(CXX) $(LDFLAGS) $(OBJECTS) -o $@ $(LIBS)

clean:
	$(MAKE) -C src/3rdparty/libcpuid/ $@
	rm -f $(OBJECTS)

src/3rdparty/libcpuid/libcpuid.a:
	$(MAKE) -C src/3rdparty/libcpuid/
