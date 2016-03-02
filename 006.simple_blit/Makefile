MODULE=blit.s
FLOPPY=bin/blit.adf
IMAGEDATA=out/image-copper-list.s out/image.bin
IMAGEFILE=../assets/mission-beach.png
TC_IMAGEDATA=out/tc.bin out/tc-mask.bin
TC_IMAGEFILE=../assets/tc.png
EXTRA=$(IMAGEDATA) $(TC_IMAGEDATA) out/bitblit.s

include ../base.mk

out/bitblit.s: bitblit.c
	vc -S bitblit.c -o out/bitblit.s

$(IMAGEDATA): $(IMAGECON) $(IMAGEFILE)
	$(IMAGECON) --input $(IMAGEFILE) --output out/image --colors 32 --quantize

$(TC_IMAGEDATA): $(IMAGECON) $(TC_IMAGEFILE)
	$(IMAGECON) --input $(TC_IMAGEFILE) --output out/tc --colors 32 --quantize --output-mask
