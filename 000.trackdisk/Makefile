MAKEADF=../tools/makeadf
FLOPPY=bin/test.adf

all: bin out $(MAKEADF) $(FLOPPY)

gdrive: all
	cp $(FLOPPY) ~/Google\ Drive

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

out/bootblock.o: bootblock.s out/main.bin
	vc -c $< -o $@

out/main.o: main.s
	vc -c $< -o $@

out/main.bin: out/main.o
	vlink -brawbin1 $< -o $@

clean:
	rm -rf out bin
