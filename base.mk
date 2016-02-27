all: bin out $(MAKEADF) $(FLOPPY)

gdrive: all
	cp $(FLOPPY) ~/Google\ Drive

test: all
	cp $(FLOPPY) ~/Projects/amiga/test.adf

go: test
	 ~/Google\ Drive/Amiga/amiga500.sh

bin:
	mkdir bin

out:
	mkdir out

$(MAKEADF): ../tools/makeadf.c
	gcc ../tools/makeadf.c -o $(MAKEADF)

$(FLOPPY): out/bootblock.bin
	$(MAKEADF) out/bootblock.bin > $(FLOPPY)

out/bootblock.bin: out/bootblock.o
	vlink -brawbin1 $< -o $@

out/bootblock.o: ../shared/bootblock.s out/main.bin
	vc -c $< -o $@

out/main.o: $(MODULE) $(EXTRA)
	vc -c $< -o $@

out/main.bin: out/main.o
	vlink -brawbin1 $< -o $@

clean:
	rm -rf out bin *~
