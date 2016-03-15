PROGRAM=./out/makeadf
OBJS=./out/makeadf.o

include ../../shared/tools.mk

test: $(PROGRAM)
	$(PROGRAM) reference/bootblock.bin > out/test.adf
	diff reference/test.adf out/test.adf
	$(PROGRAM) reference/big.bin > out/big.adf; if [ $$? -eq 2 ] ; then echo "Correctly determined that inut will not fit on a floppy..."; else (exit 2); fi 
	@echo "______  ___   _____ _____ ___________  "
	@echo "| ___ \/ _ \ /  ___/  ___|  ___|  _  \ "
	@echo "| |_/ / /_\ \\\\\ \`--.\ \`--.| |__ | | | | "
	@echo "|  __/|  _  | \`--. \\\`--. \  __|| | | | "
	@echo "| |   | | | |/\__/ /\__/ / |___| |/ /  "
	@echo "\_|   \_| |_/\____/\____/\____/|___/   "