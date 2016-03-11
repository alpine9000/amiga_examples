MODULE=sliced_ham.s
FLOPPY=bin/sliced_ham.adf
IMAGEDATA=out/image-sham-copper.s out/image-sham.bin
IMAGEFILE=../assets/gigi.png
EXTRA=$(IMAGEDATA) $(BOB_IMAGEDATA) init.s utils.s constants.i Makefile
BASE_ADDRESS=10000

#DITHERED=--dither

include ../shared/base.mk

$(IMAGEDATA): $(IMAGECON) $(IMAGEFILE) Makefile
	$(IMAGECON) --input $(IMAGEFILE) --output out/image   --output-bitplanes $(DITHERED)  --sliced-ham
