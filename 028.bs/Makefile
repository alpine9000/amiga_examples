EXAMPLE_NAME=game1
BACKGROUND_COLOR=09e
BACKGROUND_GREY_COLOR=777
paletteA_BACKGROUND_COLOR_LONG=000 153 238 255
paletteB_BACKGROUND_COLOR_LONG=000 000 102 187
paletteC_BACKGROUND_COLOR_LONG=020 020 020 255

# userstack used by bootblock
USERSTACK_ADDRESS=7fffc
# if you change this you must also change link.script.x
BASE_ADDRESS=4000
# note: this must be high enough not to conflict with MFMbufE

BOOTBLOCK_ASM=alpine_bootblock.s
OBJS=out/init.o out/utils.o out/image.o out/blit.o out/joystick.o out/player.o out/items.o out/blitmtext.o out/blitmtext85.o out/blittext.o out/music.o out/P6112-Play.o out/splash.o out/background.o out/sound.o out/trackloader.o out/disk.o out/counter.o out/map.o out/message.o out/menu.o out/credits.o

IMAGES=foreground.png \
	background.png \
	panel.png \
	mpanel.png \
	mpanelOrig.png \
	sprite_pig-0.png \
	sprite_pig-1.png \
	sprite_pig-2.png \
	sprite_pig-3.png \
	sprite_pig-4.png \
	sprite_pig-5.png \
	sprite_pig-6.png \
	sprite_pig-7.png \
	sprite_robot-0.png \
	sprite_robot-1.png \
	sprite_robot-2.png \
	sprite_robot-3.png \
	sprite_robot-4.png \
	sprite_robot-5.png \
	sprite_robot-6.png \
	sprite_robot-7.png \
	sprite_tank-0.png \
	sprite_tank-1.png \
	sprite_tank-2.png \
	sprite_tank-3.png \
	sprite_tank-4.png \
	sprite_tank-5.png \
	sprite_tank-6.png \
	sprite_tank-7.png \
	sprite_coin-0.png \
	sprite_coin-1.png \
	sprite_coin-2.png \
	sprite_coin-3.png\
	sprite_arrow-0.png \
	sprite_arrow-1.png \
	sprite_arrow-2.png \
	sprite_arrow-3.png\
	sprite_fallingPig-0.png \
	sprite_fallingPig-1.png \
	sprite_fallingPig-2.png \
	sprite_fallingPig-3.png \
	sprite_fallingPig-4.png \
	sprite_fallingRobot-0.png \
	sprite_fallingRobot-1.png \
	sprite_fallingRobot-2.png \
	sprite_fallingRobot-3.png \
	sprite_fallingRobot-4.png \
	sprite_fallingTank-0.png \
	sprite_fallingTank-1.png \
	sprite_fallingTank-2.png \
	sprite_fallingTank-3.png \
	sprite_fallingTank-4.png \
	font8x8.png\
	font8x85.png\
	splash.png\
	splashSave.png

IMAGEDATA=$(addprefix out/, $(IMAGES:.png=.bin))

VASM_EXTRA_ARGS=-DTIMING_TEST=0 -DSFX=1

LINKER_OPTIONS=-T link.script.x

include ../shared/base.mk

out/foreground.bin: assets/assets.png
	$(IMAGECON) --use-palette=assets/paletteA_foreground_flags.pal --input $< $(IMAGECON_ARGS) --colors 8 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-grey-palette --output-palette --output-png --output-copperlist --output out/foreground
	#sed -i '' "1s/.*/        dc.w COLOR00,\$$$(BACKGROUND_COLOR)/" out/foreground-copper-list.s 
	sed -i '' "1s/.*/        dc.w COLOR00,\$$$(BACKGROUND_GREY_COLOR)/" out/foreground-grey-copper.s
	sed -i '' "2s/.*/        dc.w COLOR01,\$$888/" out/foreground-grey-copper.s
	sed -i '' "3s/.*/        dc.w COLOR02,\$$bbb/" out/foreground-grey-copper.s

out/%_foreground-palette-table.s: assets/%_foreground_flags.pal
	$(IMAGECON) --use-palette=assets/$*_foreground_flags.pal --input assets/assets.png $(IMAGECON_ARGS) --colors 8  --full-color-palette-file --output-palette-asm --output-grey-palette --output-copperlist --output out/$*_foreground
	sed -i '' "1s/.*/        dc.w \$$$($*_BACKGROUND_COLOR)/" out/$*_foreground-palette-table.s


out/%_bottom_section_flags.pal: assets/%_foreground_flags.pal assets/%_background.pal
	cat assets/$*_foreground_flags.pal  assets/$*_background.pal | sed "1s/.*/$($*_BACKGROUND_COLOR_LONG)/" > out/$*_bottom_section_flags.pal

out/%_bottom_section_playarea.pal: assets/%_foreground_playarea.pal assets/%_background.pal
	cat assets/$*_foreground_playarea.pal  assets/$*_background.pal | sed "1s/.*/$($*_BACKGROUND_COLOR_LONG)/" > out/$*_bottom_section_playarea.pal

out/%_tileFadeFrom.pal: assets/%_foreground_playarea.pal
	cat assets/$*_foreground_playarea.pal | tail -1 | awk '1;1;' > out/$*_tileFadeFrom.pal

out/%_tileFadeTo.pal: assets/%_foreground_playarea.pal
	cat assets/$*_foreground_playarea.pal  | tail -3 | head -2 > out/$*_tileFadeTo.pal

out/background.bin: assets/assets.png
	$(IMAGECON) --use-palette=assets/paletteA_background.pal --input $< $(IMAGECON_ARGS) --colors 8 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-grey-palette --output-palette --output-png --output-copperlist --output out/background --palette-offset 8

out/panel.bin: assets/panel.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 16 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output-grey-palette --output out/panel --use-palette=assets/panel.pal

out/mpanel.bin: assets/mpanel.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 16 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output-grey-palette --output out/mpanel --use-palette=assets/mpanel.pal

out/mpanelOrig.bin: out/mpanelOrig.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 16 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output-grey-palette --output out/mpanelOrig --use-palette=assets/mpanel.pal


out/sprite_pig-%.bin: out/sprite_pig-%.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 4 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output out/sprite_pig-$* --palette-offset 16 --use-palette=assets/pig.pal

out/sprite_robot-%.bin: out/sprite_robot-%.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 4 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output out/sprite_robot-$* --palette-offset 16 --use-palette=assets/robot.pal

out/sprite_tank-%.bin: out/sprite_tank-%.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 4 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output out/sprite_tank-$* --palette-offset 16 --use-palette=assets/tank.pal


out/sprite_fallingPig-%.bin: out/sprite_fallingPig-%.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 4 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output out/sprite_fallingPig-$* --palette-offset 16 --use-palette=assets/pig.pal

out/sprite_fallingRobot-%.bin: out/sprite_fallingRobot-%.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 4 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output out/sprite_fallingRobot-$* --palette-offset 16 --use-palette=assets/robot.pal

out/sprite_fallingTank-%.bin: out/sprite_fallingTank-%.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 4 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output out/sprite_fallingTank-$* --palette-offset 16 --use-palette=assets/tank.pal

out/sprite_coin%.bin: out/sprite_coin%.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 4 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output out/sprite_coin$* --palette-offset 20  --use-palette=assets/coin.pal

out/sprite_arrow%.bin: out/sprite_arrow%.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 4 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output out/sprite_arrow$* --palette-offset 24  --use-palette=assets/arrow.pal


.SECONDARY:
out/sprite_pig%.png: assets/assets.png
	../tools/croppa/out/croppa --input=assets/assets.png --output=out/sprite_pig --width=16 --height=16 --rows=1 --cols=8 --dx=16 --dy=16 --x=192 --y=112

out/mpanelOrig.png: assets/mpanel.png
	../tools/croppa/out/croppa --input=assets/mpanel.png --output=out/mpanelOrig.png --width=320 --height=16 --rows=1 --cols=1 --dx=0 --dy=0 --x=0 --y=8

.SECONDARY:
out/sprite_robot%.png: assets/assets.png
	../tools/croppa/out/croppa --input=assets/assets.png --output=out/sprite_robot --width=16 --height=16 --rows=1 --cols=8 --dx=16 --dy=16 --x=192 --y=176

.SECONDARY:
out/sprite_tank%.png: assets/assets.png
	../tools/croppa/out/croppa --input=assets/assets.png --output=out/sprite_tank --width=16 --height=16 --rows=1 --cols=8 --dx=16 --dy=16 --x=192 --y=208

.SECONDARY:
out/sprite_fallingPig%.png: assets/assets.png
	../tools/croppa/out/croppa --input=assets/assets.png --output=out/sprite_fallingPig --width=16 --height=16 --rows=1 --cols=5 --dx=16 --dy=16 --x=192 --y=128

.SECONDARY:
out/sprite_fallingRobot%.png: assets/assets.png
	../tools/croppa/out/croppa --input=assets/assets.png --output=out/sprite_fallingRobot --width=16 --height=16 --rows=1 --cols=5 --dx=16 --dy=16 --x=192 --y=192

.SECONDARY:
out/sprite_fallingTank%.png: assets/assets.png
	../tools/croppa/out/croppa --input=assets/assets.png --output=out/sprite_fallingTank --width=16 --height=16 --rows=1 --cols=5 --dx=16 --dy=16 --x=192 --y=224

.SECONDARY:
out/sprite_coin%.png: assets/assets.png
	../tools/croppa/out/croppa --input=assets/assets.png --output=out/sprite_coin --width=16 --height=15 --rows=1 --cols=4 --dx=16 --dy=16 --x=192 --y=144

.SECONDARY:
out/sprite_arrow%.png: assets/assets.png
	../tools/croppa/out/croppa --input=assets/assets.png --output=out/sprite_arrow --width=16 --height=15 --rows=1 --cols=4 --dx=16 --dy=16 --x=192 --y=160

out/font%.bin: assets/font%.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --output-bitplanes --output-grey-palette-asm --output-palette-asm --output-palette --output out/font$* --colors=16 --use-palette assets/mpanel.pal --full-color-palette-file --output-mask --transparent-color=0,0,0 --output-png

out/font8x85.bin: assets/font8x8.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --output-bitplanes --output-grey-palette-asm --output-palette-asm --output-palette --output out/font8x85 --colors=32 --use-palette assets/font8x85.pal --full-color-palette-file --output-mask --transparent-color=0,0,0 --output-png

out/splashSave.bin: assets/splash.png out/splash.bin
	../tools/croppa/out/croppa --input=assets/splash.png --output=out/splashSave.png --width=96 --height=64 --rows=1 --cols=1 --dx=0 --dy=0 --x=112 --y=150
	$(IMAGECON) --input out/splashSave.png $(IMAGECON_ARGS) --output-bitplanes --output-grey-palette-asm --output-palette-asm --output-palette --output out/splashSave --colors=32 --output-copperlist --full-color-palette-file --use-palette=out/splash.pal

out/splash.bin: assets/splash.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --output-bitplanes --output-grey-palette-asm --output-palette-asm --output-palette --output out/splash --colors=32 --output-copperlist --full-color-palette-file

out/menu-palette.s: assets/splash.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --output-palette-asm --output-palette --output out/menu --colors=32 --output-copperlist --full-color-palette-file --darken=0.55

out/%_playarea_fade.s: out/%_bottom_section_playarea.pal ../tools/fade/out/fade
	../tools/fade/out/fade --from-grey --to=out/$*_bottom_section_playarea.pal --output=$*_playarea > out/$*_playarea_fade.s

out/%_flags_fade.s: out/%_bottom_section_flags.pal ../tools/fade/out/fade
	../tools/fade/out/fade --from-grey --to=out/$*_bottom_section_flags.pal --output=$*_flags > out/$*_flags_fade.s

out/panelFade.s: assets/panel.pal ../tools/fade/out/fade
	../tools/fade/out/fade --from-grey --to=assets/panel.pal --output=panel > out/panelFade.s

out/%_tileFade.s: out/%_tileFadeFrom.pal out/%_tileFadeTo.pal ../tools/fade/out/fade
	../tools/fade/out/fade --steps=64 --colors=2 --from=out/$*_tileFadeFrom.pal --to=out/$*_tileFadeTo.pal --output=$*_tileFade > out/$*_tileFade.s

out/%_foreground-map.s: levels/%_foreground.tmx
	../tools/mapgen/out/mapgen --depth=3 --input=levels/$*_foreground.tmx
	@mv foreground-map.s out/$*_foreground-map.s
	@rm items-map.s
	@mv items-indexes.s out/$*_items-indexes.s
	@rm foreground-indexes.s
	@mv pathway-map.s out/$*_pathway-map.s
	@mv pathway-indexes.s out/$*_pathway-indexes.s


out/background-map.s: background.tmx
	../tools/mapgen/out/mapgen --depth=3 --input=background.tmx
	@mv background-map.s out
	@rm background-indexes.s

out/falling.raw: assets/falling.wav
	sox assets/falling.wav -b 8 -c 1 -r 8000 out/falling.raw

out/jump.raw: assets/jump.wav
	sox -v 0.98 assets/jump.wav -c 1 -r 13000 -b 8 out/jump.raw

out/whoosh.raw: assets/whoosh.wav
	sox -v 2.0 assets/whoosh.wav -c 1 -r 13000 -b 8 out/whoosh.raw

out/chaching.raw: assets/chaching.wav
	sox -v 0.98 assets/chaching.wav -c 1 -r 13000 -b 8 out/chaching.raw

out/yay.raw: assets/yay.wav
	sox -v 2.0 assets/yay.wav -c 1 -r 4000 -b 8 out/yay.raw

out/main.o: $(IMAGEDATA) \
	out/levelA_foreground-map.s out/levelB_foreground-map.s out/levelC_foreground-map.s\
	out/background-map.s  Makefile link.script.x\
	out/menu-palette.s\
	out/paletteA_playarea_fade.s out/paletteA_flags_fade.s out/paletteA_foreground-palette-table.s out/paletteA_tileFade.s\
	out/paletteB_playarea_fade.s out/paletteB_flags_fade.s out/paletteB_foreground-palette-table.s out/paletteB_tileFade.s\
	out/paletteC_playarea_fade.s out/paletteC_flags_fade.s out/paletteC_foreground-palette-table.s out/paletteC_tileFade.s\
	out/panelFade.s out/jump.raw out/falling.raw out/chaching.raw out/whoosh.raw out/yay.raw

setuptiming:
	$(eval	VASM_EXTRA_ARGS=-DTIMING_TEST=1 -DSFX=1)
	echo $(VASM_EXTRA_ARGS)

timing: setuptiming all
