IMAGECON=./bin/imagecon
SRCS=imagecon.c
HOST_WARNINGS=-pedantic-errors -Wfatal-errors -Wall -Werror -Wextra -Wno-unused-parameter -Wshadow -limagequant
HOST_CFLAGS=$(HOST_WARNINGS)

imagecon: out bin $(SRCS)
	gcc $(HOST_CFLAGS) $(SRCS) -o $(IMAGECON) -lpng

out:
	mkdir out

bin:
	mkdir bin

bitplane.bin copper-list.s: bin/imagecon 
	$(IMAGECON) ../../assets/hello.png out/hello

test: imagecon bitplane.bin copper-list.s
	diff out/hello.bin reference/bitplane.bin
	diff out/hello-copper-list.s reference/copper-list.s

clean:
	rm -r out bin