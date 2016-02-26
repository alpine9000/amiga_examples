MAKEADF=../tools/makeadf
FLOPPY=bin/image.adf
IMAGE_DATA=out/image-copper.s out/image-data.bin

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

out/main.o: image.s $(IMAGE_DATA)
	vc -c $< -o $@

out/main.bin: out/main.o
	vlink -brawbin1 $< -o $@

$(IMAGE_DATA): images/hello.png ../tools/bitplanify.py
	../tools/bitplanify.py images/hello.png  --copper $(IMAGE_DATA) 

clean:
	rm -rf out bin
