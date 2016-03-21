SUBDIRS=tools/makeadf \
	tools/imagecon\
	tools/resize\
	tools/external/shrinkler\
	tools/external/doynamite68k\
	000.trackdisk\
	001.simple_image\
	002.sprite_display\
	003.music\
	004.copper_bars\
	005.copper_vert\
	006.simple_blit\
	007.masked_blit\
	008.shift_blit\
	009.anim_blit\
	010.blit_speed\
	011.ehb_mode\
	012.ham_mode\
	013.dithered_ham\
	014.lace_mode\
	015.sliced_ham\
	016.copper_fun\
	017.dual_playfield\
	018.vert_scroll\
	019.hori_scroll\
	020.shrinkler\
	021.calling_c\
	022.photons_bootloader

.PHONY: subdirs $(SUBDIRS)

all: subdirs

clean:
	for dir in $(SUBDIRS); do \
		echo Cleaning $$dir; \
		make -C $$dir clean; \
	done
	rm -f *~

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
	@echo "Testing tools/resize..."	
	@echo "-------------------------"
	make -C tools/resize test
	@echo ""
	@echo ""
	@echo ""

$(SUBDIRS):
	@echo ""
	make -C $@

