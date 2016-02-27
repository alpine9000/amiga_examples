MAKEADF=../tools/makeadf
FLOPPY=bin/music.adf
EXTRA=out/image-copper.s out/image-data.bin
MODULE=music.s

include ../base.mk

$(EXTRA): images/hello.png ../tools/bitplanify.py
	../tools/bitplanify.py images/hello.png  --copper $(EXTRA) 

