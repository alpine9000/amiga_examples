EXAMPLE_NAME=game1
BACKGROUND_COLOR=09e
BACKGROUND_GREY_COLOR=777

# userstack used by bootblock
USERSTACK_ADDRESS=7fffc
# if you change this you must also change link.script.x
BASE_ADDRESS=4000
# note: this must be high enough not to conflict with MFMbufE

BOOTBLOCK_ASM=alpine_bootblock.s
OBJS=out/init.o out/utils.o out/image.o out/blit.o out/joystick.o out/player.o out/items.o out/blitmtext.o out/blittext.o out/music.o out/P6112-Play.o out/splash.o out/background.o out/sound.o

IMAGES=foreground.png \
	background.png \
	panel.png \
	mpanel.png \
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
	splash.png

IMAGEDATA=$(addprefix out/, $(IMAGES:.png=.bin))

VASM_EXTRA_ARGS=-DTIMING_TEST=0

#SYMBOL_INFO=-M
LINKER_OPTIONS=-T link.script.x

include ../shared/base.mk

out/foreground.bin: assets/assets.png
	$(IMAGECON) --use-palette=assets/foreground.pal --input $< $(IMAGECON_ARGS) --colors 8 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-grey-palette --output-palette --output-png --output-copperlist --output out/foreground
	sed -i '' "1s/.*/        dc.w COLOR00,\$$$(BACKGROUND_COLOR)/" out/foreground-copper-list.s 
	sed -i '' "1s/.*/        dc.w \$$$(BACKGROUND_COLOR)/" out/foreground-palette-table.s
	sed -i '' "1s/.*/        dc.w \$$$(BACKGROUND_GREY_COLOR)/" out/foreground-grey-table.s
	sed -i '' "1s/.*/        dc.w COLOR00,\$$$(BACKGROUND_GREY_COLOR)/" out/foreground-grey-copper.s
	sed -i '' "2s/.*/        dc.w COLOR01,\$$888/" out/foreground-grey-copper.s
	sed -i '' "3s/.*/        dc.w COLOR02,\$$bbb/" out/foreground-grey-copper.s

out/background.bin: assets/assets.png
	$(IMAGECON) --use-palette=assets/background.pal --input $< $(IMAGECON_ARGS) --colors 8 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-grey-palette --output-palette --output-png --output-copperlist --output out/background --palette-offset 8

out/panel.bin: assets/panel.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 16 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output-grey-palette --output out/panel --use-palette=assets/panel.pal

out/mpanel.bin: assets/mpanel.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --colors 16 --output-bitplanes  --output-palette --full-color-palette-file --output-palette-asm --output-palette --output-png --output-copperlist --output-grey-palette --output out/mpanel --use-palette=assets/mpanel.pal

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

out/sprite_pig%.png: assets/assets.png
	../tools/croppa/out/croppa --input=assets/assets.png --output=out/sprite_pig --width=16 --height=16 --rows=1 --cols=8 --dx=16 --dy=16 --x=192 --y=112

out/sprite_robot%.png: assets/assets.png
	../tools/croppa/out/croppa --input=assets/assets.png --output=out/sprite_robot --width=16 --height=16 --rows=1 --cols=8 --dx=16 --dy=16 --x=192 --y=176

out/sprite_tank%.png: assets/assets.png
	../tools/croppa/out/croppa --input=assets/assets.png --output=out/sprite_tank --width=16 --height=16 --rows=1 --cols=8 --dx=16 --dy=16 --x=192 --y=208

out/sprite_fallingPig%.png: assets/assets.png
	../tools/croppa/out/croppa --input=assets/assets.png --output=out/sprite_fallingPig --width=16 --height=16 --rows=1 --cols=5 --dx=16 --dy=16 --x=192 --y=128

out/sprite_fallingRobot%.png: assets/assets.png
	../tools/croppa/out/croppa --input=assets/assets.png --output=out/sprite_fallingRobot --width=16 --height=16 --rows=1 --cols=5 --dx=16 --dy=16 --x=192 --y=192

out/sprite_fallingTank%.png: assets/assets.png
	../tools/croppa/out/croppa --input=assets/assets.png --output=out/sprite_fallingTank --width=16 --height=16 --rows=1 --cols=5 --dx=16 --dy=16 --x=192 --y=224

out/sprite_coin%.png: assets/assets.png
	../tools/croppa/out/croppa --input=assets/assets.png --output=out/sprite_coin --width=16 --height=15 --rows=1 --cols=4 --dx=16 --dy=16 --x=192 --y=144

out/font%.bin: assets/font%.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --output-bitplanes --output-grey-palette-asm --output-palette-asm --output-palette --output out/font$* --colors=16 --use-palette assets/mpanel.pal --full-color-palette-file --output-mask --transparent-color=0,0,0 --output-png

out/splash.bin: assets/splash.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --output-bitplanes --output-grey-palette-asm --output-palette-asm --output-palette --output out/splash --colors=32  --full-color-palette-file --output-png --output-copperlist

out/playarea_fade.s: assets/bottom_section_playarea.pal ../tools/fade/out/fade
	../tools/fade/out/fade --from-grey --to=assets/bottom_section_playarea.pal --output=playarea > out/playarea_fade.s

out/flags_fade.s: assets/bottom_section_flags.pal ../tools/fade/out/fade
	../tools/fade/out/fade --from-grey --to=assets/bottom_section_flags.pal --output=flags > out/flags_fade.s

out/panelFade.s: assets/panel.pal ../tools/fade/out/fade
	../tools/fade/out/fade --from-grey --to=assets/panel.pal --output=panel > out/panelFade.s

out/tileFade.s: assets/tileFadeFrom.pal assets/tileFadeTo.pal ../tools/fade/out/fade
	../tools/fade/out/fade --steps=64 --colors=2 --from=assets/tileFadeFrom.pal --to=assets/tileFadeTo.pal --output=tileFade > out/tileFade.s

out/foreground-map.s: foreground.tmx
	../tools/mapgen/out/mapgen --depth=3 --input=foreground.tmx
	@mv foreground-map.s out
	@rm items-map.s
	@mv items-indexes.s out
	@rm foreground-indexes.s
	@mv pathway-map.s out
	@mv pathway-indexes.s out


out/background-map.s: background.tmx
	../tools/mapgen/out/mapgen --depth=3 --input=background.tmx
	@mv background-map.s out
	@rm background-indexes.s

out/falling.raw: assets/falling.wav
	sox assets/falling.wav -b 8 -c 1 -r 8000 out/falling.raw

out/jump.raw: assets/jump.wav
	sox assets/jump.wav -c 1 -r 13000 -b 8 out/jump.raw

out/main.o: $(IMAGEDATA) out/background-map.s out/foreground-map.s Makefile link.script.x out/playarea_fade.s out/flags_fade.s out/panelFade.s out/tileFade.s out/jump.raw out/falling.raw

setuptiming:
	$(eval	VASM_EXTRA_ARGS="-DTIMING_TEST=1")
	echo $(VASM_EXTRA_ARGS)

timing: setuptiming all
