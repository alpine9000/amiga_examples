PROGRAM=./out/croppa
OBJS=out/croppa.o
LIBS=`GraphicsMagick-config --ldflags --libs`
EXTRA_CFLAGS=`GraphicsMagick-config --cppflags`

include ../../shared/tools.mk

TEST_IMAGE=../../assets/gigi_full.png
CROPPED_IMAGE=cropped

out/$(CROPPED_IMAGE): $(TEST_IMAGE) $(PROGRAM) Makefile
	$(PROGRAM) --input=$(TEST_IMAGE) --output=out/$(CROPPED_IMAGE) --width=16 --height=16 --rows=2 --cols=2 --dx=16 --dy=16 --x=192 --y=112


test: out/$(CROPPED_IMAGE)
	diff out/$(CROPPED_IMAGE)-0.png reference/$(CROPPED_IMAGE)-0.png
	diff out/$(CROPPED_IMAGE)-1.png reference/$(CROPPED_IMAGE)-1.png
	diff out/$(CROPPED_IMAGE)-2.png reference/$(CROPPED_IMAGE)-2.png
	diff out/$(CROPPED_IMAGE)-3.png reference/$(CROPPED_IMAGE)-3.png
	@echo "______  ___   _____ _____ ___________  "
	@echo "| ___ \/ _ \ /  ___/  ___|  ___|  _  \ "
	@echo "| |_/ / /_\ \\\\\ \`--.\ \`--.| |__ | | | | "
	@echo "|  __/|  _  | \`--. \\\`--. \  __|| | | | "
	@echo "| |   | | | |/\__/ /\__/ / |___| |/ /  "
	@echo "\_|   \_| |_/\____/\____/\____/|___/   "