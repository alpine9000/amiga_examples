	include "includes.i"
	
	xdef	copperList
	xdef	copperListBpl1Ptr
	xdef	copperListBpl2Ptr	
	xdef 	backgroundOnscreen
	xdef	backgroundOffscreen
	xdef	foregroundOnscreen
	xdef	foregroundOffscreen
	xdef	foregroundScrollX
	xdef	backgroundScrollX
	xdef	map
	xdef	itemsMap
	xdef   	mapSize
	xdef	moving
	xdef 	foregroundScrollPixels
	
byteMap:
	dc.l	Entry
	dc.l	endCode-byteMap

Entry:
	lea	userstack,a7
	lea 	CUSTOM,a6

	move	#$7ff,DMACON(a6)	; disable all dma
	move	#$7fff,INTENA(a6) 	; disable all interrupts		
	
	lea	Level3InterruptHandler,a3
 	move.l	a3,LVL3_INT_VECTOR			

	;; d0 - fg bitplane pointer offset
	;; d1 - bg bitplane pointer offset
	move.l	#0,d0
	move.l	#1,d1
	jsr	SwitchBuffers		
	
	move.w	#(INTF_SETCLR|INTF_VERTB|INTF_INTEN),INTENA(a6)	
 	move.w	#(DMAF_BLITTER|DMAF_SETCLR!DMAF_MASTER),DMACON(a6) 		

	lea	panelCopperListBpl1Ptr,a0
	lea	panel,a1
	jsr	PokePanelBitplanePointers
	jsr	Init		  ; enable the playfield		

	jsr	InstallSpriteColorPalette
	jsr	InstallGreyPalette
	
Reset:
	move.l	#0,foregroundScrollX
	move.l	#0,backgroundScrollX
	jsr 	BlueFill
	move.l	#-1,frameCount		

MainLoop:
	MOVE.W  #$0024,BPLCON2(a6)
	
SetupBoardLoop:
	add.l	#1,frameCount
	move.l	frameCount,d6		
	move.l	#(FOREGROUND_SCROLL_PIXELS*16)-1,foregroundScrollPixels
	;; move.l	#FOREGROUND_SCROLL_PIXELS,foregroundScrollPixels
	;; jsr	WaitVerticalBlank	
	bsr	HoriScrollPlayfield
	jsr 	SwitchBuffers	    ; takes bitplane pointer offset in d0
	move.l	foregroundScrollX,d0
	move.w	#1,moving
	bsr 	Update
	bsr	RenderNextForegroundFrame	
	;; bsr 	RenderNextBackgroundFrame			
	;; 	cmp.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS*15,frameCount
	cmp.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS,frameCount	
	bge	.gotoGameLoop
	bra	SetupBoardLoop

.gotoGameLoop:	
	jsr	WaitVerticalBlank
	bra	GameLoop
	
GameLoop:
	add.l	#1,frameCount
	move.l	frameCount,d6			

	;; cmp.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS*15+25,d6
	cmp.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS+25,d6
	bne	.c1
	move.w	#(DMAF_SPRITE|DMAF_BLITTER|DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)
	jsr	InitialisePig
.c1:
	bsr	InstallNextGreyPalette
	move.l	#FOREGROUND_SCROLL_PIXELS,foregroundScrollPixels
	jsr	WaitVerticalBlank	
	bsr	HoriScrollPlayfield
	jsr 	SwitchBuffers	    ; takes bitplane pointer offset in d0

	move.l	foregroundScrollX,d0
	lsr.l	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0 ; convert to pixels		
	and.b	#$f,d0
	cmp.b	#$f,d0
	bne	.s2
	move.w	#0,moving
.s2:
	
	jsr	ProcessJoystick
	bsr 	Update
	bsr	RenderNextForegroundFrame	
	bsr 	RenderNextBackgroundFrame			

	if 0
	 move.w	#$f00,COLOR00(a6)
	endif

	bra	GameLoop
	
Update:
	;; right
	jsr	UpdatePig
	
.backgroundUpdates:
	add.l	#BACKGROUND_SCROLL_PIXELS,backgroundScrollX		
	btst	#FOREGROUND_DELAY_BIT,d6
	beq	.skipForegroundUpdates
	;; ---- Foreground updates ----------------------------------------	
.foregroundUpdates:

	move.l	foregroundScrollX,d0
	lsr.l	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0 ; convert to pixels
	andi.l	#$f,d0

	cmp.w	#0,moving
	beq	.c1
	move.l	foregroundScrollPixels,d0
	add.l	d0,foregroundScrollX

	jsr	ScrollSprites

	move.l	foregroundScrollX,d0
	lsr.l	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0 ; convert to pixels
	andi.l	#$f,d0
	cmp.b	#0,d0
	bne	.c1
	bsr	ResetAnimPattern
	bsr	ResetDeAnimPattern
.c1:

	
.skipForegroundUpdates:
	
	rts
	
HoriScrollPlayfield:
	;; d0 - fg x position in pixels
	;; d1 - bg x position in pixels	
	;; 	movem.l	d0-d6,-(sp)
	
	move.l	backgroundScrollX,d0
	lsr.l	#BACKGROUND_SCROLL_SHIFT_CONVERT,d0		; convert to pixels	
	move.w	d0,d2
	lsr.w   #3,d0		; bytes to scroll
	and.w   #$F,d2		; pixels = 0xf - (hpos - (hpos_bytes*8))
	move.w  #$F,d0
	sub.w   d2,d0		; bits to delay	
	move.w	d0,d5		; d5 == bg bits to delay

	move.l	foregroundScrollX,d0
	lsr.l	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0		; convert to pixels
	move.w	d0,d2
	lsr.w   #3,d0		; bytes to scroll
	and.w   #$F,d2		; pixels = 0xf - (hpos - (hpos_bytes*8))
	move.w  #$F,d0
	sub.w   d2,d0		; bits to delay

	lsl.w	#4,d5
	or.w	d5,d0	

	move.w	d0,copperListScrollPtr
	;; move.w  d0,BPLCON1(a6)	
	
	;; movem.l (sp)+,d0-d6
	rts

ResetAnimPattern:
	lea	animIndex,a0
	move.l	animIndexPatternPtr,a1
	move.l	#7,d0
.loop:
	move.l	(a1)+,(a0)+
	dbra	d0,.loop
	add.l	#8,animIndexPatternPtr
	cmp.l	#$ffffffff,(a1)
	bne	.s1
	lea	animIndexPattern,a0
	move.l	a0,animIndexPatternPtr
.s1:
	rts

ResetDeAnimPattern:
	lea	deAnimIndex,a0
	move.l	deAnimIndexPatternPtr,a1
	move.l	#7,d0
.loop:
	move.l	(a1)+,(a0)+
	dbra	d0,.loop
	add.l	#8,deAnimIndexPatternPtr
	cmp.l	#$ffffffff,(a1)
	bne	.s1
	lea	deAnimIndexPattern,a0
	move.l	a0,deAnimIndexPatternPtr
.s1:
	rts	

RenderNextBackgroundFrame:
	lea	backgroundMap,a2
	move.l	backgroundScrollX,d0
	lsr.l	#BACKGROUND_SCROLL_TILE_INDEX_CONVERT,d0
	and.b	#$fe,d0
	add.l	d0,a2

	cmp.w	#$FFFF,20(a2)
	bne	.skip
	move.l	#0,backgroundScrollX
.skip:
	bsr	RenderBackgroundTile	
	rts
	
RenderNextForegroundFrame:
	lea	map,a2	
	move.l	foregroundScrollX,d0	
	lsr.l   #FOREGROUND_SCROLL_TILE_INDEX_CONVERT,d0
	lsr.l	#1,d0
	and.b   #$f0,d0
	add.l	d0,a2		
	move.l	#FOREGROUND_PLAYAREA_HEIGHT_WORDS-1,d3		; 8 tiles per column
.loop:
	move.l	d3,d2
	bsr	RenderForegroundTile
	bsr	ClearForegroundTile
	jsr	RenderItemSprite	
	add.l	#2,a2
	dbra	d3,.loop
	rts


RenderForegroundTile_NoAnim:
	;; a2 - address of tileIndex
	move.l	foregroundScrollX,d0
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0		; convert to pixels
	lsr.w   #3,d0		; bytes to scroll
	move.l	foregroundOffscreen,a0
	add.l	d0,a0
	lea 	tilemap,a1	
	add.w	(a2),a1 	; source tile	
	add.l	#(BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*(256-(16*8)+32)/4)+BITPLANE_WIDTH_BYTES-FOREGROUND_PLAYAREA_RIGHT_MARGIN_BYTES,a0	
	jsr	BlitTile
	rts	

RenderForegroundTile:
	;; a2 - address of tileIndex
	move.l	foregroundScrollX,d0
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0		; convert to pixels
	lsr.w   #3,d0		; bytes to scroll
	move.l	foregroundOffscreen,a0
	add.l	d0,a0
	lea 	tilemap,a1	
	add.w	(a2),a1 	; source tile	
	add.l	#(BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*(256-(16*8)+32)/4)+BITPLANE_WIDTH_BYTES-FOREGROUND_PLAYAREA_RIGHT_MARGIN_BYTES,a0
	lea 	animIndex,a4
	move.l	d2,d1
	lsl.l	#2,d1
	add.l	d1,a4
	move.l	(a4),d1
	lsr.l	#2,d1		; anim scaling (speed)
	cmp.l	#10,d1
	bge	.s1
	add.l	d1,a1
	jsr	BlitTile
	cmp.l	#2,(a4)
	blt	.s2
.s1:
	sub.l	#2,(a4)	
.s2:
	rts
	

ClearForegroundTile:	
	lea 	tilemap,a1		
	move.l	a2,a4
	sub.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS*8,a4
	sub.l	d0,d0
	move.w	(a4),d0
	add.l	d0,a1
	;; 	add.w	(a2,-FOREGROUND_PLAYAREA_WIDTH_WORDS),a1 	; source tile
	lea	map,a3
	add.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS*FOREGROUND_PLAYAREA_HEIGHT_WORDS,a3
	cmp.l	a3,a2		; don't clear until the full play area has scrolled in
	blt	.s3
	sub.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS,a0
	lea 	deAnimIndex,a4
	move.l	d2,d1
	lsl.l	#2,d1
	add.l	d1,a4
	move.l	(a4),d1
	lsr.l	#2,d1		; anim scaling (speed)
	cmp.l	#10,d1
	bge	.s1	
	add.l	d1,a1
	add.l	#2,(a4)	
	bra	.s2
.s1:
	add.w	#11520,a1 	; source tile	
.s2:
	jsr	BlitTile
.s3:
	rts

	
RenderBackgroundTile:	
	;; a2 - map
	move.l	backgroundScrollX,d0
	lsr.w	#BACKGROUND_SCROLL_SHIFT_CONVERT,d0 ; convert to pixels
	lsr.w   #3,d0		; bytes to scroll
	move.l	backgroundOffscreen,a0
	add.l	d0,a0
	lea 	backgroundTilemap,a1	
	add.l	#BITPLANE_WIDTH_BYTES-2,a0 ; dest
	add.w	(a2),a1 	; source tile
	move.l	backgroundScrollX,d2
	lsr.b	#BACKGROUND_SCROLL_SHIFT_CONVERT,d2		; convert to pixels
	andi.w	#$f,d2		; find the shift component		
	jsr	BlitTile
	rts	



Level3InterruptHandler:
	movem.l	d0-a6,-(sp)
	lea	CUSTOM,a6
.checkVerticalBlank:
	move.w	INTREQR(a6),d0
	and.w	#INTF_VERTB,d0	
	beq	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a6)	; clear interrupt bit	
	add.l	#1,verticalBlankCount
	jsr 	SetupSpriteData
.checkCopper:
	move.w	INTREQR(a6),d0
	and.w	#INTF_COPER,d0	
	beq.s	.interruptComplete
.copperInterrupt:
	move.w	#INTF_COPER,INTREQ(a6)	; clear interrupt bit	
	
.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte	


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

tileMapCopperPalettePtr:	
	include "out/foreground-copper-list.s"
	include "out/background-copper-list.s"
	dc.l	$fffffffe	

InstallSpriteColorPalette:
	include "out/sprite_pig_up-palette.s"
	include "out/sprite_coin1-palette.s"
	rts

InstallColorPalette:
	lea	tileMapCopperPalettePtr,a1
	lea	tilemapPalette,a0
	add.l	#2,a1
	move.l	#15,d0
.loop:
	move.w	(a0),(a1)
	add.l	#2,a0
	add.l	#4,a1	
	dbra	d0,.loop
	rts
	
InstallGreyPalette:
	lea	tileMapCopperPalettePtr,a1
	lea	greyPalette,a0
	add.l	#2,a1
	move.l	#15,d0
.loop:
	move.w	(a0),(a1)
	add.l	#2,a0
	add.l	#4,a1	
	dbra	d0,.loop

InstallPanelGreyPalette:
	lea	panelCopperPalettePtr,a1
	lea	panelGreyPalette,a0
	add.l	#2,a1
	move.l	#15,d0
.loop:
	move.w	(a0),(a1)
	add.l	#2,a0
	add.l	#4,a1	
	dbra	d0,.loop
	rts	


InstallNextGreyPalette:
	lea	tileMapCopperPalettePtr,a1	
	move.l	fadePtr,a0
	lea	bottomFadeComplete,a2
	cmp.l	a2,a0
	bge	.done
	add.l	#2,a1
	move.l	#15,d0
.loop:
	move.w	(a0),(a1)
	add.l	#2,a0
	add.l	#4,a1	
	dbra	d0,.loop
	move.l	frameCount,d0
	lsr.l	#1,d0
	btst.l	#0,d0
	beq	.done
	add.l	#16*2,fadePtr
.done
	
InstallNextGreyPanelPalette:
	lea	panelCopperPalettePtr,a1	
	move.l	panelFadePtr,a0
	lea	panelFadeComplete,a2
	cmp.l	a2,a0
	bge	.done
	add.l	#2,a1
	move.l	#15,d0
.loop:
	move.w	(a0),(a1)
	add.l	#2,a0
	add.l	#4,a1	
	dbra	d0,.loop
	move.l	frameCount,d0
	lsr.l	#1,d0
	btst.l	#0,d0
	beq	.done
	add.l	#16*2,panelFadePtr
.done
	rts		

foregroundOnscreen:
	dc.l	foregroundBitplanes1
foregroundOffscreen:
	dc.l	foregroundBitplanes2
backgroundOnscreen:
	dc.l	backgroundBitplanes1
backgroundOffscreen:
	dc.l	backgroundBitplanes1
tilemap:
	incbin "out/foreground.bin"
backgroundTilemap:
	incbin "out/background.bin"

panel:
	incbin "out/panel.bin"
map:
	include "out/foreground-map.s"
	dc.w	$FFFF
itemsMap:
	include "out/items-indexes.s"
	dc.w	$FFFF
mapSize:
	dc.l	itemsMap-map
	
backgroundMap:
	include "out/background-map.s"
	dc.w	$FFFF
foregroundScrollPixels:
	dc.l	FOREGROUND_SCROLL_PIXELS	
foregroundScrollX:
	dc.l	0
backgroundScrollX:
	dc.l	0
frameCount:
	dc.l	0
verticalBlankCount:
	dc.l	0
moving:
	dc.w	0

fadePtr:
	dc.l	fade
panelFadePtr:
	dc.l	panelFade
	
animIndex:
	ds.l	16,0
deAnimIndex:
	ds.l	16,0	

animIndexPatternPtr:
	dc.l	animIndexPattern
animIndexPattern:
	dc.l	0
	dc.l	8*4
	dc.l	10*4
	dc.l	16*4
	dc.l	12*4
	dc.l	14*4
	dc.l	16*4
	dc.l	0
	dc.l	0
	dc.l	16*4
	dc.l	10*4
	dc.l	6*4
	dc.l	2*4
	dc.l	16*4
	dc.l	14*4
	dc.l	0
	dc.l	0
	dc.l	8*4
	dc.l	10*4
	dc.l	16*4
	dc.l	12*4
	dc.l	14*4
	dc.l	16*4
	dc.l	0
	dc.l	0
	dc.l	16*4
	dc.l	10*4
	dc.l	8*4
	dc.l	12*4
	dc.l	4*4
	dc.l	12*4
	dc.l	0
	dc.l	$ffffffff

deAnimIndexPatternPtr:
	dc.l	deAnimIndexPattern
deAnimIndexPattern:
	dc.l	0
	dc.l	0*4
	dc.l	2*4
	dc.l	4*4
	dc.l	2*4
	dc.l	6*4
	dc.l	2*4
	dc.l	0
	dc.l	0
	dc.l	8*4
	dc.l	4*4
	dc.l	6*4
	dc.l	2*4
	dc.l	4*4
	dc.l	2*4
	dc.l	0
	dc.l	0
	dc.l	0*4
	dc.l	4*4
	dc.l	2*4
	dc.l	4*4
	dc.l	2*4
	dc.l	6*4
	dc.l	0
	dc.l	0
	dc.l	6*4
	dc.l	0*4
	dc.l	2*4
	dc.l	2*4
	dc.l	8*4
	dc.l	2*4
	dc.l	0	
	dc.l	$ffffffff	

greyPalette:
	include	"out/foreground-grey-table.s"
	include	"out/background-grey-table.s"		

panelGreyPalette:
	include "out/panel-grey-table.s"
	
tilemapPalette:
	if 0
	include "tilemap-palette-table.s"
	endif
	include	"out/foreground-palette-table.s"
	include	"out/background-palette-table.s"	

fade:
	include "out/fade.s"

panelFade:
	include "out/panelFade.s"
	
	section .bss
foregroundBitplanes1:
	ds.b	IMAGESIZE*3
foregroundBitplanes2:
	ds.b	IMAGESIZE*3

backgroundBitplanes1:
	ds.b	IMAGESIZE*2

startUserstack:
	ds.b	$1000		; size of stack
userstack:

	end