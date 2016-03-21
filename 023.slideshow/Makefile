EXAMPLE_NAME=slideshow

SHRINKLER=0
INTERLACE=1
HAM_MODE=1

BOOTBLOCK_ASM=alpine_bootblock.s

OBJS=out/init.o out/utils.o out/trackloader.o out/image.o

IMAGES=mr.png batgirl.png catwoman.png kb.png fe.png ww.png

USERSTACK_ADDRESS=7fffc
BASE_ADDRESS=10000
DECOMPRESS_ADDRESS=10000

ifeq ($(HAM_MODE),1)
VASM_EXTRA_ARGS=-DINTERLACE=$(INTERLACE) -DHAM_MODE=$(HAM_MODE)
IMAGECON_ARGS= --dither --ham
IMAGEDATA=$(addprefix out/, $(IMAGES:.png=-ham.bin))
else
VASM_EXTRA_ARGS=-DINTERLACE=$(INTERLACE) -DHAM_MODE=$(HAM_MODE) 
IMAGECON_ARGS=--colors 32 --quantize 
IMAGEDATA=$(addprefix out/, $(IMAGES:.png=.bin))
endif

SHRUNKDATA=$(IMAGEDATA:.bin=.bin.sz)
SIZEDIMAGEDATA=$(addprefix out/, $(IMAGES:.png=.sized.png))

ifeq ($(INTERLACE),1)
FLAGS=--height=512 --interlaced
else
FLAGS=--height=256
endif

#-M
LINK_COMMANDLINE=vlink -T link.script -brawbin1 $< $(OBJS)  -o  $@
include ../shared/base.mk

out/%.sized.png: ../assets/%.png
	$(RESIZE) --width=320  $(FLAGS) --blur=0.75 --input=$< --output=$@

out/%.bin: out/%.sized.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --output-bitplanes  --output-palette-asm --output-palette $(DITHER) --output out/$*

out/%.bin.sz: out/%.bin
	 $(SHRINKLEREXE) -d $< $@


out/%-ham.bin: out/%.sized.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --output-bitplanes  --output-palette-asm --output-palette $(DITHER) --output out/$* --use-palette=palettes/$*.pal

out/main.o: $(SIZEDIMAGEDATA) $(IMAGEDATA) $(SHRUNKDATA) constants.i Makefile link.script
out/init.o: constants.i Makefile