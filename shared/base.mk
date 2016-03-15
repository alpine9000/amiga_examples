MAKEADFDIR=../tools/makeadf/
MAKEADF=$(MAKEADFDIR)/out/makeadf
HOST_WARNINGS=-pedantic-errors -Wfatal-errors -Wall -Werror -Wextra -Wno-unused-parameter -Wshadow
HOST_CFLAGS=$(HOST_WARNINGS)
IMAGECONDIR=../tools/imagecon
IMAGECON=$(IMAGECONDIR)/out/imagecon
RESIZEDIR=../tools/resize
RESIZE=$(RESIZEDIR)/out/resize
A500_RUN_SCRIPT=~/Google\ Drive/Amiga/amiga500.sh
A600_RUN_SCRIPT=~/Google\ Drive/Amiga/amiga600.sh
ifndef BASE_ADDRESS
BASE_ADDRESS=70000
endif

ifndef RUN_SCRIPT
RUN_SCRIPT=$(A500_RUN_SCRIPT)
endif

ifndef BOOTBLOCK_ASM
BOOTBLOCK_ASM=../shared/bootblock.s
endif

ifndef PROGRAM_BIN
PROGRAM_BIN=out/main.bin
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
	@# -v
	@#vc -c $< -o $@
	@#-showopt -no-opt
	vasmm68k_mot $(VASM_EXTRA_ARGS) -Fhunk -phxass -opt-fconst -nowarn=62 -quiet $< -o $@ -I/usr/local/amiga/os-include

out/main.bin: out/main.o $(EXTRAOBJS)
	@#-T ../link.script
	vlink -Ttext 0x$(BASE_ADDRESS) -brawbin1 $< $(EXTRAOBJS) -o $@

clean:
	rm -rf out bin *~
