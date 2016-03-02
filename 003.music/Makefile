FLOPPY=bin/music.adf
EXTRA=out/image-copper-list.s out/image.bin
IMAGEFILE=../assets/mission-beach.png

MODULE=music.s

include ../base.mk

$(EXTRA): $(IMAGECON) $(IMAGEFILE)
	$(IMAGECON) --input $(IMAGEFILE) --output out/image --colors 32 --quantize
