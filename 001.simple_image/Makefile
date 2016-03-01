MAKEADF=../tools/makeadf
FLOPPY=bin/image.adf
EXTRA=out/image-copper-list.s out/image.bin
IMAGEFILE=../assets/mission-beach.png

MODULE=image.s

include ../base.mk

$(EXTRA): $(IMAGECON) $(IMAGEFILE)
	$(IMAGECON) --input $(IMAGEFILE) --output out/image --colors 32
