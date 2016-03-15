SHRINKLER=1
INTERLACE=0
HAM_MODE=0

MODULE=shrinkler.s
FLOPPY=bin/shrinkler.adf
IMAGEDATA=out/image-palette.s out/image-ham.bin
IMAGEFILE=../assets/gigi_full.png
SIZED_IMAGEFILE=out/image.png
BOOTBLOCK_ASM=shrink_bootblock.s
BASE_ADDRESS=50000
DECOMPRESS_ADDRESS=10000
EXTRA=$(IMAGEDATA) init.s utils.s constants.i Makefile

ifeq ($(SHRINKLER),1)
PROGRAM_BIN=out/shrunk.bin
VASM_EXTRA_BOOTBLOCK_ARGS=-DDECOMPRESS_ADDRESS="\$$$(DECOMPRESS_ADDRESS)" -DSHRINKLER=$(SHRINKLER)
else
PROGRAM_BIN=out/main.bin
VASM_EXTRA_BOOTBLOCK_ARGS=-DSHRINKLER=$(SHRINKLER)
endif

ifeq ($(HAM_MODE),1)
VASM_EXTRA_ARGS=-DINTERLACE=$(INTERLACE) -DHAM_MODE=$(HAM_MODE)
IMAGECON_ARGS=--use-palette gigi.pal --dither --ham
else
VASM_EXTRA_ARGS=-DINTERLACE=$(INTERLACE) -DHAM_MODE=$(HAM_MODE) 
IMAGECON_ARGS=--colors 32 --quantize 
endif

ifeq ($(INTERLACE),1)
FLAGS=--height=512 --interlaced
else
FLAGS=--height=256
endif

include ../shared/base.mk

ifeq ($(SHRINKLER),1)
$(PROGRAM_BIN): out/main.bin
	../tools/external/shrinkler/build/native/Shrinkler -d out/main.bin out/shrunk.bin
endif

$(SIZED_IMAGEFILE): $(IMAGEFILE) $(RESIZE) Makefile
	$(RESIZE) --width=320  $(FLAGS) --blur=0.75 --input=$(IMAGEFILE) --output=$(SIZED_IMAGEFILE)

$(IMAGEDATA): $(IMAGECON) $(SIZED_IMAGEFILE) Makefile
	$(IMAGECON) --input $(SIZED_IMAGEFILE) $(IMAGECON_ARGS) --output out/image --output-bitplanes  --output-palette-asm --output-palette $(DITHER)


