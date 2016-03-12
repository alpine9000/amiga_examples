FLOPPY=bin/copper_fun.adf
EXTRA=out/copper-new.s
LIBS=`GraphicsMagick-config --ldflags --libs`
MODULE=copper_fun.s
BASE_ADDRESS=10000
include ../shared/base.mk

out/copper-new.s: assets/test.gif out/copper_fun_generate
	rm -f out/*.png
	/opt/ImageMagick/bin/convert assets/test.gif out/%05d.png
	./convert.sh > out/copper-new.s

out/copper_fun_generate: copper_fun_generate.c Makefile
	gcc $(HOST_CFLAGS) `GraphicsMagick-config --cppflags` copper_fun_generate.c  -o out/copper_fun_generate $(LIBS)

