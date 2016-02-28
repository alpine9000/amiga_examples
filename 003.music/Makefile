MAKEADF=../tools/makeadf
FLOPPY=bin/music.adf
EXTRA=out/image-copper.s out/image-data.bin
MODULE=music.s

include ../base.mk


$(EXTRA): ../assets/hello.png ../tools/bitplanify.py
	../tools/bitplanify.py ../assets/hello.png  --copper $(EXTRA) 
