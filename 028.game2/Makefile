EXAMPLE_NAME=game1

# userstack used by bootblock
USERSTACK_ADDRESS=7fffc
# if you change this you must also change link.script.x
BASE_ADDRESS=4000
# note: this must be high enough not to conflict with MFMbufE

NUM_COLORS=8

BOOTBLOCK_ASM=alpine_bootblock.s
OBJS=out/init.o out/utils.o out/image.o out/blit.o out/joystick.o

IMAGES=foreground.png background.png panel.png sprite_pig_up.png sprite_pig_down.png sprite_pig_left.png sprite_pig_right.png
IMAGEDATA=$(addprefix out/, $(IMAGES:.png=.bin))

VASM_EXTRA_ARGS=-DNUM_COLORS=$(NUM_COLORS)

#SYMBOL_INFO=-M
LINKER_OPTIONS=-T link.script.x

include ../shared/base.mk


#out/%.sized.png: ../assets/%.png
#	$(RESIZE) --width=352 --height=256 --blur=0.75 --input=$< --output=$@

out/%.bin: out/%.sized.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --quantize --colors $(NUM_COLORS) --output-bitplanes  --output-palette-asm --output-grey-palette --output-palette $(DITHER) --output out/$*

out/foreground.bin: assets/foregroundTilemap.png
	$(IMAGECON) --use-palette=assets/foreground.pal --input $< $(IMAGECON_ARGS) --colors $(NUM_COLORS) --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-grey-palette --output-palette --output-png --output out/foreground

out/background.bin: assets/tilemap.png
	$(IMAGECON) --use-palette=assets/background.pal --input $< $(IMAGECON_ARGS) --colors $(NUM_COLORS) --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-grey-palette --output-palette --output-png --output out/background

out/tilemap-palette.s: assets/tilemap.png
	$(IMAGECON) --use-palette=assets/palette.pal --full-color-palette-file --input=assets/tilemap.png --output-palette-asm --output=out/tilemap --output-copperlist --output-grey-palette

out/panel.bin: assets/panel.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 16 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output out/panel --use-palette=assets/panel.pal

out/sprite_pig_up.bin: assets/sprite_pig_up.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 4 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output out/sprite_pig_up --palette-offset 16 --use-palette=assets/pig.pal

out/sprite_pig_down.bin: assets/sprite_pig_down.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 4 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output out/sprite_pig_down --palette-offset 16 --use-palette=assets/pig.pal

out/sprite_pig_left.bin: assets/sprite_pig_left.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 4 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output out/sprite_pig_left --palette-offset 16 --use-palette=assets/pig.pal

out/sprite_pig_right.bin: assets/sprite_pig_right.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 4 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output out/sprite_pig_right --palette-offset 16 --use-palette=assets/pig.pal


out/foreground-map.s: foreground.tmx
	../tools/mapgen/out/mapgen --depth=3 --input=foreground.tmx
	mv foreground-map.s out

out/background-map.s: background.tmx
	../tools/mapgen/out/mapgen --depth=3 --input=background.tmx
	mv background-map.s out

out/blit.o: constants.i macros.i
out/main.o: out/background-map.s out/foreground-map.s $(IMAGEDATA) constants.i macros.i Makefile link.script.x assets/palette.pal out/tilemap-palette.s 
out/init.o: constants.i Makefile