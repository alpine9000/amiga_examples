INTERLACE=1
MODULE=lace_mode.s
FLOPPY=bin/lace_mode.adf
IMAGEDATA=out/image-palette.s out/image-ham.bin
IMAGEFILE=../assets/gigi_full.png
SIZED_IMAGEFILE=out/image.png

ifeq ($(INTERLACE),1)
FLAGS=--height=512 --interlaced
else
FLAGS=--height=256
endif

EXTRA=$(IMAGEDATA) $(BOB_IMAGEDATA) init.s utils.s constants.i Makefile
BASE_ADDRESS=40000
VASM_EXTRA_ARGS=-DINTERLACE=$(INTERLACE)
USE_PALETTE=--use-palette gigi.pal
#USE_PALETTE=--ham-brute-force --output-palette
DITHER=--dither

include ../shared/base.mk

$(SIZED_IMAGEFILE): $(IMAGEFILE) $(RESIZE) Makefile
	$(RESIZE) --width=320  $(FLAGS) --blur=0.75 --input=$(IMAGEFILE) --output=$(SIZED_IMAGEFILE)

$(IMAGEDATA): $(IMAGECON) $(SIZED_IMAGEFILE) Makefile
	$(IMAGECON) --input $(SIZED_IMAGEFILE) --output out/image --ham --output-bitplanes  --output-palette-asm   $(USE_PALETTE) --output-palette $(DITHER)


