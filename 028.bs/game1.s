	include "includes.i"

	xdef    LevelComplete
	xdef    BigBang
	xdef	InstallTilePalette
	
	xdef	pathwayRenderPending
	xdef	pathwayPlayerTileAddress
	xdef	pathwayFadeCount	
	xdef	pathwayClearPending
	xdef	pathwayMapPtr
	
	xdef	foregroundOnscreen
	xdef	foregroundOffscreen
	xdef	foregroundScrollX
	xdef	foregroundBitplanes1	
	xdef	foregroundPlayerTileAddress	
	xdef	foregroundMapPtr
	xdef	foregroundTilemap
	xdef 	foregroundScrollPixels
	
	xdef	startForegroundMapPtr
	xdef 	startPathwayMapPtr

	xdef	moving	
	xdef   	itemsMapOffset
	xdef	livesCounterText
	xdef	panel

	xdef	nextLevelInstaller
	xdef	levelInstallers

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
MainMenu:
	jsr	ShowMenu

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

	jsr	InitialiseMessagePanel	
	lea	nullText,a1
	jsr	Message

	jsr	Init		  ; enable the playfield
	jsr	InstallSpriteColorPalette

	move.w	#(DMAF_SPRITE|DMAF_BLITTER|DMAF_SETCLR|DMAF_COPPER|DMAF_RASTER|DMAF_MASTER),DMACON(a6)

	bra	InitialiseNewGame

Reset:
	move.w	#0,stopScrollingPending	
	move.w	#218,d0
	lea	livesCounterShortText,a1	
	jsr	RenderCounter	
	lea	player1Text,a1
	move.w	#192,d0
	jsr	RenderCounter

	move.l  startForegroundMapPtr,foregroundMapPtr
	move.l  startPathwayMapPtr,pathwayMapPtr
	
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
	move.l	startMessage,a1
	jsr	Message
	
MainLoop:
	move.w  #$0024,BPLCON2(a6)
	move.l	#0,frameCount
	
SetupBoardLoop:
	add.l	#1,frameCount
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
	add.l	#1,frameCount
	jsr	WaitForJoystick	
	move.w	#0,moving
	move.l	#FOREGROUND_SCROLL_PIXELS,foregroundScrollPixels
	jsr	HideMessagePanel
	
FadeInLoop:
	add.l	#1,frameCount

	move.l	#0,d0
.loop:
	jsr 	WaitVerticalBlank
	dbra	d0,.loop
	bsr	InstallNextGreyPalette
	cmp.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS+25,frameCount
	bne	.c1
	jsr	ResetPlayer
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
	cmp.w	#1,stopScrollingPending
	bne	.s2
	move.l	#0,foregroundScrollPixels	
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
	jsr	ClearPathway
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
	jsr	VerticalScrollBees
	jsr	DetectBeeCollisions

.backgroundUpdates:
	add.l	#BACKGROUND_SCROLL_PIXELS,backgroundScrollX
	move.l	frameCount,d0
	btst	#FOREGROUND_DELAY_BIT,d0
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
	move.w	pathwayFadeCount,d0
	cmp.w	pathwayFadeTimerCount,d0
	blt	.dontInstallNextPathwayColor
	jsr	InstallNextPathwayColor
.dontInstallNextPathwayColor:
	add.w	#1,pathwayFadeCount
	rts


InitialiseNewGame:
	jsr	InitialiseItems
	jsr	InitialisePlayer
	jsr	InstallNextLevel
	bra	Reset	


GameOver:
	move.l	#levelInstallers,nextLevelInstaller
	lea	gameOverMessage,a1
	jsr	Message
	jsr	WaitForJoystick
	bra	MainMenu


InstallNextLevel:
	move.l	nextLevelInstaller,a0
	cmp.l	#0,(a0)
	bne	.dontResetLevelInstaller
	move.l	#levelInstallers,nextLevelInstaller
	move.l	nextLevelInstaller,a0	
.dontResetLevelInstaller:
	move.l	(a0),a1
	jsr	(a1)
	add.l	#4,a0
	move.l	a0,nextLevelInstaller
	rts
	
LevelComplete:
	PlaySound Yay
	jsr	ResetItems
	jsr	HidePlayer
	jsr 	SelectNextPlayerSprite
	move.l	levelCompleteMessage,a1
	jsr	Message		
	
	bsr	InstallNextLevel
	
	jsr	WaitForJoystick
	
	jsr	ResetItems
	bra	Reset


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


RenderForegroundTile:
	;; a2 - address of tileIndex
	move.l	foregroundScrollX,d0
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0		; convert to pixels
	lsr.w   #3,d0		; bytes to scroll
	move.l	foregroundOffscreen,a0
	add.l	d0,a0
	lea 	foregroundTilemap,a1	
	move.w	(a2),d0
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
	move.w	#1,stopScrollingPending
	rts
	

PostMissedTile:
	lea	livesCounterText,a0
	jsr	DecrementCounter
	bra	Reset

	
BigBang:
.finishScrollLoop: ; finish the current foreground tile scroll to clear any half cleared tiles
	move.l	foregroundScrollX,d0
	lsr.l	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0 ; convert to pixels		
	and.b	#$f,d0
	cmp.b	#$f,d0
	beq	.scrollFinished	
	add.l	#1,frameCount
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
	jsr	WaitVerticalBlank	
	bsr	HoriScrollPlayfield
	jsr 	SwitchBuffers
	jsr	UpdatePlayerFallingAnimation
	jsr	PrepareItemSpriteData

	
	move.l	foregroundMapPtr,a2
	move.l	foregroundScrollX,d0	
	lsr.l   #FOREGROUND_SCROLL_TILE_INDEX_CONVERT,d0
	lsr.l	#1,d0
	and.b   #$f0,d0
	add.l	d0,a2
	add.l	#(FOREGROUND_PLAYAREA_HEIGHT_WORDS-1)*2,a2
	
	move.l	foregroundScrollX,d0
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0	; convert to pixels
	lsr.w   #3,d0					; bytes to scroll
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


InstallSpriteColorPalette:
	jsr	InstallPlayerColorPalette
	include "out/sprite_coin-1-palette.s"
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
	cmp.l	a5,a0
	bge	.done
	move.l	#1,d0 		; 2 colors to update
.loop:
	move.w	(a0),(a1)
	add.l	#2,a0
	add.l	#4,a1
	dbra	d0,.loop
	move.l	tileFadePtr,d1
	add.l	pathwayFadeRate,d1
	move.l	d1,tileFadePtr
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
.done:
	
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
.done:

InstallFlagGreyPalette:
	lea	flagsCopperPalettePtr1,a1
	lea	flagsCopperPalettePtr2,a2
	move.l	flagsFadePtr,a0
	move.l	flagsFade,a5
	add.l	#(paletteA_flagsFadeComplete-paletteA_flagsFade),a5
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


	;; variable prefix
	;; level name
	;; frames before pathway starts fading
	;; pathway fading steps per frame (must be a factor of 64)
	;; frames player pauses between each jump
	;; frames after jump before player miss is checked
	;; level complete name
	;; palette
	Level	1,"STAY ON THE PATHWAYS!",100,2*2,12,10,"LEVEL 1",A
	Level	2,"COLLECT COINS!",100,2*2,12,10,"LEVEL 2",A
	Level	3,"ARROWS ARE YOUR FRIEND!",100,2*2,12,10,"LEVEL 3",A		
	Level	4,"WATCH OUT FOR BEES!",100,2*2,12,10,"LEVEL 4",A
	Level	5,"REMEMBER THE PATHWAYS BEFORE THEY FADE!",75,2*2,12,10,"LEVEL 5",A
	Level	B,"LEVEL 2",100,2*2,12,10,"2",B
	Level	C,"LEVEL 3",50,4*2,8,6,"3",C
	Palette	A
	Palette	B
	Palette	C	
	
	include "copper.i"

nullText:
	dc.b	0
	align	4
player1Text:
	dc.b	"P1"
	dc.b	0
	align	4
player2Text:
	dc.b	"P2"
	dc.b	0
	align	4		
gameOverMessage:
	dc.b	"GAME OVER"
	dc.b	0
	align 	4
skippedFramesCounterText:
	dc.b	"0000"
	dc.b	0
	align 	4
foregroundOnscreen:
	dc.l	foregroundBitplanes1
foregroundOffscreen:
	dc.l	foregroundBitplanes1+IMAGESIZE	
foregroundTilemap:
	incbin "out/foreground.bin"
panel:
	incbin "out/panel.bin"
itemsMapOffset:
	dc.l	level1ItemsMap-level1ForegroundMap
foregroundScrollPixels:
	dc.l	FOREGROUND_SCROLL_PIXELS
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
levelInstallers:
	dc.l	InstallLevel1
	dc.l	InstallLevel2
	dc.l	InstallLevel3
	dc.l	InstallLevel4
	dc.l	InstallLevel5	
	dc.l	InstallLevelB
	dc.l	InstallLevelC	
	dc.l	0
nextLevelInstaller:
	dc.l	levelInstallers
panelFade:
	include "out/panelFade.s"


	section .bss	
foregroundBitplanes1:
	ds.b	IMAGESIZE*2
playAreaPalette:
	dc.l	0
playareaFade:
	dc.l	0
flagsFade:
	dc.l	0
tileFade:
	dc.l	0
frameCount:
	dc.l	0
verticalBlankCount:
	dc.l	0
movingCounter:
	dc.w	0
moving:
	dc.w	0
pathwayFadeRate
	dc.l	0
pathwayFadeTimerCount:
	dc.w	0
pathwayFadeCount:
	dc.w	0
tileFadePtr:
	dc.l	0
playareaFadePtr:
	dc.l	0
panelFadePtr:
	dc.l	0
flagsFadePtr:
	dc.l	0
startMessage:
	dc.l	0
levelCompleteMessage:
	dc.l	0
foregroundMapPtr:
	dc.l	0
pathwayMapPtr:
	dc.l	0
startForegroundMapPtr:
	dc.l	0
startPathwayMapPtr:
	dc.l	0
foregroundPlayerTileAddress:
	dc.l	0
pathwayRenderPending:
	dc.w	0
pathwayPlayerTileAddress:
	dc.l	0
pathwayClearPending:
	dc.w	0	
foregroundScrollX:
	dc.l	0
livesCounterText:
	dc.b	"00"
livesCounterShortText:
	dc.b	"00"
	dc.b	0
	align	4	
stopScrollingPending:
	dc.w	0
	
startUserstack:
	ds.b	$1000		; size of stack
userstack:

	end