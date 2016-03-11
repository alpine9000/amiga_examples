MODULE=dithered_ham.s
FLOPPY=bin/dithered_ham.adf
IMAGEDATA=out/image-palette.s out/image-ham.bin
IMAGEFILE=../assets/gigi_320x256.png
#IMAGEFILE=../assets/demo_320x256.png
EXTRA=$(IMAGEDATA) $(BOB_IMAGEDATA) init.s utils.s constants.i Makefile

USE_PALETTE=--use-palette gigi.pal
@USE_PALETTE=--use-palette demo.pal
#USE_PALETTE=--ham-brute-force
DITHER=--dither

include ../shared/base.mk

$(IMAGEDATA): $(IMAGECON) $(IMAGEFILE) Makefile
	$(IMAGECON) --input $(IMAGEFILE) --output out/image --ham --output-bitplanes  --output-palette-asm   $(USE_PALETTE) --output-palette $(DITHER)
