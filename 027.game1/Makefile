EXAMPLE_NAME=tile_hscroll

# userstack used by bootblock
USERSTACK_ADDRESS=7fffc
# if you change this you must also change link.script.x
BASE_ADDRESS=4000
# note: this must be high enough not to conflict with MFMbufE

NUM_COLORS=8

BOOTBLOCK_ASM=alpine_bootblock.s
OBJS=out/init.o out/utils.o out/image.o out/blit.o out/scroll.o

#IMAGES=gigi_full.png
#IMAGEDATA=$(addprefix out/, $(IMAGES:.png=.bin))
#SIZEDIMAGEDATA=$(addprefix out/, $(IMAGES:.png=.sized.png))

TILEMAPS=2222.png background_tiles.png
TILEMAPDATA=$(addprefix out/, $(TILEMAPS:.png=.bin))

VASM_EXTRA_ARGS=-DNUM_COLORS=$(NUM_COLORS)

#SYMBOL_INFO=-M
LINKER_OPTIONS=-T link.script.x

include ../shared/base.mk


#out/%.sized.png: ../assets/%.png
#	$(RESIZE) --width=352 --height=256 --blur=0.75 --input=$< --output=$@

#out/%.bin: out/%.sized.png
#	$(IMAGECON) --input $< $(IMAGECON_ARGS) --quantize --colors $(NUM_COLORS) --output-bitplanes  --output-palette-asm --output-grey-palette --output-palette $(DITHER) --output out/$*

out/%.bin: assets/%.png
	$(IMAGECON) --use-palette=assets/fg.pal --input $< $(IMAGECON_ARGS) --quantize --colors $(NUM_COLORS) --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-grey-palette --output-palette $(DITHER) --output-png --output out/$*

out/main-map.s: map.tmx
	../tools/mapgen/out/mapgen --depth=3 --input=map.tmx
	mv main-map.s out

out/blit.o: constants.i macros.i
out/main.o: out/main-map.s $(TILEMAPDATA) $(IMAGEDATA) constants.i macros.i Makefile link.script.x palette.pal
out/init.o: constants.i Makefile