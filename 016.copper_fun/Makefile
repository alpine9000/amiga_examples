FLOPPY=bin/copper_fun.adf
EXTRA=out/copper-new.s
LIBS=`GraphicsMagick-config --ldflags --libs`
MODULE=copper_fun.s
BASE_ADDRESS=10000
GIF_FILE=assets/test.gif
RUN_SCRIPT=$(A500_RUN_SCRIPT)
FRAMERATE=10
VASM_EXTRA_ARGS=-DFRAMERATE=$(FRAMERATE)
IMAGE_MAGIK_CONVERT=/opt/ImageMagick/bin/convert
include ../shared/base.mk

out/copper-new.s: $(GIF_FILE) out/copper_fun_generate convert.sh
	rm -f out/*.png
	$(IMAGE_MAGIK_CONVERT) $(GIF_FILE) out/%05d.png
	./convert.sh > out/copper-new.s

out/copper_fun_generate: copper_fun_generate.c Makefile
	gcc -Wno-ignored-attributes $(HOST_CFLAGS) `GraphicsMagick-config --cppflags` copper_fun_generate.c  -o out/copper_fun_generate $(LIBS)

video: GIF_FILE:=assets/video.gif
video: all

vgo: RUN_SCRIPT:=$(A600_RUN_SCRIPT)
vgo: video go
