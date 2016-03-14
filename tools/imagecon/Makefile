PROGRAM=./out/imagecon
OBJS=out/imagecon.o out/png.o out/color.o out/dither.o out/ham.o out/palette.o out/file.o out/sliced_ham.o out/quant.o out/utils.o
LIBS=-lpng -limagequant

include ../../shared/tools.mk

# Simple 32 color quantize
32COLOR_QUANT=32color-quant.png
out/$(32COLOR_QUANT).bin: IMAGECON_ARGS=--output-copperlist --output-bitplanes --output-grey-palette --output-palette-asm --colors 32 --quantize --output-palette --output-png

# Using a previously generated palette
USE_PALETTE=use_palette.png
out/$(USE_PALETTE).bin: IMAGECON_ARGS=--output-bitplanes --output-palette-asm --use-palette out/$(32COLOR_QUANT).pal --output-palette --quantize

# Extra half brite mode
EXTRA_HALF_BRITE=extra_half_brite.png
out/$(EXTRA_HALF_BRITE).bin: IMAGECON_ARGS=--extra-half-brite --output-bitplanes --output-palette-asm  --output-palette --quantize --output-copperlist --colors=32 --quantize

# HAM mode
HAM_MODE=ham_mode.png
out/$(HAM_MODE).bin: IMAGECON_ARGS=--output-bitplanes --ham --output-palette-asm

# Dithered HAM mode
DITHERED_HAM=dithered_ham.png
out/$(DITHERED_HAM).bin: IMAGECON_ARGS=--dither --output-bitplanes --ham --output-palette-asm

# Laced dithered HAM mode
LACE_MODE=lace.png
out/$(LACE_MODE).bin: IMAGECON_ARGS=--dither --output-bitplanes --ham --output-palette-asm

# Two images, sharing a palette
SHARED_PALETTE=shared_palette.png


# default recipe for converting images
out/%.bin: test-images/% Makefile
	$(PROGRAM) --input $< --output out/$* $(IMAGECON_ARGS)

# special case for shared palette
out/$(SHARED_PALETTE).bin: $(PROGRAM)
	$(PROGRAM) --input test-images/$(32COLOR_QUANT),test-images/bob.png --output out/$(SHARED_PALETTE) --colors 32 --quantize --output-palette --output-bitplanes


test: $(PROGRAM) out/$(32COLOR_QUANT).bin out/$(USE_PALETTE).bin out/$(SHARED_PALETTE).bin out/$(EXTRA_HALF_BRITE).bin out/$(HAM_MODE).bin out/$(DITHERED_HAM).bin out/$(LACE_MODE).bin
	diff out/$(32COLOR_QUANT).bin reference/$(32COLOR_QUANT).bin
	diff out/$(32COLOR_QUANT)-copper-list.s reference/$(32COLOR_QUANT)-copper-list.s
	diff out/$(32COLOR_QUANT)-grey.s reference/$(32COLOR_QUANT)-grey.s
	diff out/$(32COLOR_QUANT)-palette.s reference/$(32COLOR_QUANT)-palette.s
	diff out/$(32COLOR_QUANT).pal reference/$(32COLOR_QUANT).pal
	diff out/$(32COLOR_QUANT)-converted.png reference/$(32COLOR_QUANT)-converted.png

	diff out/$(USE_PALETTE).bin reference/$(USE_PALETTE).bin

	diff out/$(SHARED_PALETTE).bin reference/$(SHARED_PALETTE).bin
	diff out/$(SHARED_PALETTE).pal reference/$(SHARED_PALETTE).pal

	diff out/$(EXTRA_HALF_BRITE).bin reference/$(EXTRA_HALF_BRITE).bin
	diff out/$(EXTRA_HALF_BRITE)-copper-list.s reference/$(EXTRA_HALF_BRITE)-copper-list.s
	diff out/$(EXTRA_HALF_BRITE)-palette.s reference/$(EXTRA_HALF_BRITE)-palette.s
	diff out/$(EXTRA_HALF_BRITE).pal reference/$(EXTRA_HALF_BRITE).pal

	diff out/$(HAM_MODE)-ham.bin reference/$(HAM_MODE)-ham.bin
	diff out/$(HAM_MODE)-palette.s reference/$(HAM_MODE)-palette.s

	diff out/$(DITHERED_HAM)-ham.bin reference/$(DITHERED_HAM)-ham.bin
	diff out/$(DITHERED_HAM)-palette.s reference/$(DITHERED_HAM)-palette.s

	diff out/$(LACE_MODE)-ham.bin reference/$(LACE_MODE)-ham.bin
	diff out/$(LACE_MODE)-palette.s reference/$(LACE_MODE)-palette.s

	@echo "______  ___   _____ _____ ___________  "
	@echo "| ___ \/ _ \ /  ___/  ___|  ___|  _  \ "
	@echo "| |_/ / /_\ \\\\\ \`--.\ \`--.| |__ | | | | "
	@echo "|  __/|  _  | \`--. \\\`--. \  __|| | | | "
	@echo "| |   | | | |/\__/ /\__/ / |___| |/ /  "
	@echo "\_|   \_| |_/\____/\____/\____/|___/   "
	