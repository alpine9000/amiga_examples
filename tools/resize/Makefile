PROGRAM=./out/resize
OBJS=out/resize.o
WARN_ERROR=-Werror
HOST_WARNINGS=$(WARN_ERROR) -pedantic-errors -Wfatal-errors -Wall  -Wextra -Wno-unused-parameter -Wshadow -limagequant
HOST_CFLAGS=$(HOST_WARNINGS) -O3 `GraphicsMagick-config --cppflags`
LIBS=`GraphicsMagick-config --ldflags --libs`

TEST_IMAGE=../../assets/gigi_full.png
RESIZED_IMAGE=out/gigi.png
RESIZED_LACED=out/gigi_laced.png
REFERENCE_IMAGE=reference/gigi.png
REFERENCE_LACED=reference/gigi_laced.png

$(PROGRAM): out bin $(OBJS) 
	gcc $(OBJS) -o $(PROGRAM) $(LIBS)

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

clean:
	rm -rf out bin *~

$(RESIZED_IMAGE): $(TEST_IMAGE) $(PROGRAM) Makefile
	$(PROGRAM) --width=320 --height=256 --blur=0.75 --input=$(TEST_IMAGE) --output=$(RESIZED_IMAGE)

$(RESIZED_LACED): $(TEST_IMAGE) $(PROGRAM) Makefile
	$(PROGRAM) --width=320 --height=512 --interlaced --blur=0.75 --input=$(TEST_IMAGE) --output=$(RESIZED_LACED)

test: $(RESIZED_IMAGE) $(RESIZED_LACED)
	diff $(RESIZED_IMAGE) $(REFERENCE_IMAGE);
	diff $(RESIZED_LACED) $(REFERENCE_LACED);
	@echo "______  ___   _____ _____ ___________  "
	@echo "| ___ \/ _ \ /  ___/  ___|  ___|  _  \ "
	@echo "| |_/ / /_\ \\\\\ \`--.\ \`--.| |__ | | | | "
	@echo "|  __/|  _  | \`--. \\\`--. \  __|| | | | "
	@echo "| |   | | | |/\__/ /\__/ / |___| |/ /  "
	@echo "\_|   \_| |_/\____/\____/\____/|___/   "