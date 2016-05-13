copperList:
panelCopperListBpl1Ptr:	
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0		
	dc.w    BPLCON1,0
	dc.w	DDFSTRT,(RASTER_X_START/2-SCREEN_RES)
	dc.w	DDFSTOP,(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1))
	dc.w	BPLCON0,(4<<12)|COLOR_ON ; 4 bit planes
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*4-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*4-SCREEN_WIDTH_BYTES
panelCopperPalettePtr:	
	include "out/panel-copper-list.s"
	dc.w    $5bd1,$fffe


	dc.w	BPL1MOD,BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES-2
	dc.w	BPL2MOD,BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES-2	
	
	dc.w    BPLCON1
copperListScrollPtr:	
	dc.w	0
copperListBpl1Ptr:
	;; this is where bitplanes are assigned to playfields
	;; http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0079.html
	;; 3 bitplanes per playfield, playfield1 gets bitplanes 1,3,5
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
copperListBpl2Ptr:
	;; 3 bitplanes per playfield, playfield2 gets bitplanes 2,4,6
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0

	dc.w	DDFSTRT,(RASTER_X_START/2-SCREEN_RES)-8 ; -8 for extra scrolling word
	dc.w	DDFSTOP,(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1))	
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH*2<<12)|COLOR_ON|DBLPF	

	
	if TIMING_TEST=1
	dc.l	$fffffffe
	endif


playAreaCopperPalettePtr1:	
	;; the foreground color values are just place holders and will be poked with the correcr value
	include "out/foreground-copper-list.s"
	include "out/background-copper-list.s"	

	;; top flag row has it's own palette
	dc.w    $84d1
	dc.w	$fffe		
flagsCopperPalettePtr1:
	;; the foreground color values are just place holders and will be poked with the correcr value	
	include "out/foreground-copper-list.s"
	include "out/background-copper-list.s"
	dc.w    $94d1
	dc.w	$fffe
	;; 

	
playAreaCopperPalettePtr2:
	;; the foreground color values are just place holders and will be poked with the correcr value	
	include "out/foreground-copper-list.s"
	include "out/background-copper-list.s"		
	

	;; bottom flag row has it's own palette
	dc.w    $f4d1
	dc.w	$fffe		
flagsCopperPalettePtr2:
	;; the foreground color values are just place holders and will be poked with the correcr value	
	include "out/foreground-copper-list.s"
	include "out/background-copper-list.s"
	dc.w    $ffdf
	dc.w	$fffe
	dc.w    $04d1
	dc.w	$fffe	

playAreaCopperPalettePtr3:
	;; the foreground color values are just place holders and will be poked with the correcr value	
	include "out/foreground-copper-list.s"
	include "out/background-copper-list.s"
	
	
	dc.l	$fffffffe


mpanelCopperList:
panelCopperListBpl1Ptr_MP:	
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0		
	dc.w    BPLCON1,0
	dc.w	DDFSTRT,(RASTER_X_START/2-SCREEN_RES)
	dc.w	DDFSTOP,(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1))
	dc.w	BPLCON0,(4<<12)|COLOR_ON ; 4 bit planes
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*4-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*4-SCREEN_WIDTH_BYTES
	include "out/panel-grey-copper.s"
	dc.w    $5bd1,$fffe


	dc.w	BPL1MOD,BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES-2
	dc.w	BPL2MOD,BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES-2	
	
	dc.w    BPLCON1
copperListScrollPtr_MP:	
	dc.w	0
copperListBpl1Ptr_MP:
	;; this is where bitplanes are assigned to playfields
	;; http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0079.html
	;; 3 bitplanes per playfield, playfield1 gets bitplanes 1,3,5
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
	
copperListBpl2Ptr_MP:
	;; 3 bitplanes per playfield, playfield2 gets bitplanes 2,4,6
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0

	dc.w	DDFSTRT,(RASTER_X_START/2-SCREEN_RES)-8 ; -8 for extra scrolling word
	dc.w	DDFSTOP,(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1))	
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH*2<<12)|COLOR_ON|DBLPF	


playAreaCopperPalettePtr1_MP:	
	include "out/foreground-grey-copper.s"
	include "out/background-grey-copper.s"
	
	dc.w    $84d1
	dc.w	$fffe		
flagsCopperPalettePtr1_MP:	
	include "out/foreground-grey-copper.s"
	include "out/background-grey-copper.s"	
	dc.w    $94d1
	dc.w	$fffe

playAreaCopperPalettePtr2_MP:	
	include "out/foreground-grey-copper.s"
	include "out/background-grey-copper.s"
	
	
mpanelWaitLinePtr:	
	dc.w    MPANEL_COPPER_WAIT
	dc.w	$fffe

mpanelCopperListBpl1Ptr:	
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0		
	dc.w    BPLCON1,0
	dc.w	DDFSTRT,(RASTER_X_START/2-SCREEN_RES)
	dc.w	DDFSTOP,(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1))
	dc.w	BPLCON0,(4<<12)|COLOR_ON ; 4 bit planes
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*4-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*4-SCREEN_WIDTH_BYTES
mpanelCopperPalettePtr_MP:	
	include "out/mpanel-copper-list.s"
	
	dc.w    $BAd1,$fffe


	dc.w	BPL1MOD,BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES-2
	dc.w	BPL2MOD,BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES-2	
	
	dc.w    BPLCON1
copperListScrollPtr2_MP:	
	dc.w	0
copperListBpl1Ptr2_MP:
	;; this is where bitplanes are assigned to playfields
	;; http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0079.html
	;; 3 bitplanes per playfield, playfield1 gets bitplanes 1,3,5
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0

copperListBpl2Ptr2_MP:
	;; 3 bitplanes per playfield, playfield2 gets bitplanes 2,4,6
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0

	dc.w	DDFSTRT,(RASTER_X_START/2-SCREEN_RES)-8 ; -8 for extra scrolling word
	dc.w	DDFSTOP,(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1))	
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH*2<<12)|COLOR_ON|DBLPF	

playAreaCopperPalettePtr3_MP:	
	include "out/foreground-grey-copper.s"
	include "out/background-grey-copper.s"


	dc.w    $f4d1
	dc.w	$fffe		
flagsCopperPalettePtr2_MP:	
	include "out/foreground-grey-copper.s"
	include "out/background-grey-copper.s"
	dc.w    $ffdf
	dc.w	$fffe
	dc.w    $04d1
	dc.w	$fffe	

playAreaCopperPalettePtr4_MP:	
	include "out/foreground-grey-copper.s"
	include "out/background-grey-copper.s"
	
	
	dc.l	$fffffffe

	xdef	copperList
	xdef	mpanelCopperList
	xdef	mpanelCopperListBpl1Ptr
	xdef	copperListBpl1Ptr
	xdef	copperListBpl2Ptr

	xdef	copperListBpl1Ptr_MP
	xdef	copperListBpl1Ptr2_MP
	xdef	copperListBpl2Ptr_MP
	xdef	copperListBpl2Ptr2_MP

