NUM_COLORS=32
MODULE=ehb_mode.s
FLOPPY=bin/ehb_mode.adf
IMAGEDATA=out/image-palette.s out/image.bin
IMAGEFILE=../assets/gigi_full.png
SIZED_IMAGEFILE=out/image.png

EXTRA=$(IMAGEDATA) $(BOB_IMAGEDATA) init.s utils.s constants.i Makefile
VASM_EXTRA_ARGS=-DSCREEN_COLORS=$(NUM_COLORS)

ifeq ($(NUM_COLORS),64)
EXTRA_HALF_BRITE=--extra-half-brite
endif

include ../shared/base.mk

$(SIZED_IMAGEFILE): $(IMAGEFILE) $(RESIZE) Makefile
	$(RESIZE) --width=320 --height=256 --blur=0.75 --input=$(IMAGEFILE) --output=$(SIZED_IMAGEFILE)

$(IMAGEDATA): $(IMAGECON) $(SIZED_IMAGEFILE) $(SHARED_PALETTE) Makefile
	$(IMAGECON) --input $(SIZED_IMAGEFILE) --output out/image --output-bitplanes --output-grey-palette-asm --output-palette-asm --colors=32 --quantize $(EXTRA_HALF_BRITE)
