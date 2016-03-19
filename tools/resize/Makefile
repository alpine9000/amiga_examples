PROGRAM=./out/resize
OBJS=out/resize.o
LIBS=`GraphicsMagick-config --ldflags --libs`
EXTRA_CFLAGS=`GraphicsMagick-config --cppflags`

include ../../shared/tools.mk

TEST_IMAGE=../../assets/gigi_full.png
RESIZED_IMAGE=out/gigi.png
RESIZED_LACED=out/gigi_laced.png
REFERENCE_IMAGE=reference/gigi.png
REFERENCE_LACED=reference/gigi_laced.png
TEST_IMAGE2=../../assets/Amiga2000.png
RESIZED_IMAGE2=out/Amiga2000.png
REFERENCE_IMAGE2=reference/Amiga2000.png
RESIZED_LACED2=out/Amiga2000_laced.png
REFERENCE_LACED2=reference/Amiga2000_laced.png

ODD_SIZE_IMAGE=../../assets/mr.png
REFERENCE_ODD_SIZE=reference/mr.png
ODD_SIZE=out/mr.png


$(RESIZED_IMAGE): $(TEST_IMAGE) $(PROGRAM) Makefile
	$(PROGRAM) --width=320 --height=256 --blur=0.75 --input=$(TEST_IMAGE) --output=$(RESIZED_IMAGE)

$(RESIZED_IMAGE2): $(TEST_IMAGE2) $(PROGRAM) Makefile
	$(PROGRAM) --width=320 --height=256 --blur=0.75 --input=$(TEST_IMAGE2) --output=$(RESIZED_IMAGE2)

$(RESIZED_LACED): $(TEST_IMAGE) $(PROGRAM) Makefile
	$(PROGRAM) --width=320 --height=512 --interlaced --blur=0.75 --input=$(TEST_IMAGE) --output=$(RESIZED_LACED)

$(RESIZED_LACED2): $(TEST_IMAGE2) $(PROGRAM) Makefile
	$(PROGRAM) --width=320 --height=512 --interlaced --blur=0.75 --input=$(TEST_IMAGE2) --output=$(RESIZED_LACED2)

$(ODD_SIZE): $(ODD_SIZE_IMAGE) $(PROGRAM) Makefile
	$(PROGRAM) --width=320 --height=512 --interlaced --blur=0.75 --input=$(ODD_SIZE_IMAGE) --output=$(ODD_SIZE)

test: $(RESIZED_IMAGE) $(RESIZED_LACED) $(RESIZED_IMAGE2) $(RESIZED_LACED2) $(ODD_SIZE)
	diff $(RESIZED_IMAGE) $(REFERENCE_IMAGE)
	diff $(RESIZED_LACED) $(REFERENCE_LACED)
	diff $(RESIZED_IMAGE2) $(REFERENCE_IMAGE2)
	diff $(RESIZED_LACED2) $(REFERENCE_LACED2)
	diff $(ODD_SIZE) $(REFERENCE_ODD_SIZE)
	@echo "______  ___   _____ _____ ___________  "
	@echo "| ___ \/ _ \ /  ___/  ___|  ___|  _  \ "
	@echo "| |_/ / /_\ \\\\\ \`--.\ \`--.| |__ | | | | "
	@echo "|  __/|  _  | \`--. \\\`--. \  __|| | | | "
	@echo "| |   | | | |/\__/ /\__/ / |___| |/ /  "
	@echo "\_|   \_| |_/\____/\____/\____/|___/   "