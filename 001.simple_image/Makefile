MAKEADF=../tools/makeadf
FLOPPY=bin/image.adf
EXTRA=out/image-copper.s out/image-data.bin

MODULE=image.s

include ../base.mk

$(EXTRA): ../assets/hello.png ../tools/bitplanify.py
	../tools/bitplanify.py ../assets/hello.png  --copper $(EXTRA) 

