EXAMPLE_NAME=slideshow

SECONDS_WAIT=10
INTERLACE=1
HAM_MODE=1

USERSTACK_ADDRESS=7fffc # userstack used by bootblock
BASE_ADDRESS=10000	# if you change this you must also change link.script

BOOTBLOCK_ASM=alpine_bootblock.s
OBJS=out/init.o out/utils.o out/trackloader.o out/image.o out/blitter.o

ifeq ($(INTERLACE),0)
NOINTERLACE_EXTRA=mr8.png
endif

IMAGES=mr.png mr2.png mr3.png mr4.png  mr6.png mr9.png mr10.png $(NOINTERLACE_EXTRA)

P61MODULE=out/P61.breath_of_life.lz

USE_PALETTES=--use-palette=palettes/$*.pal

VASM_EXTRA_ARGS=-DSECONDS_WAIT=$(SECONDS_WAIT) -DINTERLACE=$(INTERLACE) -DHAM_MODE=$(HAM_MODE)

ifeq ($(HAM_MODE),1)
IMAGECON_ARGS= --dither --ham $(USE_PALETTES)
IMAGEDATA=$(addprefix out/, $(IMAGES:.png=-ham.bin))
else
IMAGECON_ARGS=--colors 32 --quantize 
IMAGEDATA=$(addprefix out/, $(IMAGES:.png=.bin))
endif

SHRUNKDATA=$(IMAGEDATA:.bin=.lz)
SIZEDIMAGEDATA=$(addprefix out/, $(IMAGES:.png=.sized.png))

ifeq ($(INTERLACE),1)
FLAGS=--height=512 --interlaced
else
FLAGS=--height=256
endif

#SYMBOL_INFO=-M
LINK_COMMANDLINE=vlink -T link.script -brawbin1 $< $(OBJS) $(SYMBOL_INFO) -o $@
include ../shared/base.mk


out/%.sized.png: ../assets/%.png
	$(RESIZE) --width=320  $(FLAGS) --blur=0.75 --input=$< --output=$@

out/%.bin: out/%.sized.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --output-bitplanes  --output-palette-asm --output-palette $(DITHER) --output out/$*

out/%.lz: out/%.bin
	$(DOYNAMITE68K) $<

out/%.lz: ../assets/%.mod
	$(DOYNAMITE68K) -o $@ $<

out/%-ham.bin: out/%.sized.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --output-bitplanes  --output-palette-asm --output-palette $(DITHER) --output out/$* 

out/main.o: $(P61MODULE) $(SIZEDIMAGEDATA) $(IMAGEDATA) $(SHRUNKDATA) constants.i Makefile link.script
out/init.o: constants.i Makefile