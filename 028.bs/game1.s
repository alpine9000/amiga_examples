	include "includes.i"

	xdef	StartGame
	xdef	QuitGame
	xdef    LevelComplete
	xdef    BigBang
	xdef	InstallTilePalette
	xdef 	RevealPathway
	xdef	FreezeScrolling
	xdef	PostCheckPlayerMiss
	
	xdef	pathwayRenderPending
	xdef	pathwayPlayerTileAddress
	xdef	pathwayLastSafeTileAddress
	xdef	pathwayFadeCount	
	xdef	pathwayClearPending
	xdef	pathwayMapPtr
	
	xdef	foregroundOnscreen
	xdef	foregroundOffscreen
	xdef	foregroundScrollX
	xdef	foregroundBitplanes1	
	xdef	foregroundPlayerTileAddress	
	xdef	foregroundLastSafeTileAddress
	xdef	foregroundMapPtr
	xdef	foregroundTilemap
	xdef 	foregroundScrollPixels
	
	xdef	startForegroundMapPtr
	xdef 	startPathwayMapPtr

	xdef	frameCount
	xdef	moving	
	xdef   	itemsMapOffset
	xdef	itemsMapEndPtr
	xdef	livesCounterText
	xdef	livesCounterShortText	
	xdef	panel

	xdef	nextLevelInstaller
	xdef	levelInstallers
	xdef	tutorialLevelInstallers

	if TRACKLOADER=1
byteMap:
	dc.l	Entry
	dc.l	endCode-byteMap
	endif


	include "wbstartup.i"
	
Entry:
	if TRACKLOADER=0
	jmp 	StartupFromOS
	else
	lea	userstack,a7	
	endif
Entry2:
	
	lea 	CUSTOM,a6

	move	#$7ff,DMACON(a6)	; disable all dma
	move	#$7fff,INTENA(a6) 	; disable all interrupts		

	jsr 	WaitVerticalBlank		

	move.w	#$7FFF,d0
	move.w	d0,$9A(a6)	; Disable Interrupts
	move.w	d0,$96(a6)	; Clear all DMA channels
	move.w	d0,$9C(a6)	; Clear all INT requests
	move.w	d0,$9C(a6)	; Clear all INT requests	

	move.w	#$0C00,$106(a6) ;BPLCON3
	move.w	#$0011,$10C(a6) ;BPLCON4	
	
	lea	Level3InterruptHandler,a3
 	move.l	a3,LVL3_INT_VECTOR

	move.w	#0,d0
	jsr	StartMusic
	jsr	ShowSplash
MainMenu:
	jmp	ShowMenu
StartGame:
	jsr 	BlueFill
	jsr	InitialiseBackground

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
	move.w	#1,splashInvalid
	move.w	#0,stopScrollingPending	
	move.w	#PANEL_LIVES_X,d0
	lea	livesCounterShortText,a1	
	jsr	RenderCounter	
	lea	player1Text,a1
	move.w	#PANEL_PLAYER1_X,d0
	jsr	RenderCounter
	move.l  playerXColumnLastSafe,playerXColumn
	jsr	PreRenderColumnsRemaining
	jsr	RenderPlayerScore
	jsr	ResetPickups
	jsr	ResetSound
	
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
	move.w	#0,freezeCountdownCounter
	bsr	RenderFreezeCountdown	
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
	bsr	Update

	jsr	RenderNextForegroundFrame
	jsr	PrepareItemSpriteData			

	jsr 	SwitchBackgroundBuffers2
	move.w	#15,d5
	sub.l	#BACKGROUND_SCROLL_PIXELS,backgroundScrollX			
.renderNextBackgroundFrameLoop:	
	add.l	#BACKGROUND_SCROLL_PIXELS,backgroundScrollX		
	jsr	RenderNextBackgroundFrame
	jsr 	SwitchBackgroundBuffers2
	dbra	d5,.renderNextBackgroundFrameLoop

	cmp.l	#FOREGROUND_PLAYAREA_WIDTH_WORDS,frameCount	
	bge	.gotoGameLoop
	bra	SetupBoardLoop
.gotoGameLoop:
	jsr 	SwitchBackgroundBuffers	
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
	jsr	EnableBobs
	bra	GameLoop
.c1:
	bra	FadeInLoop


GameLoop:	
	RenderSkippedFramesCounter
	add.l	#1,frameCount
	jsr	WaitVerticalBlank
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
	cmp.w	#0,freezeCountdownCounter
	bgt	.notMoving
	move.w	#1,moving
.notMoving:

	bsr 	Update
	jmp	CheckPlayerMiss
PostCheckPlayerMiss:	
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

	
	jsr	PlayNextSound
	jsr	PrepareItemSpriteData
	jsr	FlashPickup

	bra	GameLoop

	if TRACKLOADER=0
QuitGame:
	jsr	WaitVerticalBlank	
	jsr	PlayNextSound
	IntsOff
	jsr	WaitVerticalBlank		
	movem.l	d0-a6,-(sp)
	jsr	P61_End
	movem.l	(sp)+,d0-a6
	jmp	LongJump
	endif

Update:	
	jsr	UpdatePlayer
	jsr	VerticalScrollBees
	jsr	DetectBeeCollisions

	cmp.w	#0,freezeCountdownCounter
	beq	.notFrozen
	bsr	UpdateFreezeCountdown
.notFrozen:
	
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

RevealPathway:
	move.w	#50,pathwayFadeCount
	jsr	InstallTilePalette
	rts

FreezeScrolling:
	move.w	#150,freezeCountdownCounter
	move.w	#0,moving	
	rts

InitialiseNewGame:
	jsr	InitialiseItems
	jsr	InitialisePlayer
	jsr	InitialisePickups
	jsr	InstallNextLevel
	bra	Reset	


GameOver:
	sub.l	#4,nextLevelInstaller
	cmp.l	#tutorialLevelInstallers,nextLevelInstaller
	blt	.notTutorial
	move.l	#levelInstallers,nextLevelInstaller
	move.l	#"0001",levelCounter
	bra	.dontRegisterHighScore
.notTutorial:
	jsr	RegisterHighScore
.dontRegisterHighScore:
	lea	gameOverMessage,a1
	jsr	Message
	jsr	WaitForJoystick
	jsr	RestorePanel

	jmp	ShowHighScore
	
TutorialOver:
	jsr	RestorePanel
	add.l	#8,sp		; dirty hack - unwind the call stack
	move.l	#levelInstallers,nextLevelInstaller
	move.l	#"0001",levelCounter
	lea	tutorialOverMessage,a1	
	jsr	Message
	jsr	WaitForJoystick
	jsr	RestorePanel
	bra	MainMenu

InstallNextLevel:
	move.l	nextLevelInstaller,a0
	cmp.l	#endTutorialLevelInstaller,a0
	beq	TutorialOver
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
	jsr	ResetBobs	
	jsr	ResetItems
	jsr	HidePlayer
	move.l	levelCompleteMessage,a1
	jsr	Message
	jsr	WaitForJoystick	
	bsr	InstallNextLevel
	jsr	RestorePanel	
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
	move.l	#(FOREGROUND_PLAYAREA_WIDTH_WORDS/2),d1
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
	lea 	animIndex,a4
	move.l	d2,d1
	lsl.l	#2,d1
	add.l	d1,a4
	move.l	(a4),d1
	lsr.l	#2,d1		; anim scaling (speed)
	cmp.l	#10,d1
	bge	.s1
	add.l	d1,a1
	cmp.l	endForegroundMapPtr,a2
	bge	.dontBlit
	jsr	BlitTile
.dontBlit:
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
	jsr	InitialisePickups
	lea	livesCounterText,a0
	jsr	DecrementCounter
	bra	Reset

	
BigBang:
	PlaySound Falling
	jsr	WaitVerticalBlank
	jsr	ResetBobs
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
	move.l	#(FOREGROUND_PLAYAREA_WIDTH_WORDS/2)-0,d5
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
	cmp.l	endForegroundMapPtr,a2
	bge	.s1
	move.w	(a2),d0
	add.l	d0,a1
	move.l	(a4),d1
	cmp.l	#10,d1
	bge	.s1	
	cmp.l	#0,d5 		; this is the last row which might have partially animated tiles so
	beq	.s1 		; clear it to prevent backwards animations
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
	cmp.w	#0,P61_Master
	beq	.checkCopper
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


UpdateFreezeCountdown:	
	sub.w	#1,freezeCountdownCounter
RenderFreezeCountdown:
	move.w	freezeCountdownCounter,d0
	cmp.w	#0,d0
	beq	.skip
	ext.l	d0
	divu.w	#50,d0
	add.w	#2,d0
	bsr	BlitCountdown
	rts
.skip:
	move.w	#0,d0
	bsr	BlitCountdown	
	rts	
	
BlitCountdown:
	WaitBlitter	
	;; d0.w	countdown digit
	lsl.w	#1,d0 		; *2 because I was lazy (look at image)
	move.w 	#BC0F_SRCB|BC0F_SRCC|BC0F_DEST|$ca,BLTCON0(a6)
	lea	countdownImages,a0	
	move.l	#panel+(SCREEN_WIDTH_BYTES/2)+(SCREEN_WIDTH_BYTES*PANEL_BIT_DEPTH*18),a1	
	adda.w	d0,a0	
	move.w 	#4<<12,BLTCON1(a6) 
	move.w 	#$0ff0,BLTALWM(a6)
	move.w 	#$ffff,BLTAFWM(a6)
	move.w 	#$ffff,BLTADAT(a6) ; preload source mask so only BLTA?WM mask is used	
	move.w 	#(COUNTDOWN_BITMAP_WIDTH/8)-COUNTDOWN_BLIT_WIDTH_BYTES,BLTBMOD(a6)
	move.w 	#SCREEN_WIDTH_BYTES-COUNTDOWN_BLIT_WIDTH_BYTES,BLTCMOD(a6)
	move.w 	#SCREEN_WIDTH_BYTES-COUNTDOWN_BLIT_WIDTH_BYTES,BLTDMOD(a6)
	move.l 	a0,BLTBPTH(a6)	;source graphic top left corner
	move.l 	a1,BLTCPTH(a6) ;destination top left corner
	move.l  a1,BLTDPTH(a6) ;destination top left corner	
	move.w 	#(12*PANEL_BIT_DEPTH)<<6|(COUNTDOWN_BLIT_WIDTH_WORDS),BLTSIZE(a6)
	rts


	include "os.i"

	;; \1 variable prefix
	;; \2 level name
	;; \3 frames before pathway starts fading
	;; \4 pathway fading steps per frame (must be a factor of 64)
	;; \5 frames player pauses between each jump
	;; \6 frames after jump before player miss is checked
	;; \7 level complete name
	;; \8 palette
	;; \9 num columns
	;; \a music module index
	;; \b 0 = load from disk, 1 = resident
	;; \c sprite
	Level	91,"STAY ON THE PATHWAYS!",100,2*2,12,10,"WELL DONE!",A,21,0,1,pig
	Level	92,"COLLECT COINS!",100,2*2,12,10,"NEXT COLLECT AN ARROW...",A,21,0,1,pig
	Level	93,"PRESS FIRE TO ACTIVATE THE ARROW",100,2*2,12,10,"WHOO HOO!",A,21,0,1,pig
	Level	94,"WATCH OUT FOR BEES!",100,2*2,12,10,"LOL - BEES :-)",A,21,0,1,pig
	Level	95,"REMEMBER THE PATHWAYS BEFORE THEY FADE!",75,2*2,12,10,"CLOCKS WILL STOP THE BOARD MOVING",A,21,0,1,pig
	Level	96,"PRESS FIRE TO ACTIVATE THE CLOCK",200,2*2,12,10,"EYES WILL UNHIDE THE BOARD",A,21,0,1,pig
	Level	97,"PRESS FIRE TO ACTIVATE THE EYE",100,2*2,12,10,"YOU DID IT!",A,21,0,1,pig

	Level	1,"WELCOME TO BLOCKY SKIES!",75,2*2,12,10,"PHEW!, LEVEL 1 COMPLETE!",A,99,0,1,pig
	Level	2,"HAVING FUN YET?",70,2*2,12,10,"LEVEL 2",B,98,2,0,robot
	Level	3,"GIDDY UP!",50,4*2,8,6,"GETTING FASTER!, LEVEL 3 COMPLETE!",C,98,2,0,pig
	Level	4,"MOO!",75,4*2,8,6,"ALRIGHT! LEVEL 4 COMPLETE!!",E,99,2,0,cow
	Level	5,"KABOOM?!",200,4*2,8,6,"PHEW!!! LEVEL 5 COMPLETE!",D,99,1,0,tank
	Level	6,"WHAT? WHAT?!",50,4*2,8,6,"NICE! LEVEL 6 COMPLETE!",A,98,1,0,cow


	Palette	A
	Palette	B
	Palette	C
	Palette	D
	Palette	E	

levelData:
	ds.b	(level2End-level2Start)+1024
	
	include "copper.i"

nullText:
	dc.b	0
	align	4
player1Text:
	dc.b	"P1"
	dc.b	0
	align	4
gameOverMessage:
	dc.b	"GAME OVER"
	dc.b	0
	align 	4
tutorialOverMessage:
	dc.b	"TUTORIAL COMPLETE!"
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
countdownImages:
	incbin "out/countdown.bin"	
itemsMapOffset:
	dc.l	0
itemsMapEndPtr:
	dc.l	0
foregroundScrollPixels:
	dc.l	FOREGROUND_SCROLL_PIXELS
bigBangIndex:
	ds.l	FOREGROUND_PLAYAREA_HEIGHT_WORDS*FOREGROUND_PLAYAREA_WIDTH_WORDS+1,0	
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
	dc.l	InstallLevel6	
	dc.l	0
nextLevelInstaller:
	dc.l	levelInstallers	

tutorialLevelInstallers:
	dc.l	InstallLevel91
	dc.l	InstallLevel92
	dc.l	InstallLevel93
	dc.l	InstallLevel94
	dc.l	InstallLevel95	
	dc.l	InstallLevel96
	dc.l	InstallLevel97
endTutorialLevelInstaller:	
	dc.l	0	
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
endForegroundMapPtr:
	dc.l	0
startPathwayMapPtr:
	dc.l	0
foregroundPlayerTileAddress:
	dc.l	0
pathwayRenderPending:
	dc.w	0
pathwayPlayerTileAddress:
	dc.l	0
pathwayLastSafeTileAddress:
	dc.l	0
foregroundLastSafeTileAddress:
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
freezeCountdownCounter:
	dc.w	0	
	if TRACKLOADER=1
startUserstack:
	ds.b	$1000		; size of stack
userstack:
	endif
	end