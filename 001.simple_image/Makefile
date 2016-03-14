FLOPPY=bin/image.adf
EXTRA=out/image-copper-list.s out/image.bin
IMAGEFILE=../assets/quake.png

MODULE=image.s

include ../shared/base.mk

$(EXTRA): $(IMAGECON) $(IMAGEFILE)
	$(IMAGECON) --input $(IMAGEFILE) --output out/image --colors 32 --quantize --output-bitplanes --output-copperlist
