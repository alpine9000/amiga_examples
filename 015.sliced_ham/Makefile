MODULE=sliced_ham.s
FLOPPY=bin/sliced_ham.adf
IMAGEDATA=out/image-sham-copper.s out/image-sham.bin
IMAGEFILE=../assets/gigi_full.png
SIZED_IMAGEFILE=out/image.png
EXTRA=$(IMAGEDATA) $(BOB_IMAGEDATA) init.s utils.s constants.i Makefile
BASE_ADDRESS=10000

#DITHERED=--dither

include ../shared/base.mk

$(SIZED_IMAGEFILE): $(IMAGEFILE) $(RESIZE) Makefile
	$(RESIZE) --width=320  --height=256 --blur=0.75 --input=$(IMAGEFILE) --output=$(SIZED_IMAGEFILE)

$(IMAGEDATA): $(IMAGECON) $(SIZED_IMAGEFILE) Makefile
	$(IMAGECON) --input $(SIZED_IMAGEFILE) --output out/image   --output-bitplanes $(DITHERED)  --sliced-ham
