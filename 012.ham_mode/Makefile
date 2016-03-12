MODULE=ham_mode.s
FLOPPY=bin/ham_mode.adf
IMAGEDATA=out/image-palette.s out/image-ham.bin
IMAGEFILE=../assets/gigi_full.png
SIZED_IMAGEFILE=out/image.png
EXTRA=$(IMAGEDATA) $(BOB_IMAGEDATA) init.s utils.s constants.i Makefile

include ../shared/base.mk

$(SIZED_IMAGEFILE): $(IMAGEFILE) $(RESIZE) Makefile
	$(RESIZE) --width=320 --height=256  --blur=0.75 --input=$(IMAGEFILE) --output=$(SIZED_IMAGEFILE)

$(IMAGEDATA): $(IMAGECON) $(SIZED_IMAGEFILE) Makefile
	$(IMAGECON) --input $(SIZED_IMAGEFILE) --output out/image --ham --output-bitplanes --output-palette-asm 
