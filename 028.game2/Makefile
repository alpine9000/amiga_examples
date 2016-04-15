EXAMPLE_NAME=game1

# userstack used by bootblock
USERSTACK_ADDRESS=7fffc
# if you change this you must also change link.script.x
BASE_ADDRESS=4000
# note: this must be high enough not to conflict with MFMbufE

NUM_COLORS=8

BOOTBLOCK_ASM=alpine_bootblock.s
OBJS=out/init.o out/utils.o out/image.o out/blit.o out/joystick.o

#IMAGES=gigi_full.png
#IMAGEDATA=$(addprefix out/, $(IMAGES:.png=.bin))
#SIZEDIMAGEDATA=$(addprefix out/, $(IMAGES:.png=.sized.png))

TILEMAPS=foreground.png background.png
TILEMAPDATA=$(addprefix out/, $(TILEMAPS:.png=.bin))

VASM_EXTRA_ARGS=-DNUM_COLORS=$(NUM_COLORS)

#SYMBOL_INFO=-M
LINKER_OPTIONS=-T link.script.x

include ../shared/base.mk


#out/%.sized.png: ../assets/%.png
#	$(RESIZE) --width=352 --height=256 --blur=0.75 --input=$< --output=$@

out/%.bin: out/%.sized.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --quantize --colors $(NUM_COLORS) --output-bitplanes  --output-palette-asm --output-grey-palette --output-palette $(DITHER) --output out/$*

out/foreground.bin: assets/tilemap.png
	$(IMAGECON) --use-palette=assets/foreground.pal --input $< $(IMAGECON_ARGS) --colors $(NUM_COLORS) --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-grey-palette --output-palette --output-png --output out/foreground

out/background.bin: assets/tilemap.png
	$(IMAGECON) --use-palette=assets/background.pal --input $< $(IMAGECON_ARGS) --colors $(NUM_COLORS) --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-grey-palette --output-palette --output-png --output out/background

out/tilemap-palette.s: assets/tilemap.png
	$(IMAGECON) --use-palette=assets/palette.pal --full-color-palette-file --input=assets/tilemap.png --output-palette-asm --output=out/tilemap

out/foreground-map.s: foreground.tmx
	../tools/mapgen/out/mapgen --depth=3 --input=foreground.tmx
	mv foreground-map.s out

out/background-map.s: background.tmx
	../tools/mapgen/out/mapgen --depth=3 --input=background.tmx
	mv background-map.s out

out/blit.o: constants.i macros.i
out/main.o: out/background-map.s out/foreground-map.s $(TILEMAPDATA) $(IMAGEDATA) constants.i macros.i Makefile link.script.x assets/palette.pal out/tilemap-palette.s
out/init.o: constants.i Makefile