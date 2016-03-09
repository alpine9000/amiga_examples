MODULE=lace_mode.s
FLOPPY=bin/lace_mode.adf
IMAGEDATA=out/image-palette.s out/image-ham.bin
IMAGEFILE=../assets/gigi_320x512.png
EXTRA=$(IMAGEDATA) $(BOB_IMAGEDATA) init.s utils.s constants.i Makefile
BASE_ADDRESS=40000

USE_PALETTE=--use-palette gigi.pal
DITHER=--dither

include ../shared/base.mk

$(IMAGEDATA): $(IMAGECON) $(IMAGEFILE) Makefile
	$(IMAGECON) --input $(IMAGEFILE) --output out/image --ham --output-bitplanes  --output-palette-asm   $(USE_PALETTE) --output-palette $(DITHER)

