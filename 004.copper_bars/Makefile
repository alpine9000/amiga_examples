FLOPPY=bin/copper_bars.adf
EXTRA=out/copper-list.s

MODULE=copper.s

include ../base.mk

out/copper-list.s: out/copper_gen
	./out/copper_gen  > out/copper-list.s

out/copper_gen: copper_gen.c
	gcc $(HOST_CFLAGS) copper_gen.c -o out/copper_gen

