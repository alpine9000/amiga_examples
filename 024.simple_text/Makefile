EXAMPLE_NAME=simple_text

# userstack used by bootblock
USERSTACK_ADDRESS=7fffc
# if you change this you must also change link.script.x
BASE_ADDRESS=4000
# note: this must be high enough not to conflict with MFMbufE

BOOTBLOCK_ASM=alpine_bootblock.s
OBJS=out/init.o out/utils.o out/image.o out/blittext.o out/cpu.o out/blit.o

IMAGES=font.png
IMAGEDATA=$(addprefix out/, $(IMAGES:.png=.bin))
VASM_EXTRA_ARGS=

#SYMBOL_INFO=-M
LINKER_OPTIONS=-T link.script.x

include ../shared/base.mk

out/%.bin: ../assets/%.png
	$(IMAGECON) --input $< $(IMAGECON_ARGS) --output-bitplanes --output-grey-palette-asm --output-palette-asm --output-palette --output out/$* --colors=16 --use-palette palette.pal --full-color-palette-file --output-mask --transparent-color=0,0,0 --output-png


out/simple_image.o: constants.i macros.i
out/blittext.o: constants.i macros.i
out/blit.o: constants.i macros.i
out/main.o: $(IMAGEDATA) constants.i macros.i Makefile link.script.x palette.pal
out/init.o: constants.i Makefile