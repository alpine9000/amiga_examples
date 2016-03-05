IMAGECON=./out/imagecon
OBJS=out/imagecon.o out/png.o
HOST_WARNINGS=-pedantic-errors -Wfatal-errors -Wall -Werror -Wextra -Wno-unused-parameter -Wshadow -limagequant
HOST_CFLAGS=$(HOST_WARNINGS)
LIBS=-lpng -limagequant

# test stuff
OUTPUT_BASE=out/mission-beach
REFERENCE_BASE=reference/mission-beach
TEST_IMAGE=../../assets/mission-beach.png
TEST_IMAGE2=../../assets/tc.png
BOB_IMAGE=../../assets/emoji.png
SHARED_BASE=out/shared
BOB_BASE=out/bob
REFERENCE_BOB_BASE=reference/bob
REFERENCE_SHARED_BASE=reference/shared
REFERENCE_SHARED_PALETTE=$(REFERENCE_SHARED_BASE).pal
SHARED_PALETTE=$(SHARED_BASE).pal
USED_PALETTE=$(SHARED_BASE).bin $(SHARED_BASE)-copper-list.s

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

$(USED_PALETTE): $(SHARED_PALETTE)
	$(IMAGECON) --input $(TEST_IMAGE),$(TEST_IMAGE2) --output $(SHARED_BASE) --colors 32 --quantize --output-bitplanes --output-copperlist

$(SHARED_PALETTE): $(IMAGECON)
	-rm -f $(SHARED_PALETTE)
	$(IMAGECON) --input $(TEST_IMAGE),$(TEST_IMAGE2) --output $(SHARED_BASE) --colors 32 --quantize --output-palette

$(OUTPUT_BASE).bin: $(IMAGECON) 
	-rm -f $(OUTPUT_BASE).bin $(OUTPUT_BASE)-copper-list.s $(OUTPUT_BASE)-palette.s 
	$(IMAGECON) --input $(TEST_IMAGE) --output $(OUTPUT_BASE) --output-copperlist --output-bitplanes --output-grey-palette --output-palette-asm --colors 32 --quantize
	$(IMAGECON) --input $(BOB_IMAGE) --output $(BOB_BASE) --output-mask --colors 32 --quantize

test: $(IMAGECON) $(OUTPUT_BASE).bin $(SHARED_PALETTE) $(USED_PALETTE)
	diff $(OUTPUT_BASE).bin $(REFERENCE_BASE).bin	
	diff $(OUTPUT_BASE)-copper-list.s $(REFERENCE_BASE)-copper-list.s
	diff $(OUTPUT_BASE)-palette.s $(REFERENCE_BASE)-palette.s
	diff $(OUTPUT_BASE)-grey.s $(REFERENCE_BASE)-grey.s
	diff $(SHARED_PALETTE) $(REFERENCE_SHARED_PALETTE)
	diff $(SHARED_BASE).bin $(REFERENCE_SHARED_BASE).bin	
	diff $(SHARED_BASE)-copper-list.s $(REFERENCE_SHARED_BASE)-copper-list.s
	diff $(BOB_BASE)-mask.bin $(REFERENCE_BOB_BASE)-mask.bin

	@echo "______  ___   _____ _____ ___________  "
	@echo "| ___ \/ _ \ /  ___/  ___|  ___|  _  \ "
	@echo "| |_/ / /_\ \\\\\ \`--.\ \`--.| |__ | | | | "
	@echo "|  __/|  _  | \`--. \\\`--. \  __|| | | | "
	@echo "| |   | | | |/\__/ /\__/ / |___| |/ /  "
	@echo "\_|   \_| |_/\____/\____/\____/|___/   "

clean:
	rm -rf out bin *~