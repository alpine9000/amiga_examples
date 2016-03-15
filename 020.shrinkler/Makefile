SHRINKLER=1
INTERLACE=0
HAM_MODE=0

MODULE=shrinkler.s
OBJS=out/init.o out/utils.o
FLOPPY=bin/shrinkler.adf
IMAGEFILE=../assets/gigi_full.png
SIZED_IMAGEFILE=out/image.png
BASE_ADDRESS=50000
DECOMPRESS_ADDRESS=10000

ifeq ($(HAM_MODE),1)
IMAGEDATA=out/image-palette.s out/image-ham.bin
VASM_EXTRA_ARGS=-DINTERLACE=$(INTERLACE) -DHAM_MODE=$(HAM_MODE)
IMAGECON_ARGS=--use-palette gigi.pal --dither --ham
else
VASM_EXTRA_ARGS=-DINTERLACE=$(INTERLACE) -DHAM_MODE=$(HAM_MODE) 
IMAGECON_ARGS=--colors 32 --quantize 
IMAGEDATA=out/image-palette.s out/image.bin
endif

ifeq ($(INTERLACE),1)
FLAGS=--height=512 --interlaced
else
FLAGS=--height=256
endif

include ../shared/base.mk


$(SIZED_IMAGEFILE): $(IMAGEFILE) $(RESIZE) Makefile
	$(RESIZE) --width=320  $(FLAGS) --blur=0.75 --input=$(IMAGEFILE) --output=$(SIZED_IMAGEFILE)

$(IMAGEDATA): $(IMAGECON) $(SIZED_IMAGEFILE) Makefile
	$(IMAGECON) --input $(SIZED_IMAGEFILE) $(IMAGECON_ARGS) --output out/image --output-bitplanes  --output-palette-asm --output-palette $(DITHER)


out/main.o: $(IMAGEDATA) constants.i Makefile
out/init.o: constants.i Makefile