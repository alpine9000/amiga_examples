NUM_COLORS=2
MODULE=blit_speed.s
FLOPPY=bin/blit_speed.adf
IMAGEDATA=out/image-palette.s out/image.bin
IMAGEFILE=../assets/mission-beach.png
BOB_BASE=out/emoji
BOB_IMAGEDATA=$(BOB_BASE).bin $(BOB_BASE)-mask.bin
BOB_IMAGEFILE=../assets/emoji.png
EXTRA=$(IMAGEDATA) $(BOB_IMAGEDATA) blit.s init.s utils.s constants.i Makefile
SHARED_PALETTE_BASE=out/shared-palette
SHARED_PALETTE=$(SHARED_PALETTE_BASE).pal
VASM_EXTRA_ARGS=-DSCREEN_COLORS=$(NUM_COLORS)

include ../shared/base.mk

$(SHARED_PALETTE): $(IMAGEFILE) $(BOB_IMAGEFILE) Makefile
	$(IMAGECON) --input $(IMAGEFILE),$(BOB_IMAGEFILE) --output $(SHARED_PALETTE_BASE) --colors $(NUM_COLORS) --quantize --output-palette

$(IMAGEDATA): $(IMAGECON) $(IMAGEFILE) $(SHARED_PALETTE) Makefile
	$(IMAGECON) --input $(IMAGEFILE) --output out/image --output-bitplanes --output-grey-palette-asm --output-palette-asm --use-palette $(SHARED_PALETTE)

$(BOB_IMAGEDATA): $(IMAGECON) $(BOB_IMAGEFILE) $(SHARED_PALETTE) Makefile
	$(IMAGECON) --input $(BOB_IMAGEFILE) --output $(BOB_BASE) --output-bitplanes --use-palette $(SHARED_PALETTE)
	$(IMAGECON) --input $(BOB_IMAGEFILE) --output $(BOB_BASE) --colors $(NUM_COLORS) --output-mask  --quantize
