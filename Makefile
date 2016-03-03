SUBDIRS=tools/makeadf \
	tools/imagecon\
	000.trackdisk\
	001.simple_image\
	002.sprite_display\
	003.music\
	004.copper_bars\
	005.copper_vert\
	006.simple_blit

.PHONY: subdirs $(SUBDIRS)

all: subdirs

clean:
	for dir in $(SUBDIRS); do \
		echo Cleaning $$dir; \
		make -C $$dir clean; \
	done

subdirs: $(SUBDIRS)

test:
	@echo ""
	@echo ""
	@echo ""
	@echo "Testing tools/makeadf..."	
	@echo "------------------------"
	make -C tools/makeadf test
	@echo ""
	@echo ""
	@echo ""
	@echo "Testing tools/imagecon..."	
	@echo "-------------------------"
	make -C tools/imagecon test
	@echo ""
	@echo ""
	@echo ""

$(SUBDIRS):
	@echo ""
	make -C $@

