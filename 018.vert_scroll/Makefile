MODULE=vert_scroll.s
FLOPPY=bin/vert_scroll.adf
IMAGEDATA=out/image-palette.s out/image-ham.bin
IMAGEFILE=../assets/gigi_full.png
SIZED_IMAGEFILE=out/image.png

EXTRA=$(IMAGEDATA) init.s utils.s constants.i Makefile
BASE_ADDRESS=10000
DITHER=--dither

include ../shared/base.mk

$(SIZED_IMAGEFILE): $(IMAGEFILE) $(RESIZE) Makefile
	$(RESIZE) --width=320 --height=512 --blur=0.75 --input=$(IMAGEFILE) --output=$(SIZED_IMAGEFILE)

$(IMAGEDATA): $(IMAGECON) $(SIZED_IMAGEFILE) Makefile
	$(IMAGECON) --input $(SIZED_IMAGEFILE) --output out/image --colors 32 --output-bitplanes  --output-palette-asm   $(USE_PALETTE) --output-palette $(DITHER) --quantize


