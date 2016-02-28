MAKEADF=../tools/makeadf
FLOPPY=bin/image.adf
EXTRA=out/copper-list.s

MODULE=copper.s

include ../base.mk

out/copper-list.s: out/copper_gen
	./out/copper_gen  > out/copper-list.s

out/copper_gen: copper_gen.c
	gcc copper_gen.c -o out/copper_gen

