	include "includes.i"

	xdef    BigBang
	xdef	IncrementScore

	xdef	copperList
	xdef	mpanelCopperList
	xdef	copperListBpl1Ptr
	xdef	copperListBpl2Ptr

	xdef	copperListBpl1Ptr_MP
	xdef	copperListBpl1Ptr2_MP
	xdef	copperListBpl2Ptr_MP
	xdef	copperListBpl2Ptr2_MP
	
	xdef	foregroundOnscreen
	xdef	foregroundOffscreen
	xdef	foregroundScrollX
	xdef	map
	xdef	itemsMap
	xdef   	mapSize
	xdef	moving
	xdef 	foregroundScrollPixels

TIMING_TEST		equ 0
TIMING_TEST_MAIN_LOOP	equ 1
	
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
	
	jsr	StartMusic

	jsr	ShowSplash

	;; jsr	InstallGreyPalette	

	;; d0 - fg bitplane pointer offset
	;; d1 - bg bitplane pointer offset		
	move.l	#0,d0
	move.l	#1,d1
	jsr	SwitchBuffers				

 	move.w	#(DMAF_BLITTER|DMAF_SETCLR!DMAF_MASTER),DMACON(a6) 		

	lea	panelCopperListBpl1Ptr,a0
	lea	panel,a1
	jsr	PokePanelBitplanePointers

	lea	panelCopperListBpl1Ptr_MP,a0
	lea	panel,a1
	jsr	PokePanelBitplanePointers	


	lea	mpanelCopperListBpl1Ptr,a0
	lea	mpanel,a1
	jsr	PokePanelBitplanePointers

	bsr	ShowMessagePanel
	jsr	Init		  ; enable the playfield		

	jsr	InstallSpriteColorPalette


	move.w	#(DMAF_SPRITE|DMAF_BLITTER|DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)

	
Reset:	
	move.w	#0,moving	
	move.l	#playareaFade,playareaFadePtr
	move.l	#panelFade,panelFadePtr
	move.l	#flagsFade,flagsFadePtr
	move.l	#tileFade,tileFadePtr
	move.l	#0,foregroundScrollX
	move.l	#-1,frameCount		
	bsr	InitAnimPattern
	jsr	ResetBigBangPattern
	jsr 	BlueFill
	jsr	Message
	jsr	InstallGreyPalette
	jsr	HidePlayer
	bsr	RenderScore
	
MainLoop:
	MOVE.W  #$0024,BPLCON2(a6)
	move.l	#0,frameCount
SetupBoardLoop:
	add.l	#1,frameCount
	move.l	frameCount,d6		
	move.l	#(FOREGROUND_SCROLL_PIXELS*16)-1,foregroundScrollPixels
	bsr	HoriScrollPlayfield
	jsr 	SwitchBuffers
	move.l	foregroundScrollX,d0
	move.w	#1,moving
	bsr 	Update
	bsr	RenderNextForegroundFrame	
	cmp.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS,frameCount	
	bge	.gotoGameLoop
	bra	SetupBoardLoop
.gotoGameLoop:
	add.l	#1,d6
	jsr	WaitVerticalBlank
	cmp.l	#50,d6
	ble	.gotoGameLoop
	jsr	ProcessJoystick
	;; cmp.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS+50,d6
	;; bne	.gotoGameLoop
	btst.b	#0,joystick
	beq	.gotoGameLoop
	move.w	#0,moving
	move.l	#FOREGROUND_SCROLL_PIXELS,foregroundScrollPixels
	;; move.w	#$ffff,mpanelWaitLinePtr
	;; bsr	ClearMPanel
	bsr	HideMessagePanel
	
FadeInLoop:
	add.l	#1,frameCount
	move.l	frameCount,d6				

	move.l	#0,d0
.loop:
	jsr 	WaitVerticalBlank
	dbra	d0,.loop
	bsr	InstallNextGreyPalette
	cmp.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS+25,d6
	bne	.c1
	jsr	InitialisePlayer
	jsr	EnableItemSprites
	bra	GameLoop
.c1:
	bra	FadeInLoop
	
GameLoop:
	add.l	#1,frameCount
	move.l	frameCount,d6			
	move.l	#FOREGROUND_SCROLL_PIXELS,foregroundScrollPixels
	jsr	WaitVerticalBlank

	if	TIMING_TEST=1
	if	TIMING_TEST_MAIN_LOOP=1
	move.l	#4000,d0
.looooo:
	dbra	d0,.looooo	
	move.w	#$0f0,COLOR00(a6)
	endif
	endif
	
	bsr	HoriScrollPlayfield
	jsr 	SwitchBuffers
	move.l	foregroundScrollX,d0
	lsr.l	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0 ; convert to pixels		
	and.b	#$f,d0
	cmp.b	#$f,d0
	bne	.s2
	move.w	#0,moving
.s2:	
	jsr	ProcessJoystick

	jsr	InstallNextTileColor
	jsr	CheckPlayerMiss	
	bsr 	Update
	bsr	RenderNextForegroundFrame	
	jsr 	RenderNextBackgroundFrame

	if TIMING_TEST=1
	move.l	#0,d0
.checkLoop:
	dbra	d0,.checkLoop
	move.w	#$f00,COLOR00(a6)
	move.w	#$f00,COLOR02(a6)			
	endif

	bra	GameLoop
	
Update:
	jsr	UpdatePlayer

.backgroundUpdates:
	add.l	#BACKGROUND_SCROLL_PIXELS,backgroundScrollX		
	btst	#FOREGROUND_DELAY_BIT,d6
	beq	.skipForegroundUpdates
	;; ---- Foreground updates ----------------------------------------	
.foregroundUpdates:
	jsr	CalculateScore
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


ShowMessagePanel:
	lea	mpanelCopperList,a0
	move.l	a0,COP1LC(a6)
 	move.w  COPJMP1(a6),d0
	rts


HideMessagePanel:
	lea	copperList,a0
	move.l	a0,COP1LC(a6)
 	move.w  COPJMP1(a6),d0
	rts	
	
HoriScrollPlayfield:
	;; d0 - fg x position in pixels
	;; d1 - bg x position in pixels	
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
	;; move.w	d0,copperListScrollPtr2
	move.w	d0,copperListScrollPtr_MP
	move.w	d0,copperListScrollPtr2_MP
	rts


InitAnimPattern:
	lea	animIndex,a0
	move.l	#7,d0
.loop:
	move.l	#0,(a0)+
	dbra	d0,.loop
	move.l	#animIndexPattern,animIndexPatternPtr
	rts	
	
ResetAnimPattern:
	lea	animIndex,a0
	move.l	#animIndexPattern,a1
	move.l	#7,d0
.loop:
	move.l	(a1)+,(a0)+
	dbra	d0,.loop
	add.l	#8*4,animIndexPatternPtr
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


ResetBigBangPattern:
	lea	bigBangIndex,a0
	move.l	verticalBlankCount,d0
	andi.l	#$fff0,d0
	move.l	#MainLoop,a1	
	add.l	d0,a1
	move.l	#(FOREGROUND_PLAYAREA_WIDTH_WORDS/2)-1,d1
.loop1:	
	move.l	#FOREGROUND_PLAYAREA_HEIGHT_WORDS-1,d0
.loop:
	move.l	(a1)+,d2
	and.l	#3,d2
	move.l	d2,(a0)+
	dbra	d0,.loop
	dbra	d1,.loop1
	rts	

	
RenderNextForegroundFrame:
	lea	map,a2	
	move.l	foregroundScrollX,d0	
	lsr.l   #FOREGROUND_SCROLL_TILE_INDEX_CONVERT,d0
	lsr.l	#1,d0
	and.b   #$f0,d0
	add.l	d0,a2		
	;; 	move.l	#FOREGROUND_PLAYAREA_HEIGHT_WORDS-1,d3		; 8 tiles per column
	move.l	0,d3
.loop:
	move.l	d3,d2
	bsr	RenderForegroundTile
	bsr	ClearForegroundTile
	jsr	RenderItemSprite	
	add.l	#2,a2
	add.l	#1,d3
	cmp.l 	#FOREGROUND_PLAYAREA_HEIGHT_WORDS,d3
	blt	.loop
	rts


RenderForegroundTile_NoAnim:
	;; a2 - address of tileIndex
	move.l	foregroundScrollX,d0
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0		; convert to pixels
	lsr.w   #3,d0		; bytes to scroll
	move.l	foregroundOffscreen,a0
	add.l	d0,a0
	lea 	foregroundTilemap,a1	
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
	lea 	foregroundTilemap,a1	
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
	

PostMissedTile:
	jsr 	SelectNextPlayerSprite
	bra	Reset


	
BigBang:
	;; move.w	#(DMAF_SPRITE),DMACON(a6) ; turn sprites off for now	

	jsr	ResetItems	
	move.w	#0,moving
	move.l	#0,frameCount	
.bigBangLoop:
	add.l	#1,frameCount
	cmp.l	#BIGBANG_POST_DELAY,frameCount
	beq	PostMissedTile
	move.l	frameCount,d6	
	jsr	WaitVerticalBlank	
	bsr	HoriScrollPlayfield
	jsr 	SwitchBuffers
	jsr	ProcessJoystick
	jsr	UpdatePlayerFallingAnimation
	;; bsr 	Update

	lea	map,a2	
	move.l	foregroundScrollX,d0	
	lsr.l   #FOREGROUND_SCROLL_TILE_INDEX_CONVERT,d0
	lsr.l	#1,d0
	and.b   #$f0,d0
	add.l	d0,a2
	add.l	#(FOREGROUND_PLAYAREA_HEIGHT_WORDS-1)*2,a2
	
	move.l	foregroundScrollX,d0
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0		; convert to pixels
	lsr.w   #3,d0		; bytes to scroll
	move.l	foregroundOffscreen,a0
	add.l	d0,a0
	lea 	foregroundTilemap,a1	
	add.l	#(BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*(256-(16*8)+32)/4)+BITPLANE_WIDTH_BYTES-FOREGROUND_PLAYAREA_RIGHT_MARGIN_BYTES,a0	


	move.l	#(FOREGROUND_PLAYAREA_WIDTH_WORDS/2),d5

	move.l	#BIGBANG_ANIM_DELAY,d0

	lea 	bigBangIndex,a4
.loop3:
	jsr	WaitVerticalBlank
	dbra	d0,.loop3

	
.loop1:	
	move.l  #FOREGROUND_PLAYAREA_HEIGHT_WORDS-1,d2
.loop2:
	bsr	ClearForegroundTile3
	sub.l	#2,a2
	dbra	d2,.loop2
	sub.l	#2,a0
	dbra	d5,.loop1
	bra	.bigBangLoop


ClearForegroundTile3:	
	;;  a4 - pointed to animation offset for tile
	lea 	foregroundTilemap,a1		
	sub.l	d0,d0
	move.w	(a2),d0
	add.l	d0,a1
	lea	map,a3
	add.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS*FOREGROUND_PLAYAREA_HEIGHT_WORDS,a3
	move.l	(a4),d1
	cmp.l	#10,d1
	bge	.s1	
	add.l	d1,a1
	add.l	#2,(a4)	
	add.l	#4,a4
	bra	.s2
.s1:
	lea 	foregroundTilemap,a1
	;; add.w	#21520,a1 	; source tile
	add.w	#$0,a1
.s2:
	jsr	BlitTile
	rts

	
ClearForegroundTile:	
	lea 	foregroundTilemap,a1		
	move.l	a2,a4
	sub.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS*8,a4
	sub.l	d0,d0
	move.w	(a4),d0
	add.l	d0,a1
	lea	map,a3
	add.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS*FOREGROUND_PLAYAREA_HEIGHT_WORDS,a3
	cmp.l	a3,a2		; don't clear until the full play area has scrolled in
	blt	.s3
	sub.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS,a0
	lea     deAnimIndex,a4
	
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
	lea 	foregroundTilemap,a1
	;; 	add.w	#21520,a1 	; source tile		
	add.w	#$0,a1
.s2:
	jsr	BlitTile
.s3:
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
	jsr	P61_Music
.checkCopper:
	move.w	INTREQR(a6),d0
	and.w	#INTF_COPER,d0	
	beq.s	.interruptComplete
.copperInterrupt:
	move.w	#INTF_COPER,INTREQ(a6)	; clear interrupt bit	
	
.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte	

Message:
	;; a0 - bitplane
	;; a1 - text
	;; d0 - xpos
	;; d1 - ypos
	lea	mpanel,a0
	lea	message,a1
	move.w	#128,d0
	move.w	#11,d1
	jsr	DrawMaskedText8
	;; move.w	#MPANEL_COPPER_WAIT,mpanelWaitLinePtr
	;; jsr	EnableMPanel
	bsr	ShowMessagePanel
	rts

RenderScore:
	lea	panel,a0
	lea	scoreText,a1
	move.w	#31,d0
	move.w	#20,d1
	jsr	DrawText8
	rts

	
IncrementScore:
	movem.l	d0-a6,-(sp)
	lea	scoreText,a0
	add.l	#3,a0
.loop:
	sub.l	d0,d0
	move.b	(a0),d0
	addq.b	#1,d0
	cmp.b	#'9',d0
	ble	.done
	move.b	#'0',d0
	move.b	d0,(a0)	
	sub.l	#1,a0
	bra	.loop
.done
	move.b	d0,(a0)
	jsr	RenderScore
	movem.l	(sp)+,d0-a6
	rts
	
message:
	dc.b	"LETS PLAY!"
	dc.b	0

	align 4	

scoreText:
	dc.b	"0000"
	dc.b	0

	align	4
	
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
	include "out/foreground-copper-list.s"
	include "out/background-copper-list.s"	

	;; top flag row has it's own palette
	dc.w    $84d1
	dc.w	$fffe		
flagsCopperPalettePtr1:	
	include "out/foreground-copper-list.s"
	include "out/background-copper-list.s"
	dc.w    $94d1
	dc.w	$fffe
	;; 

	
playAreaCopperPalettePtr2:	
	include "out/foreground-copper-list.s"
	include "out/background-copper-list.s"		
	

	;; bottom flag row has it's own palette
	dc.w    $f4d1
	dc.w	$fffe		
flagsCopperPalettePtr2:	
	include "out/foreground-copper-list.s"
	include "out/background-copper-list.s"
	dc.w    $ffdf
	dc.w	$fffe
	dc.w    $04d1
	dc.w	$fffe	

playAreaCopperPalettePtr3:	
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

InstallSpriteColorPalette:
	jsr	InstallPlayerColorPalette
	include "out/sprite_coin-1-palette.s"
	rts

InstallColorPalette:
	lea	playAreaCopperPalettePtr1,a1
	lea	playAreaCopperPalettePtr2,a2
	lea	playAreaCopperPalettePtr3,a3
	lea	playAreaPalette,a0
	add.l	#2,a1
	add.l	#2,a2
	add.l	#2,a3
	move.l	#15,d0
.loop:
	move.w	(a0),(a1)
	move.w	(a0),(a2)
	move.w	(a0),(a3)
	add.l	#2,a0
	add.l	#4,a1
	add.l	#4,a2
	add.l	#4,a3
	dbra	d0,.loop
	rts
	
InstallGreyPalette:
	lea	playAreaCopperPalettePtr1,a1
	lea	playAreaCopperPalettePtr2,a2
	lea	playAreaCopperPalettePtr3,a3
	lea	playareaFade,a0
	add.l	#2,a1
	add.l	#2,a2
	add.l	#2,a3
	move.l	#15,d0
.loop:
	move.w	(a0),(a1)
	move.w	(a0),(a2)
	move.w	(a0),(a3)
	add.l	#2,a0
	add.l	#4,a1
	add.l	#4,a2
	add.l	#4,a3
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


InstallFlagsGreyPalette:
	lea	flagsCopperPalettePtr1,a1
	lea	flagsCopperPalettePtr2,a2
	lea	flagsFade,a0
	add.l	#2,a1
	add.l	#2,a2
	move.l	#15,d0
.loop:
	move.w	(a0),(a1)
	move.w	(a0),(a2)
	add.l	#2,a0
	add.l	#4,a1
	add.l	#4,a2
	dbra	d0,.loop	
	
	rts	


InstallNextTileColor:
	movem.l	d0-a6,-(sp)
	lea	playAreaCopperPalettePtr2,a1
	add.l	#6,a1 		; point to COLOR01
	move.l	tileFadePtr,a0
	lea	tileFadeFadeComplete,a5
	cmp.l	a5,a0
	bge	.reset
	move.l	#1,d0 		; 2 colors to update
.loop:
	move.w	(a0),(a1)
	add.l	#2,a0
	add.l	#4,a1
	dbra	d0,.loop
	add.l	#2*2,tileFadePtr
	bra	.done
.reset:
	move.l	#tileFade,tileFadePtr
.done:
	movem.l	(sp)+,d0-a6
	rts
	
InstallNextGreyPalette:
	lea	playAreaCopperPalettePtr1,a1
	lea	playAreaCopperPalettePtr2,a2
	lea	playAreaCopperPalettePtr3,a3
	move.l	playareaFadePtr,a0
	lea	playareaFadeComplete,a5
	cmp.l	a5,a0
	bge	.done
	add.l	#2,a1
	add.l	#2,a2
	add.l	#2,a3
	move.l	#15,d0
.loop:
	move.w	(a0),(a1)
	move.w	(a0),(a2)	
	move.w	(a0),(a3)
	add.l	#2,a0
	add.l	#4,a1
	add.l	#4,a2
	add.l	#4,a3
	dbra	d0,.loop
	add.l	#16*2,playareaFadePtr
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
	add.l	#16*2,panelFadePtr
.done


InstallFlagGreyPalette:
	lea	flagsCopperPalettePtr1,a1
	lea	flagsCopperPalettePtr2,a2
	move.l	flagsFadePtr,a0
	lea	flagsFadeComplete,a5
	cmp.l	a5,a0
	bge	.done
	add.l	#2,a1
	add.l	#2,a2
	move.l	#15,d0
.loop:
	move.w	(a0),(a1)
	move.w	(a0),(a2)	
	add.l	#2,a0
	add.l	#4,a1
	add.l	#4,a2
	dbra	d0,.loop
	add.l	#16*2,flagsFadePtr
.done	
	rts		


	
foregroundOnscreen:
	dc.l	foregroundBitplanes1
foregroundOffscreen:
	dc.l	foregroundBitplanes2
foregroundTilemap:
	incbin "out/foreground.bin"
panel:
	incbin "out/panel.bin"
mpanel:
	incbin "out/mpanel.bin"	
map:
	include "out/foreground-map.s"
	dc.w	$FFFF
itemsMap:
	include "out/items-indexes.s"
	dc.w	$FFFF
mapSize:
	dc.l	itemsMap-map
	

foregroundScrollPixels:
	dc.l	FOREGROUND_SCROLL_PIXELS	
foregroundScrollX:
	dc.l	0
frameCount:
	dc.l	0
verticalBlankCount:
	dc.l	0
moving:
	dc.w	0

tileFadePtr:
	dc.l	tileFade
playareaFadePtr:
	dc.l	playareaFade
panelFadePtr:
	dc.l	panelFade
flagsFadePtr:
	dc.l	flagsFade

bigBangIndex:
	ds.l	FOREGROUND_PLAYAREA_HEIGHT_WORDS*FOREGROUND_PLAYAREA_WIDTH_WORDS,0
	
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

	if 0
greyPalette:
	include	"out/foreground-grey-table.s"
	include	"out/background-grey-table.s"
	endif

panelGreyPalette:
	include "out/panel-grey-table.s"
	
playAreaPalette:
	include	"out/foreground-palette-table.s"
	include	"out/background-palette-table.s"	

playareaFade:
	include "out/playarea_fade.s"

flagsFade:
	include "out/flags_fade.s"	

panelFade:
	include "out/panelFade.s"

tileFade:
	include "out/tileFade.s"



	section .bss
foregroundBitplanes1:
	ds.b	IMAGESIZE
foregroundBitplanes2:
	ds.b	IMAGESIZE
startUserstack:
	ds.b	$1000		; size of stack
userstack:

	end