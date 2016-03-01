MAKEADF=../tools/makeadf
FLOPPY=bin/image.adf
EXTRA=out/image-copper-list.s out/image.bin
IMAGEFILE=../assets/hello.png

MODULE=music.s

include ../base.mk

$(EXTRA): $(IMAGECON) $(IMAGEFILE)
	$(IMAGECON) $(IMAGEFILE) out/image
