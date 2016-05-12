	include "includes.i"

	xdef    LevelComplete
	xdef    BigBang
	xdef 	IncrementCounter
	xdef	RenderCounter
	
	xdef	pathwayRenderPending
	xdef	pathwayPlayerTileAddress
	xdef	pathwayFadeCount	
	xdef	pathwayClearPending
	xdef	InstallTilePalette	

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
	xdef	foregroundBitplanes1	
	xdef	foregroundPlayerTileAddress
	
	xdef	foregroundMapPtr
	xdef	pathwayMapPtr
	xdef	startForegroundMapPtr
	xdef 	startPathwayMapPtr
	
	xdef   	itemsMapOffset
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

	jsr	StartMusic
	jsr	ShowSplash
	if SPLASH_USE_FOREGROUND=1
	jsr	InstallBlackPalette
	endif
	jsr 	BlueFill	

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

	move.w	#(DMAF_SPRITE|DMAF_BLITTER|DMAF_SETCLR|DMAF_COPPER|DMAF_RASTER|DMAF_MASTER),DMACON(a6)

	jsr	InitialiseItems	
Reset:
	lea	livesCounterText,a0
	bsr	DecrementCounter
	move.w	#218,d0
	lea	livesCounterShortText,a1	
	jsr	RenderCounter	
	lea	player1Text,a1
	move.w	#192,d0
	jsr	RenderCounter
	
	move.l	startForegroundMapPtr,foregroundMapPtr
	move.l	startPathwayMapPtr,pathwayMapPtr	
	move.w	#0,pathwayRenderPending
	move.w	#0,pathwayClearPending
	move.w	#0,moving
	move.w	#-2*FOREGROUND_MOVING_COUNTER,movingCounter
	move.l	playareaFade,playareaFadePtr
	move.l	#panelFade,panelFadePtr
	move.l	flagsFade,flagsFadePtr
	move.l	tileFade,tileFadePtr
	move.l	#0,foregroundScrollX
	move.l	#-1,frameCount		
	bsr	InitAnimPattern
	jsr	ResetBigBangPattern
	jsr 	BlueFill
	jsr	InstallGreyPalette
	jsr	HidePlayer
	cmp.l	#'0000',livesCounterText
	bne	.notGameOver
	bra	GameOver
.notGameOver:
	lea	message,a1
	move.w	#128,d0
	jsr	Message
	
	
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

	jsr	RenderNextForegroundFrame	
	
	move.w	#15,d5
	sub.l	#BACKGROUND_SCROLL_PIXELS,backgroundScrollX			
.renderNextBackgroundFrameLoop:	
	add.l	#BACKGROUND_SCROLL_PIXELS,backgroundScrollX		
	jsr	RenderNextBackgroundFrame
	jsr 	SwitchBackgroundBuffers
	dbra	d5,.renderNextBackgroundFrameLoop
	
	cmp.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS,frameCount	
	bge	.gotoGameLoop
	bra	SetupBoardLoop
.gotoGameLoop:
	add.l	#1,d6
	jsr	WaitForJoystick	
	move.w	#0,moving
	move.l	#FOREGROUND_SCROLL_PIXELS,foregroundScrollPixels
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

	move.l	#0,verticalBlankCount
	move.l	#1,frameCount
	move.l	#FOREGROUND_SCROLL_PIXELS,foregroundScrollPixels

	bra	GameLoop
.c1:
	bra	FadeInLoop


GameLoop:

	move.l	verticalBlankCount,d0
	move.l	frameCount,d1	
	cmp.l	d1,d0
	beq	.noSkippedFrames
	addq	#1,d0
	cmp.l	d1,d0
	beq	.noSkippedFrames
	move.l	frameCount,verticalBlankCount
	lea	skippedFramesCounterText,a0
	jsr	IncrementCounter
	lea	skippedFramesCounterText,a1	
	move.w	#110,d0
	jsr	RenderCounter		
.noSkippedFrames:

	
	add.l	#1,frameCount
	move.l	frameCount,d6			

	jsr	WaitVerticalBlank
	
	if      TIMING_TEST=1
	move.l	#4000,d0
.looooo:
	dbra	d0,.looooo	
	move.w	#$0f0,COLOR00(a6)
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
	cmp.w	#PLAYER_INITIAL_X+16*3,spriteX
	bge	.setMoving
	addq.w	#1,movingCounter
	cmp.w	#FOREGROUND_MOVING_COUNTER,movingCounter
	bge	.setMoving
	bra	.notMoving
.setMoving:
	move.w	#0,movingCounter
	move.w	#1,moving
.notMoving:


	
	
	bsr 	Update
	jsr	CheckPlayerMiss
	bsr	RenderNextForegroundFrame
	jsr 	RenderNextBackgroundFrame


	cmp.w	#0,pathwayClearPending
	beq	.dontClearPathway
	bsr	ClearPathway
.dontClearPathway:
	
	cmp.w	#0,pathwayRenderPending
	beq	.dontRenderPathway
	jsr	RenderPathway
.dontRenderPathway:

	if TIMING_TEST=1
	move.w	#$f00,COLOR00(a6)
	move.w	#$f00,COLOR02(a6)			
	endif

	jsr	PlayNextSound	
	bra	GameLoop
	
Update:	
	jsr	UpdatePlayer

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
	rts
.c1:
.skipForegroundUpdates:

	cmp.w	#PATHWAY_FADE_TIMER_COUNT,pathwayFadeCount
	blt	.dontInstallNextPathwayColor
	jsr	InstallNextPathwayColor
.dontInstallNextPathwayColor:
	add.w	#1,pathwayFadeCount

	rts


GameOver:
	lea	gameOverMessage,a1
	move.w	#128,d0
	jsr	Message
	jsr	InstallPaletteA

	jsr	WaitForJoystick		

	move.l	#level1ForegroundMap,startForegroundMapPtr
	move.l	#level1PathwayMap,startPathwayMapPtr
	move.l	#'0004',livesCounterText	
	jsr	InitialiseItems
	bra	Reset


LevelComplete:
	PlaySound Yay
	jsr	ResetItems
	jsr	ResetPlayer

	jsr 	SelectNextPlayerSprite
	move.l	nextPaletteInstaller,a0
	cmp.l	#0,(a0)
	bne	.dontResetPaletteInstaller
	move.l	#paletteInstallers,nextPaletteInstaller
	move.l	nextPaletteInstaller,a0	
.dontResetPaletteInstaller:
	move.l	(a0),a1
	jsr	(a1)
	add.l	#4,a0
	move.l	a0,nextPaletteInstaller
	
	lea	levelCompleteMessage,a1
	move.w	#100,d0
	jsr	Message	

	jsr	WaitForJoystick
	
	move.l	#level1ForegroundMap,startForegroundMapPtr
	move.l	#level1PathwayMap,startPathwayMapPtr
	move.l	#'0004',livesCounterText	
	jsr	InitialiseItems
	bra	Reset
	
ShowMessagePanel:
	jsr	WaitVerticalBlank
	lea	mpanelCopperList,a0
	move.l	a0,COP1LC(a6)
	rts


HideMessagePanel:
	jsr	WaitVerticalBlank
	lea	copperList,a0
	move.l	a0,COP1LC(a6)
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
	move.l	foregroundMapPtr,a2
	move.l	foregroundScrollX,d0	
	lsr.l   #FOREGROUND_SCROLL_TILE_INDEX_CONVERT,d0
	lsr.l	#1,d0
	and.b   #$f0,d0
	add.l	d0,a2		
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
	jsr	PrepareItemSpriteData	
	rts

RenderPathway:
	move.l	pathwayPlayerTileAddress,d5
	andi.w	#$fff0,d5       ; point the address to the last tile of the previous column
	addq	#2,d5		;
	move.l	d5,a4
	move.w	#1,d5
.loopX:	
	move.w	#6,d6 		; y index
	move.w	#0,d7		; number of rows without a pathway
.loopY:
	move.l	pathwayMapPtr,a2
	bsr	GetMapTile
	cmp.l	a4,a2		; search for the start column
	ble	.next	
	cmp.l	pathwayPlayerTileAddress,a2
	beq	.next
	
	move.l	d0,a2
	move.w	(a2),d0
	
	cmp.w	#0,d0
	beq	.dontBlit
	
	lea 	foregroundTilemap,a1	
	add.w	d0,a1 	; source tile	
	
	move.l	foregroundScrollX,d0
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0		; convert to pixels
	lsr.w   #3,d0		; bytes to scroll
	move.l	foregroundOffscreen,a0
	add.l	d0,a0

	move.l	#-BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*8,d0
	move.w	d5,d4
	mulu.w	#2,d4
	add.l	d4,d0
	add.l	#10,d0
	add.l	d0,a0
	move.l	#10,d2
	sub.l	d6,d2
	jsr	BlitTile
	bra	.next
.dontBlit:
	add.w	#1,d7
	cmp.w	#7,d7
	beq	.skip
.next:
	dbra	d6,.loopY
	add.w	#1,d5
	cmp.w	#(FOREGROUND_PLAYAREA_WIDTH_WORDS/2)-0,d5 ; don't render pathways off the play area
	beq	.pathwayNotComplete
	bra	.loopX
.skip:
	sub.w	#1,pathwayRenderPending	
	rts
.pathwayNotComplete:
	rts


ClearPathway:
	sub.w	#1,pathwayClearPending
	move.l	foregroundPlayerTileAddress,d7
	andi.w	#$fff0,d7	 ; address of the last tile in the previous column
	move.w	#0,d5		 ; x index
.loopX:	
	move.w	#6,d6 		; y index
.loopY:
	move.l	foregroundMapPtr,a2 ;; todo: this will be too slow, it will render too many tiles
	bsr	GetMapTile
	cmp.l	d7,a2		; finished clearing...
	bgt	.done
	move.l	d0,a2
	move.w	(a2),d0

	if 0
	move.l	foregroundMapPtr,a3
	move.w	(a3),d0
	endif

	cmp.w	#0,d0
	beq	.dontBlit
	
	lea 	foregroundTilemap,a1	
	add.w	d0,a1 	; source tile	
	
	move.l	foregroundScrollX,d0
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0		; convert to pixels
	lsr.w   #3,d0		; bytes to scroll
	move.l	foregroundOffscreen,a0
	add.l	d0,a0

	move.l	#-BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*8,d0
	move.w	d5,d4
	mulu.w	#2,d4
	add.l	d4,d0
	add.l	#10,d0
	add.l	d0,a0
	move.l	#10,d2
	sub.l	d6,d2
	jsr	BlitTile
	bra	.next
.dontBlit:
.next:
	dbra	d6,.loopY
	add.w	#1,d5
	bra	.loopX
	;; dbra	d5,.loopX
.done
	rts	


RenderMapTile:
	;; d5 - x map index
	;; d6 - y map index

	move.l	foregroundMapPtr,a2
	bsr	GetMapTile
	move.l	d0,a2
	move.w	(a2),d0
	cmp.w	#0,d0
	beq	.dontBlit
	
	lea 	foregroundTilemap,a1	
	add.w	d0,a1 	; source tile
	
	move.l	foregroundScrollX,d0
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0		; convert to pixels
	lsr.w   #3,d0		; bytes to scroll
	move.l	foregroundOffscreen,a0
	add.l	d0,a0

	move.l	#-BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*8,d0
	move.w	d5,d4
	mulu.w	#2,d4
	add.l	d4,d0
	add.l	#10,d0
	add.l	d0,a0
	move.l	#10,d2
	sub.l	d6,d2
	jsr	BlitTile
.dontBlit:
	rts
	
GetMapTile:
	;; d5 - x board index
	;; d6 - y board index
	;; a2 - map
	;;
	;; d0 - pathwayOffset
	
	
	;; calculate the a2 offset of the top right tile based on foreground scroll
	move.l	foregroundScrollX,d0		
	lsr.l   #FOREGROUND_SCROLL_TILE_INDEX_CONVERT,d0
	lsr.l	#1,d0
	and.b   #$f0,d0
	add.l	d0,a2

	move.l	#(FOREGROUND_PLAYAREA_WIDTH_WORDS/2)-1,d1
	sub.w	d5,d1		; x column
	mulu.w  #FOREGROUND_PLAYAREA_HEIGHT_WORDS*2,d1
	sub.l	d1,a2		; player x if y == bottom ?

	sub.l	d1,d1
	move.w	#FOREGROUND_PLAYAREA_HEIGHT_WORDS-1,d1
	sub.w	d6,d1 		; y row
	lsl.w	#1,d1
	add.l	d1,a2

	;; a2 now points at the tile at the coordinate
	move.l	a2,d0
	rts
		
	
RenderNextForegroundPathwayFrame:
	move.l	pathwayMapPtr,a2
	move.l	foregroundScrollX,d0	
	lsr.l   #FOREGROUND_SCROLL_TILE_INDEX_CONVERT,d0
	lsr.l	#1,d0
	and.b   #$f0,d0
	add.l	d0,a2		
	move.l	0,d3
.loop:
	move.l	d3,d2
	bsr	RenderForegroundTile
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
	move.w	(a2),d0
	;; 	cmp.l	#0,d0
	;; 	beq	.s2
	add.w	(a2),a1 	; source tile	
	add.l	#(BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*(256-(16*8)+32)/4)+BITPLANE_WIDTH_BYTES-FOREGROUND_PLAYAREA_RIGHT_MARGIN_BYTES,a0
	cmp.w	#$ffff,d0
	beq	stopScrolling

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
stopScrolling:
	move.l	#0,foregroundScrollPixels
	rts
	

PostMissedTile:
	bra	Reset

	
BigBang:

.finishScrollLoop: ; finish the current foreground tile scroll to clear any half cleared tiles
	move.l	foregroundScrollX,d0
	lsr.l	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0 ; convert to pixels		
	and.b	#$f,d0
	cmp.b	#$f,d0
	beq	.scrollFinished	
	add.l	#1,frameCount
	move.l	frameCount,d6	
	jsr	Update
	bsr	RenderNextForegroundFrame
	jsr 	RenderNextBackgroundFrame	
	jsr	WaitVerticalBlank
	jsr	PlayNextSound		
	bsr	HoriScrollPlayfield
	jsr 	SwitchBuffers
	bra	.finishScrollLoop
.scrollFinished:
	
	PlaySound Falling
	jsr	WaitVerticalBlank		
	jsr	PlayNextSound		
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
	jsr	UpdatePlayerFallingAnimation

	move.l	foregroundMapPtr,a2
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


	move.l	#(FOREGROUND_PLAYAREA_WIDTH_WORDS/2)-1,d5

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
	move.l	foregroundMapPtr,a3
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
	;; a0 - pointer to tile just rendered (on the screen right) in destination bitplane
	lea 	foregroundTilemap,a1		
	move.l	a2,a4
	sub.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS*8,a4
	sub.l	d0,d0
	move.w	(a4),d0
	add.l	d0,a1
	move.l	foregroundMapPtr,a3
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
	cmp.l	#0,foregroundScrollPixels
	beq	.s1	
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

	move.w	d0,d1
	move.w	#(32*4)<<6|(8),d0
	lea	mpanelOrig,a0
	lea	mpanel,a2
	add.l	#(40*4*8),a2
	jsr	SimpleBlit
	
	lea	mpanel,a0
	move.w	d1,d0
	move.w	#11,d1
	jsr	DrawMaskedText8
	bsr	ShowMessagePanel
	rts

	
RenderCounter:
	lea	panel,a0
	move.w	#20,d1
	jsr	DrawText8
	rts


ResetCounter:
	move.l	#"0000",(a0)
	rts
	
IncrementCounter:
	move.l	a0,a1
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
	cmp.l	a1,a0
	blt	.startOfText
	bra	.loop
.done:
	move.b	d0,(a0)
.startOfText:
	rts


DecrementCounter:
	move.l	a0,a1	
	add.l	#3,a0
.loop:
	sub.l	d0,d0
	move.b	(a0),d0
	cmp.b	#'0',d0
	beq	.dontWrap
	subq.b	#1,d0
	bra	.done
.dontWrap:
	move.b	#'9',d0
	move.b	d0,(a0)	
	sub.l	#1,a0
	cmp.l	a1,a0
	blt	.startOfText	
	bra	.loop
.done:
	move.b	d0,(a0)
.startOfText:
	rts	


player1Text:
	dc.b	"P1"
	dc.b	0
	align	4

player2Text:
	dc.b	"P2"
	dc.b	0
	align	4	
	
message:
	dc.b	"LETS PLAY!"
	dc.b	0
	align 	4
	
gameOverMessage:
	dc.b	"GAME OVER"
	dc.b	0
	align 	4

levelCompleteMessage:
	dc.b	"LEVEL COMPLETE!"
	dc.b	0
	align 	4		

skippedFramesCounterText:
	dc.b	"0000"
	dc.b	0
	align 	4
	
livesCounterText:
	dc.b	"00"
livesCounterShortText:
	dc.b	"04"
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

InstallSpriteColorPalette:
	jsr	InstallPlayerColorPalette
	include "out/sprite_coin-1-palette.s"
	include "out/sprite_arrow-1-palette.s"	
	rts
	
InstallGreyPalette:
	lea	playAreaCopperPalettePtr1,a1
	lea	playAreaCopperPalettePtr2,a2
	lea	playAreaCopperPalettePtr3,a3
	move.l	playareaFade,a0
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
	move.l	flagsFade,a0
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

	if SPLASH_USE_FOREGROUND=1	
InstallBlackPalette:
	move.w #$000,COLOR00(a6)
	move.w #$000,COLOR01(a6)
	move.w #$000,COLOR02(a6)
	move.w #$000,COLOR03(a6)
	move.w #$000,COLOR04(a6)
	move.w #$000,COLOR05(a6)
	move.w #$000,COLOR06(a6)
	move.w #$000,COLOR07(a6)
	move.w #$000,COLOR08(a6)
	move.w #$000,COLOR09(a6)
	move.w #$000,COLOR10(a6)
	move.w #$000,COLOR11(a6)
	move.w #$000,COLOR12(a6)
	move.w #$000,COLOR13(a6)
	move.w #$000,COLOR14(a6)
	move.w #$000,COLOR15(a6)
	move.w #$000,COLOR16(a6)
	move.w #$000,COLOR17(a6)
	move.w #$000,COLOR18(a6)
	move.w #$000,COLOR19(a6)
	move.w #$000,COLOR20(a6)
	rts
	endif
	
InstallTilePalette:
	move.l	tileFade,tileFadePtr
	lea	playAreaCopperPalettePtr2,a1	
	add.l	#6,a1 		; point to COLOR01
	move.l	tileFade,a0
	move.l	#1,d0
.loop:
	move.w	(a0),(a1)
	add.l	#2,a0
	add.l	#4,a1
	dbra	d0,.loop
	rts
	
InstallNextPathwayColor:
	lea	playAreaCopperPalettePtr2,a1
	add.l	#6,a1 		; point to COLOR01
	move.l	tileFadePtr,a0
	move.l	tileFade,a5
	add.l	#(paletteA_tileFadeFadeComplete-paletteA_tileFade),a5
	;; 	lea	tileFadeFadeComplete,a5
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
	;; move.l	#tileFade,tileFadePtr
.done:
	rts
	
InstallNextGreyPalette:
	lea	playAreaCopperPalettePtr1,a1
	lea	playAreaCopperPalettePtr2,a2
	lea	playAreaCopperPalettePtr3,a3
	lea	panelCopperPalettePtr,a4 ; write color00 for the panel palette here
	move.l	playareaFadePtr,a0
	move.l	playareaFade,a5
	add.l	#(paletteA_playareaFadeComplete-paletteA_playareaFade),a5
	cmp.l	a5,a0
	bge	.done
	add.l	#2,a1
	add.l	#2,a2
	add.l	#2,a3
	add.l	#2,a4			; write color00 for the panel palette here
	move.w	(a0),(a4)		; write color00 for the panel palette here
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
	add.l	#6,a1		; start at color01 as color00 was written in InstallNextGreyPalette
	add.l	#2,a0		; start at color01 as color00 was written in InstallNextGreyPalette
	move.l	#14,d0		; only 15 colors as color00 isn't written
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
	move.l	flagsFade,a5
	add.l	#(paletteA_flagsFadeComplete-paletteA_flagsFade),a5
	;; 	lea	flagsFadeComplete,a5
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


InstallPaletteA:
	move.l	#paletteA_playAreaPalette,playAreaPalette
	move.l	#paletteA_playareaFade,playareaFade
	move.l	#paletteA_flagsFade,flagsFade
	move.l	#paletteA_tileFade,tileFade
	rts

InstallPaletteB:
	move.l	#paletteB_playAreaPalette,playAreaPalette
	move.l	#paletteB_playareaFade,playareaFade
	move.l	#paletteB_flagsFade,flagsFade
	move.l	#paletteB_tileFade,tileFade
	rts	
	
foregroundOnscreen:
	dc.l	foregroundBitplanes1
foregroundOffscreen:
	dc.l	foregroundBitplanes1+IMAGESIZE	
foregroundTilemap:
	incbin "out/foreground.bin"
panel:
	incbin "out/panel.bin"
mpanel:
	incbin "out/mpanel.bin"
mpanelOrig:
	incbin "out/mpanelOrig.bin"
level1ForegroundMap:
	include "out/foreground-map.s"
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF		
level1PathwayMap:
	include "out/pathway-map.s"
itemsMap:
	include "out/items-indexes.s"
itemsMapOffset:
	dc.l	itemsMap-level1ForegroundMap
foregroundMapPtr:
	dc.l	0
pathwayMapPtr:
	dc.l	0
startForegroundMapPtr:
	dc.l	level1ForegroundMap
startPathwayMapPtr:
	dc.l	level1PathwayMap	
	
	

foregroundScrollPixels:
	dc.l	FOREGROUND_SCROLL_PIXELS	
foregroundScrollX:
	dc.l	0
frameCount:
	dc.l	0
verticalBlankCount:
	dc.l	0
movingCounter:
	dc.w	0
moving:
	dc.w	0

foregroundPlayerTileAddress:
	dc.l	0
pathwayRenderPending:
	dc.w	0
pathwayPlayerTileAddress:
	dc.l	0
pathwayClearPending:
	dc.w	0
pathwayFadeCount:
	dc.w	0
	
tileFadePtr:
	dc.l	0
playareaFadePtr:
	dc.l	0
panelFadePtr:
	dc.l	panelFade
flagsFadePtr:
	dc.l	0
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

panelGreyPalette:
	include "out/panel-grey-table.s"
	
paletteA_playAreaPalette:
	include	"out/paletteA_foreground-palette-table.s"
	include	"out/background-palette-table.s"	

paletteA_playareaFade:
	include "out/paletteA_playarea_fade.s"

paletteA_flagsFade:
	include "out/paletteA_flags_fade.s"	

paletteA_tileFade:
	include "out/paletteA_tileFade.s"

paletteB_playAreaPalette:
	include	"out/paletteB_foreground-palette-table.s"
	include	"out/background-palette-table.s"	

paletteB_playareaFade:
	include "out/paletteB_playarea_fade.s"

paletteB_flagsFade:
	include "out/paletteB_flags_fade.s"	

paletteB_tileFade:
	include "out/paletteB_tileFade.s"

playAreaPalette:
	dc.l	paletteA_playAreaPalette
playareaFade:
	dc.l	paletteA_playareaFade
flagsFade:
	dc.l	paletteA_flagsFade
tileFade:
	dc.l	paletteA_tileFade

paletteInstallers:
	dc.l	InstallPaletteA	
	dc.l	InstallPaletteB
	dc.l	0

nextPaletteInstaller:
	dc.l	paletteInstallers+4
	
panelFade:
	include "out/panelFade.s"	


foregroundBitplanes1:
	if SPLASH_USE_FOREGROUND=1
	incbin "out/splash.bin"
	endif	
.endSplash
	ds.b	(IMAGESIZE*2)-(.endSplash-foregroundBitplanes1)
	section .bss
startUserstack:
	ds.b	$1000		; size of stack
userstack:

	end