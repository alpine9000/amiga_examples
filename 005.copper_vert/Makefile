FLOPPY=bin/copper_vert.adf
EXTRA=out/copper-list.s

MODULE=copper_vert.s

include ../shared/base.mk

out/copper-list.s: out/copper_gen_vert
	./out/copper_gen_vert  > out/copper-list.s

out/copper_gen_vert: copper_gen_vert.c
	gcc $(HOST_CFLAGS) copper_gen_vert.c -o out/copper_gen_vert

