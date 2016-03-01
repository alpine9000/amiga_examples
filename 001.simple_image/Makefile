MAKEADF=../tools/makeadf
FLOPPY=bin/image.adf
EXTRA=out/image-copper-list.s out/image.bin
IMAGEFILE=../assets/hello.png

MODULE=image.s

include ../base.mk

$(EXTRA): $(IMAGECON) $(IMAGEFILE)
	$(IMAGECON) $(IMAGEFILE) out/image
