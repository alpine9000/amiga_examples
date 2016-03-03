IMAGECON=./out/imagecon
OBJS=out/imagecon.o out/png.o
HOST_WARNINGS=-pedantic-errors -Wfatal-errors -Wall -Werror -Wextra -Wno-unused-parameter -Wshadow -limagequant
HOST_CFLAGS=$(HOST_WARNINGS)
OUTPUT_BASE=out/mission-beach
REFERENCE_BASE=reference/mission-beach
TEST_IMAGE=../../assets/mission-beach.png
LIBS=-lpng -limagequant

$(IMAGECON): out bin $(OBJS) 
	gcc $(OBJS) -o $(IMAGECON) $(LIBS)


out/imagecon.o: imagecon.h
out/png.o: imagecon.h

out/%.o: %.c
	gcc -c $(HOST_CFLAGS) $< -o $@ 

out:
	mkdir out

bin:
	mkdir bin

out/mission-beach.bin: $(IMAGECON) 
	-rm -f $(OUTPUT_BASE).bin $(OUTPUT_BASE)-copper-list.s
	$(IMAGECON) --input $(TEST_IMAGE) --output $(OUTPUT_BASE) --output-copperlist --output-bitplanes --colors 32 --quantize

test: $(IMAGECON) $(OUTPUT_BASE).bin	
	diff $(OUTPUT_BASE).bin $(REFERENCE_BASE).bin	
	diff $(OUTPUT_BASE)-copper-list.s $(REFERENCE_BASE)-copper-list.s
	@echo "Success!"

clean:
	rm -rf out bin *~