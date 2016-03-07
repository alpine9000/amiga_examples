MODULE=masked_blit.s
FLOPPY=bin/mask_blit.adf
IMAGEDATA=out/image-palette.s out/image.bin
IMAGEFILE=../assets/mission-beach.png
BOB_BASE=out/emoji
BOB_IMAGEDATA=$(BOB_BASE).bin $(BOB_BASE)-mask.bin
BOB_IMAGEFILE=../assets/emoji.png
EXTRA=$(IMAGEDATA) $(BOB_IMAGEDATA)
SHARED_PALETTE_BASE=out/shared-palette
SHARED_PALETTE=$(SHARED_PALETTE_BASE).pal

include ../shared/base.mk

$(SHARED_PALETTE): $(IMAGEFILE) $(BOB_IMAGEFILE)
	$(IMAGECON) --input $(IMAGEFILE),$(BOB_IMAGEFILE) --output $(SHARED_PALETTE_BASE) --colors 32 --quantize --output-palette

$(IMAGEDATA): $(IMAGECON) $(IMAGEFILE) $(SHARED_PALETTE)
	$(IMAGECON) --input $(IMAGEFILE) --output out/image --output-bitplanes --output-palette-asm --use-palette $(SHARED_PALETTE) --colors 32

$(BOB_IMAGEDATA): $(IMAGECON) $(BOB_IMAGEFILE) $(SHARED_PALETTE)
	$(IMAGECON) --input $(BOB_IMAGEFILE) --output $(BOB_BASE) --output-bitplanes --use-palette $(SHARED_PALETTE) --colors 32
	$(IMAGECON) --input $(BOB_IMAGEFILE) --output $(BOB_BASE) --output-mask  --quantize --colors 32
