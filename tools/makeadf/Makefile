PROGRAM=./out/makeadf
OBJS=./out/makeadf.o

include ../../shared/tools.mk

test: $(PROGRAM)
	$(PROGRAM) reference/bootblock.bin > out/test.adf
	diff reference/test.adf out/test.adf
	@echo "______  ___   _____ _____ ___________  "
	@echo "| ___ \/ _ \ /  ___/  ___|  ___|  _  \ "
	@echo "| |_/ / /_\ \\\\\ \`--.\ \`--.| |__ | | | | "
	@echo "|  __/|  _  | \`--. \\\`--. \  __|| | | | "
	@echo "| |   | | | |/\__/ /\__/ / |___| |/ /  "
	@echo "\_|   \_| |_/\____/\____/\____/|___/   "