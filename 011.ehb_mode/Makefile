NUM_COLORS=64
MODULE=ehb_mode.s
FLOPPY=bin/ehb_mode.adf
IMAGEDATA=out/image-palette.s out/image.bin
IMAGEFILE=../assets/gigi.png
EXTRA=$(IMAGEDATA) $(BOB_IMAGEDATA) init.s utils.s constants.i Makefile
VASM_EXTRA_ARGS=-DSCREEN_COLORS=$(NUM_COLORS)

ifeq ($(NUM_COLORS),64)
EXTRA_HALF_BRITE=--extra-half-brite
endif

include ../shared/base.mk

$(IMAGEDATA): $(IMAGECON) $(IMAGEFILE) $(SHARED_PALETTE) Makefile
	$(IMAGECON) --input $(IMAGEFILE) --output out/image --output-bitplanes --output-grey-palette-asm --output-palette-asm --colors=32 --quantize $(EXTRA_HALF_BRITE)
