MAKEADFDIR=../tools/makeadf/
MAKEADF=$(MAKEADFDIR)/out/makeadf
HOST_WARNINGS=-pedantic-errors -Wfatal-errors -Wall -Werror -Wextra -Wno-unused-parameter -Wshadow
HOST_CFLAGS=$(HOST_WARNINGS)
IMAGECONDIR=../tools/imagecon
IMAGECON=$(IMAGECONDIR)/out/imagecon
SHRINKLERDIR=../tools/external/shrinkler
SHRINKLEREXE=$(SHRINKLERDIR)/build/native/Shrinkler
RESIZEDIR=../tools/resize
RESIZE=$(RESIZEDIR)/out/resize
A500_RUN_SCRIPT=~/Google\ Drive/Amiga/amiga500.sh
A600_RUN_SCRIPT=~/Google\ Drive/Amiga/amiga600.sh

ifndef SHRINKLER
SHRINKLER=0
endif

ifndef BASE_ADDRESS
BASE_ADDRESS=70000
endif

ifndef DECOMPRESS_ADDRESS
DECOMPRESS_ADDRESS=10000
endif

ifndef RUN_SCRIPT
RUN_SCRIPT=$(A500_RUN_SCRIPT)
endif


ifeq ($(SHRINKLER),1)
BOOTBLOCK_ASM=../shared/shrinkler_bootblock.s
PROGRAM_BIN=out/shrunk.bin
VASM_EXTRA_BOOTBLOCK_ARGS=-DDECOMPRESS_ADDRESS="\$$$(DECOMPRESS_ADDRESS)" -DSHRINKLER=$(SHRINKLER)
else
BOOTBLOCK_ASM=../shared/bootblock.s
PROGRAM_BIN=out/main.bin
VASM_EXTRA_BOOTBLOCK_ARGS=
endif


all: bin out $(MAKEADF) $(FLOPPY)

gdrive: all
	cp $(FLOPPY) ~/Google\ Drive

test: all
	cp $(FLOPPY) ~/Projects/amiga/test.adf

go: test
	 $(RUN_SCRIPT)

list:
	m68k-amigaos-objdump  -b binary --disassemble-all out/bootblock.bin -m m68k > out/bootblock.txt

bin:
	mkdir bin

out:
	mkdir out

ic:
	make -C $(IMAGECONDIR)

$(IMAGECON):
	make -C $(IMAGECONDIR)

$(SHRINKLEREXE):
	make -C $(SHRINKLERDIR)

$(RESIZE):
	make -C $(RESIZEDIR)

$(MAKEADF):
	make -C $(MAKEADFDIR)

$(FLOPPY): out/bootblock.bin
	$(MAKEADF) out/bootblock.bin > $(FLOPPY)
	@ls -lh out/bootblock.bin
	@ls -lh $(FLOPPY)

out/bootblock.bin: out/bootblock.o
	vlink -brawbin1 $< -o $@

out/bootblock.o: $(BOOTBLOCK_ASM) $(PROGRAM_BIN)
	vasmm68k_mot $(VASM_EXTRA_BOOTBLOCK_ARGS) -DBASE_ADDRESS="\$$$(BASE_ADDRESS)" -Fhunk -phxass -opt-fconst -nowarn=62 -quiet $< -o $@ -I/usr/local/amiga/os-include

out/main.o: $(MODULE) $(EXTRA)
	vasmm68k_mot $(VASM_EXTRA_ARGS) -Fhunk -phxass -opt-fconst -nowarn=62 -quiet $< -o $@ -I/usr/local/amiga/os-include

out/%.o: %.s
	vasmm68k_mot $(VASM_EXTRA_ARGS) -Fhunk -phxass -opt-fconst -nowarn=62 -quiet $< -o $@ -I/usr/local/amiga/os-include

out/main.bin: out/main.o $(OBJS)
	@#-T ../link.script
	vlink -Ttext 0x$(BASE_ADDRESS) -brawbin1 $< $(OBJS) -o $@


out/shrunk.bin: $(SHRINKLER_EXE) out/main.bin
	$(SHRINKLEREXE) -d out/main.bin out/shrunk.bin

clean:
	rm -rf out bin *~
