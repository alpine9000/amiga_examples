EXAMPLE_NAME=game1
BACKGROUND_COLOR=09e
BACKGROUND_GREY_COLOR=777

# userstack used by bootblock
USERSTACK_ADDRESS=7fffc
# if you change this you must also change link.script.x
BASE_ADDRESS=4000
# note: this must be high enough not to conflict with MFMbufE

NUM_COLORS=8

BOOTBLOCK_ASM=alpine_bootblock.s
OBJS=out/init.o out/utils.o out/image.o out/blit.o out/joystick.o out/pig.o out/items.o out/blittext.o

IMAGES=foreground.png \
	background.png \
	panel.png \
	mpanel.png \
	sprite_pig_up.png \
	sprite_pig_down.png \
	sprite_pig_left.png \
	sprite_pig_right.png \
	sprite_pig_left_jump.png \
	sprite_pig_up_jump.png \
	sprite_pig_down_jump.png \
	sprite_pig_right_jump.png \
	sprite_coin-0.png \
	sprite_coin-1.png \
	sprite_coin-2.png \
	sprite_coin-3.png\
	font8x8.png

IMAGEDATA=$(addprefix out/, $(IMAGES:.png=.bin))

VASM_EXTRA_ARGS=-DNUM_COLORS=$(NUM_COLORS)

#SYMBOL_INFO=-M
LINKER_OPTIONS=-T link.script.x

include ../shared/base.mk

#out/%.bin: out/%.sized.png
#	$(IMAGECON) --input $< $(IMAGECON_ARGS) --quantize --colors $(NUM_COLORS) --output-bitplanes  --output-palette-asm --output-grey-palette --output-palette $(DITHER) --output out/$*

out/foreground.bin: assets/foreground.png
	$(IMAGECON) --use-palette=assets/foreground.pal --input $< $(IMAGECON_ARGS) --colors $(NUM_COLORS) --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-grey-palette --output-palette --output-png --output-copperlist --output out/foreground
	sed -i '' "1s/.*/        dc.w COLOR00,\$$$(BACKGROUND_COLOR)/" out/foreground-copper-list.s 
	sed -i '' "1s/.*/        dc.w \$$$(BACKGROUND_COLOR)/" out/foreground-palette-table.s
	sed -i '' "1s/.*/        dc.w \$$$(BACKGROUND_GREY_COLOR)/" out/foreground-grey-table.s

out/background.bin: assets/tilemap.png
	$(IMAGECON) --use-palette=assets/background.pal --input $< $(IMAGECON_ARGS) --colors $(NUM_COLORS) --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-grey-palette --output-palette --output-png --output-copperlist --output out/background --palette-offset 8

out/panel.bin: assets/panel.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 16 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output-grey-palette --output out/panel --use-palette=assets/panel.pal

out/mpanel.bin: assets/mpanel.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 16 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output-grey-palette --output out/mpanel --use-palette=assets/mpanel.pal

out/sprite_pig_%.bin: assets/sprite_pig_%.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 4 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output out/sprite_pig_$* --palette-offset 16 --use-palette=assets/pig.pal

out/sprite_coin%.bin: out/sprite_coin%.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 4 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output out/sprite_coin$* --palette-offset 20  --use-palette=assets/coin.pal

out/sprite_coin%.png: assets/assets.png
	../tools/croppa/out/croppa --input=assets/assets.png --output=out/sprite_coin --width=16 --height=16 --rows=1 --cols=4 --dx=16 --dy=16 --x=128 --y=192

out/font%.bin: assets/font%.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --output-bitplanes --output-grey-palette-asm --output-palette-asm --output-palette --output out/font$* --colors=16 --use-palette assets/mpanel.pal --full-color-palette-file --output-mask --transparent-color=0,0,0 --output-png

out/fade.s: assets/bottom_section.pal out/fade
	./out/fade assets/bottom_section.pal bottom > out/fade.s

out/panelFade.s: assets/panel.pal out/fade
	./out/fade assets/panel.pal panel > out/panelFade.s

out/fade: fade.c
	gcc fade.c -o out/fade

out/foreground-map.s: foreground.tmx
	../tools/mapgen/out/mapgen --depth=3 --input=foreground.tmx
	mv foreground-map.s out
	rm items-map.s
	mv items-indexes.s out
	rm foreground-indexes.s

out/background-map.s: background.tmx
	../tools/mapgen/out/mapgen --depth=3 --input=background.tmx
	mv background-map.s out
	rm background-indexes.s

out/blit.o: constants.i macros.i
out/main.o: out/background-map.s out/foreground-map.s $(IMAGEDATA) constants.i macros.i Makefile link.script.x assets/palette.pal out/fade.s out/panelFade.s
out/init.o: constants.i Makefile