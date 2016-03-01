IMAGECON=./out/imagecon
SRCS=imagecon.c
HOST_WARNINGS=-pedantic-errors -Wfatal-errors -Wall -Werror -Wextra -Wno-unused-parameter -Wshadow -limagequant
HOST_CFLAGS=$(HOST_WARNINGS)
OUTPUT_BASE=out/mission-beach
REFERENCE_BASE=reference/mission-beach
TEST_IMAGE=../../assets/mission-beach.png

$(IMAGECON): out bin $(SRCS)
	gcc $(HOST_CFLAGS) $(SRCS) -o $(IMAGECON) -lpng

out:
	mkdir out

bin:
	mkdir bin

out/mission-beach.bin: $(IMAGECON) 
	-rm -f $(OUTPUT_BASE).bin $(OUTPUT_BASE)-copper-list.s
	$(IMAGECON) --input $(TEST_IMAGE) --output $(OUTPUT_BASE) --colors 32

test: $(IMAGECON) $(OUTPUT_BASE).bin	
	diff $(OUTPUT_BASE).bin $(REFERENCE_BASE).bin	
	diff $(OUTPUT_BASE)-copper-list.s $(REFERENCE_BASE)-copper-list.s
	@echo "Success!"

clean:
	rm -r out bin