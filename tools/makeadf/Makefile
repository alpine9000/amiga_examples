MAKEADF=./out/makeadf
SRCS=makeadf.c
HOST_WARNINGS=-pedantic-errors -Wfatal-errors -Wall -Werror -Wextra -Wno-unused-parameter -Wshadow
HOST_CFLAGS=$(HOST_WARNINGS)

$(MAKEADF): out bin $(SRCS)
	gcc $(HOST_CFLAGS) $(SRCS) -o $(MAKEADF)

out:
	mkdir out

bin:
	mkdir bin

clean:
	rm -r out bin *~

test: $(MAKEADF)
	$(MAKEADF) reference/bootblock.bin > out/test.adf
	diff reference/test.adf out/test.adf
	@echo "______  ___   _____ _____ ___________  "
	@echo "| ___ \/ _ \ /  ___/  ___|  ___|  _  \ "
	@echo "| |_/ / /_\ \\\\\ \`--.\ \`--.| |__ | | | | "
	@echo "|  __/|  _  | \`--. \\\`--. \  __|| | | | "
	@echo "| |   | | | |/\__/ /\__/ / |___| |/ /  "
	@echo "\_|   \_| |_/\____/\____/\____/|___/   "