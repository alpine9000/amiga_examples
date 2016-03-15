
ifndef PLATFORM
PLATFORM := native
endif

ifneq ($(PLATFORM),$(filter $(PLATFORM),amiga windows-32 windows-64 native native-32 native-64))
DUMMY := $(error Unsupported platform $(PLATFORM))
endif

BUILD_DIR     := build/$(PLATFORM)
MKDIR_DUMMY   := $(shell mkdir -p $(BUILD_DIR))

all: $(BUILD_DIR)/Shrinkler

# Common flags
CFLAGS := -Wall -Wno-sign-compare
LFLAGS := -s

ifdef DEBUG
CFLAGS += -g -DDEBUG
LFLAGS :=
else
CFLAGS += -O3
endif

ifdef PROFILE
CFLAGS += -fno-inline -fno-inline-functions
LFLAGS :=
endif

ifeq ($(PLATFORM),amiga)

# Amiga build, using GCC and ixemul

TOOLCHAIN_DIR := toolchain
AMIGA_GCC_DIR := $(TOOLCHAIN_DIR)/GCC-4.5.0-m68k-amigaos-cygwin/usr/local/amiga
BINUTILS_DIR  := $(TOOLCHAIN_DIR)/amiga-binutils
INCLUDE_DIR   := $(TOOLCHAIN_DIR)/C++include/include
LIB_DIR1      := $(TOOLCHAIN_DIR)/C++include/lib
LIB_DIR2      := $(AMIGA_GCC_DIR)/lib/gcc/m68k-amigaos/4.5.0
LIB_DIR3      := $(TOOLCHAIN_DIR)/ixemul-sdk/lib

CC       := $(AMIGA_GCC_DIR)/bin/m68k-amigaos-g++
CFLAGS   += -m68000
INCLUDE  := -I $(INCLUDE_DIR)/c++/4.3.2 -I $(INCLUDE_DIR)/c++/4.3.2/m68k-amigaos -I $(INCLUDE_DIR)

ASM      := $(BINUTILS_DIR)/as
ASMFLAGS :=

LINK     := $(BINUTILS_DIR)/ld
STARTUP  := $(LIB_DIR3)/crt0.o
LIBS     := -L $(LIB_DIR1) -L $(LIB_DIR2) -L $(LIB_DIR3) -lstdc++ -lgcc -lc

$(BUILD_DIR)/%.o: %.cpp
	$(CC) $(CFLAGS) $(INCLUDE) $< -S -o $(@:%.o=%.s)
	$(ASM) $(ASMFLAGS) $(@:%.o=%.s) -o $@

else
ifeq ($(PLATFORM),windows-32)

# 32-bit MinGW build

CC       := i686-w64-mingw32-g++
LINK     := i686-w64-mingw32-g++
LFLAGS   += -static-libgcc -static-libstdc++

else
ifeq ($(PLATFORM),windows-64)

# 64-bit MinGW build

CC       := x86_64-w64-mingw32-g++
LINK     := x86_64-w64-mingw32-g++
LFLAGS   += -static-libgcc -static-libstdc++

else

# Native build

CC       := g++
LINK     := g++

ifeq ($(PLATFORM),native-32)
CFLAGS   += -m32
endif

ifeq ($(PLATFORM),native-64)
CFLAGS   += -m64
endif

endif
endif

# Common setup for non-Amiga builds

INCLUDE  :=
STARTUP  :=
LIBS     :=

$(BUILD_DIR)/%.o: %.cpp
	$(CC) $(CFLAGS) $(INCLUDE) $< -c -o $@

endif


$(BUILD_DIR)/Shrinkler.o: *.h Header1.dat Header1T.dat Header2.dat OverlapHeader.dat OverlapHeaderT.dat MiniHeader.dat

%.dat: %.bin
	python -c 'for b in open("$^", "rb").read(): print ("0x%02X," % ord(b)),' > $@

$(BUILD_DIR)/Shrinkler: $(BUILD_DIR)/Shrinkler.o
	$(LINK) $(LFLAGS) $(STARTUP) $< $(LIBS) -o $@

clean:
	rm -rf build
