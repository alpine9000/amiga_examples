SCREEN_WIDTH		equ 320
SCREEN_HEIGHT		equ (256+(256*INTERLACE))
SCREEN_WIDTH_BYTES	equ (SCREEN_WIDTH/8)
			if HAM_MODE==1
SCREEN_BIT_DEPTH	equ 6
			else
SCREEN_BIT_DEPTH	equ 5
			endif
SCREEN_RES		equ 8 	; 8=lo resolution, 4=hi resolution
RASTER_X_START		equ $81	; hard coded coordinates from hardware manual
RASTER_Y_START		equ $2c
RASTER_X_STOP		equ RASTER_X_START+SCREEN_WIDTH
RASTER_Y_STOP		equ RASTER_Y_START+256
