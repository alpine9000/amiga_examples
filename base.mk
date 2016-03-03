MAKEADFDIR=../tools/makeadf/
MAKEADF=$(MAKEADFDIR)/out/makeadf
HOST_WARNINGS=-pedantic-errors -Wfatal-errors -Wall -Werror -Wextra -Wno-unused-parameter -Wshadow
HOST_CFLAGS=-g $(HOST_WARNINGS)
IMAGECONDIR=../tools/imagecon
IMAGECON=$(IMAGECONDIR)/out/imagecon

all: bin out $(MAKEADF) $(FLOPPY)

gdrive: all
	cp $(FLOPPY) ~/Google\ Drive

test: all
	cp $(FLOPPY) ~/Projects/amiga/test.adf

go: test
	 ~/Google\ Drive/Amiga/amiga500.sh

list:
	m68k-amigaos-objdump  -b binary --disassemble-all out/bootblock.bin -m m68k > out/bootblock.txt

bin:
	mkdir bin

out:
	mkdir out

$(IMAGECON):
	make -C $(IMAGECONDIR)

$(MAKEADF):
	make -C $(MAKEADFDIR)

$(FLOPPY): out/bootblock.bin
	$(MAKEADF) out/bootblock.bin > $(FLOPPY)

out/bootblock.bin: out/bootblock.o
	vlink -brawbin1 $< -o $@

out/bootblock.o: ../shared/bootblock.s out/main.bin
	vc -c $< -o $@

out/main.o: $(MODULE) $(EXTRA)
	@# -v
	@#vc -c $< -o $@
	@#-showopt -no-opt
	vasmm68k_mot -Fhunk -phxass -opt-fconst -nowarn=62 -quiet $< -o $@ -I/usr/local/amiga/os-include

out/main.bin: out/main.o $(EXTRAOBJS)
	@#-T ../link.script
	vlink -Ttext 0x70000 -brawbin1 $< $(EXTRAOBJS) -o $@

clean:
	rm -rf out bin *~
