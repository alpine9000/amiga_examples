MODULE=blit.s
FLOPPY=bin/blit.adf
IMAGEDATA=out/image-palette.s out/image.bin
IMAGEFILE=../assets/mission-beach.png
TC_IMAGEDATA=out/tc.bin out/tc-mask.bin
TC_IMAGEFILE=../assets/tc.png
EXTRA=$(IMAGEDATA) $(TC_IMAGEDATA)
SHARED_PALETTE_BASE=out/shared-palette
SHARED_PALETTE=$(SHARED_PALETTE_BASE).pal

include ../base.mk

$(SHARED_PALETTE): $(IMAGEFILE) $(TC_IMAGEFILE)
	$(IMAGECON) --input $(IMAGEFILE),$(TC_IMAGEFILE) --output $(SHARED_PALETTE_BASE) --colors 32 --quantize --output-palette

$(IMAGEDATA): $(IMAGECON) $(IMAGEFILE) $(SHARED_PALETTE)
	$(IMAGECON) --input $(IMAGEFILE) --output out/image --output-bitplanes --output-palette-asm --use-palette $(SHARED_PALETTE)

$(TC_IMAGEDATA): $(IMAGECON) $(TC_IMAGEFILE) $(SHARED_PALETTE)
	$(IMAGECON) --input $(TC_IMAGEFILE) --output out/tc --output-bitplanes --output-mask  --use-palette $(SHARED_PALETTE)
