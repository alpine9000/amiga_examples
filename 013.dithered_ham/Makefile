MODULE=dithered_ham.s
FLOPPY=bin/dithered_ham.adf
IMAGEDATA=out/image-palette.s out/image-ham.bin
IMAGEFILE=../assets/gigi_full.png
@IMAGEFILE=../assets/demo_full.png
EXTRA=$(IMAGEDATA) $(BOB_IMAGEDATA) init.s utils.s constants.i Makefile
SIZED_IMAGEFILE=out/image.png

USE_PALETTE=--use-palette gigi.pal
#USE_PALETTE=--use-palette demo.pal
#USE_PALETTE=--ham-brute-force
DITHER=--dither

include ../shared/base.mk

$(SIZED_IMAGEFILE): $(IMAGEFILE) $(RESIZE) Makefile
	$(RESIZE) --width=320  --height=256 --blur=0.75 --input=$(IMAGEFILE) --output=$(SIZED_IMAGEFILE)

$(IMAGEDATA): $(IMAGECON) $(SIZED_IMAGEFILE) Makefile
	$(IMAGECON) --input $(SIZED_IMAGEFILE) --output out/image --ham --output-bitplanes  --output-palette-asm   $(USE_PALETTE) --output-palette $(DITHER)