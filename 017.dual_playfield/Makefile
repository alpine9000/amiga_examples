MODULE=dual_playfield_mode.s
FLOPPY=bin/dual_playfield_mode.adf
IMAGEDATA=out/playfield1-palette.s out/playfield2-palette.s out/playfield1.bin out/playfield2.bin
PF1_FILE=../assets/playfield1.png
PF2_FILE=../assets/playfield2.png

EXTRA=$(IMAGEDATA) init.s utils.s constants.i Makefile
BASE_ADDRESS=10000

include ../shared/base.mk

$(IMAGEDATA): $(IMAGECON) $(PF1_FILE) $(PF2_FILE)
	echo "imagecon = " $(IMAGECON)
	$(IMAGECON) --input $(PF1_FILE) --output out/playfield1 --output-bitplanes  --output-palette-asm  --output-palette
	$(IMAGECON) --input $(PF2_FILE) --output out/playfield2 --output-bitplanes  --output-palette-asm  --palette-offset 8 --output-palette


