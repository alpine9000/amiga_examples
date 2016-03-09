INTERLACE=1
MODULE=lace_mode.s
FLOPPY=bin/lace_mode.adf
IMAGEDATA=out/image-palette.s out/image-ham.bin
ifeq ($(INTERLACE),1)
IMAGEFILE=../assets/gigi_320x512.png
else
IMAGEFILE=../assets/gigi.png
endif
EXTRA=$(IMAGEDATA) $(BOB_IMAGEDATA) init.s utils.s constants.i Makefile
BASE_ADDRESS=40000   # The extra data in a 512 row bitplane dataset caused the original base (0x70000) to crash into something bad
VASM_EXTRA_ARGS=-DINTERLACE=$(INTERLACE)
USE_PALETTE=--use-palette gigi.pal
DITHER=--dither

include ../shared/base.mk

$(IMAGEDATA): $(IMAGECON) $(IMAGEFILE) Makefile
	$(IMAGECON) --input $(IMAGEFILE) --output out/image --ham --output-bitplanes  --output-palette-asm   $(USE_PALETTE) --output-palette $(DITHER)

