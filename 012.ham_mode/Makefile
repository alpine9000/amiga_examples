MODULE=ham_mode.s
FLOPPY=bin/ham_mode.adf
IMAGEDATA=out/image-palette.s out/image-ham.bin
IMAGEFILE=../assets/gigi.png
EXTRA=$(IMAGEDATA) $(BOB_IMAGEDATA) init.s utils.s constants.i Makefile

include ../shared/base.mk

$(IMAGEDATA): $(IMAGECON) $(IMAGEFILE) Makefile
	$(IMAGECON) --input $(IMAGEFILE) --output out/image --ham --output-bitplanes --output-palette-asm 
