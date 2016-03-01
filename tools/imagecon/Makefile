IMAGECON=./bin/imagecon
SRCS=imagecon.c
HOST_WARNINGS=-pedantic-errors -Wfatal-errors -Wall -Werror -Wextra -Wno-unused-parameter -Wshadow -limagequant
HOST_CFLAGS=$(HOST_WARNINGS)

$(IMAGECON): out bin $(SRCS)
	gcc $(HOST_CFLAGS) $(SRCS) -o $(IMAGECON) -lpng

out:
	mkdir out

bin:
	mkdir bin

out/bitplane.bin: $(IMAGECON) 
	-rm -f out/bitplane.bin out/hello-copper-list.s
	$(IMAGECON) ../../assets/hello.png out/hello

test: $(IMAGECON) out/bitplane.bin	
	diff out/hello.bin reference/bitplane.bin
	diff out/hello-copper-list.s reference/copper-list.s
	@echo "Success!"

clean:
	rm -r out bin