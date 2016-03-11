IMAGECON=./out/imagecon
OBJS=out/imagecon.o out/png.o out/color.o out/dither.o out/ham.o out/palette.o out/file.o out/sliced_ham.o out/quant.o
WARN_ERROR=-Werror
HOST_WARNINGS=$(WARN_ERROR) -pedantic-errors -Wfatal-errors -Wall  -Wextra -Wno-unused-parameter -Wshadow -limagequant
HOST_CFLAGS=$(HOST_WARNINGS) -O3
LIBS=-lpng -limagequant

# test stuff
OUTPUT_BASE=out/mission-beach
REFERENCE_BASE=reference/mission-beach
TEST_IMAGE=../../assets/mission-beach.png
BOB_IMAGE=../../assets/emoji.png
SHARED_BASE=out/shared
BOB_BASE=out/bob
REFERENCE_BOB_BASE=reference/bob
REFERENCE_SHARED_BASE=reference/shared
REFERENCE_SHARED_PALETTE=$(REFERENCE_SHARED_BASE).pal
SHARED_PALETTE=$(SHARED_BASE).pal
USED_PALETTE=$(SHARED_BASE).bin $(SHARED_BASE)-copper-list.s

EHB_IMAGE=../../assets/gigi.png
EHB_BASE=out/ehb
REFERENCE_EHB_BASE=reference/ehb

HAM_IMAGE=../../assets/gigi.png
HAM_BASE=out/ham
REFERENCE_HAM_BASE=reference/ham

DITHERED_HAM_IMAGE=../../assets/gigi.png
DITHERED_HAM_BASE=out/dithered_ham
REFERENCE_DITHERED_HAM_BASE=reference/dithered_ham

$(IMAGECON): out bin $(OBJS) 
	gcc $(OBJS) -o $(IMAGECON) $(LIBS)

-include $(OBJS:.o=.d)

out/%.o: %.c
	gcc -c $(HOST_CFLAGS) $< -o $@ 
	@gcc -MM $(HOST_CFLAGS) $*.c > out/$*.d
	@mv -f out/$*.d out/$*.d.tmp
	@sed  's/^.*\:/out\/&/' < out/$*.d.tmp > out/$*.d
	@rm -f out/$*.d.tmp

out:
	mkdir out

bin:
	mkdir bin

$(USED_PALETTE): $(SHARED_PALETTE)
	@echo "testing use-palette"
	$(IMAGECON) --input $(TEST_IMAGE),$(BOB_IMAGE) --output $(SHARED_BASE) --use-palette $(SHARED_PALETTE) --output-bitplanes --output-copperlist

$(SHARED_PALETTE): $(IMAGECON)
	-rm -f $(SHARED_PALETTE)
	$(IMAGECON) --input $(TEST_IMAGE),$(BOB_IMAGE) --output $(SHARED_BASE) --colors 32 --quantize --output-palette

$(OUTPUT_BASE).bin: $(IMAGECON) 
	-rm -f $(OUTPUT_BASE).bin $(OUTPUT_BASE)-copper-list.s $(OUTPUT_BASE)-palette.s 
	$(IMAGECON) --input $(TEST_IMAGE) --output $(OUTPUT_BASE) --output-copperlist --output-bitplanes --output-grey-palette --output-palette-asm --colors 32 --quantize
	$(IMAGECON) --input $(BOB_IMAGE) --output $(BOB_BASE) --output-mask --colors 32 --quantize

$(EHB_BASE).bin: $(EHB_IMAGE)
	$(IMAGECON) --input $(EHB_IMAGE) --output $(EHB_BASE) --output-bitplanes --colors 32 --quantize --extra-half-brite --output-copperlist

$(HAM_BASE).bin: $(HAM_IMAGE)
	$(IMAGECON) --input $(HAM_IMAGE) --output $(HAM_BASE) --output-bitplanes --ham --output-palette-asm

$(DITHERED_HAM_BASE).bin: $(DITHERED_HAM_IMAGE)
	$(IMAGECON) --input $(DITHERED_HAM_IMAGE) --output $(DITHERED_HAM_BASE) --dither --output-bitplanes --ham --output-palette-asm

test: $(IMAGECON) $(OUTPUT_BASE).bin $(SHARED_PALETTE) $(USED_PALETTE) $(EHB_BASE).bin $(HAM_BASE).bin $(DITHERED_HAM_BASE).bin
	diff $(OUTPUT_BASE).bin $(REFERENCE_BASE).bin	
	diff $(OUTPUT_BASE)-copper-list.s $(REFERENCE_BASE)-copper-list.s
	diff $(OUTPUT_BASE)-palette.s $(REFERENCE_BASE)-palette.s
	diff $(OUTPUT_BASE)-grey.s $(REFERENCE_BASE)-grey.s
	diff $(SHARED_PALETTE) $(REFERENCE_SHARED_PALETTE)
	diff $(SHARED_BASE).bin $(REFERENCE_SHARED_BASE).bin	
	diff $(SHARED_BASE)-copper-list.s $(REFERENCE_SHARED_BASE)-copper-list.s
	diff $(BOB_BASE)-mask.bin $(REFERENCE_BOB_BASE)-mask.bin
	diff $(EHB_BASE).bin $(REFERENCE_EHB_BASE).bin
	diff $(EHB_BASE)-copper-list.s $(REFERENCE_EHB_BASE)-copper-list.s
	diff $(HAM_BASE)-ham.bin $(REFERENCE_HAM_BASE)-ham.bin
	diff $(HAM_BASE)-palette.s $(REFERENCE_HAM_BASE)-palette.s
	diff $(DITHERED_HAM_BASE)-ham.bin $(REFERENCE_DITHERED_HAM_BASE)-ham.bin
	diff $(DITHERED_HAM_BASE)-palette.s $(REFERENCE_DITHERED_HAM_BASE)-palette.s

	@echo "______  ___   _____ _____ ___________  "
	@echo "| ___ \/ _ \ /  ___/  ___|  ___|  _  \ "
	@echo "| |_/ / /_\ \\\\\ \`--.\ \`--.| |__ | | | | "
	@echo "|  __/|  _  | \`--. \\\`--. \  __|| | | | "
	@echo "| |   | | | |/\__/ /\__/ / |___| |/ /  "
	@echo "\_|   \_| |_/\____/\____/\____/|___/   "

clean:
	rm -rf out bin *~