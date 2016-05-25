	include "includes.i"

	xdef ResetPlayer
	xdef GetNextAutoMove
	xdef CheckPlayerMiss
	xdef UpdatePlayer
	xdef ProcessJoystick
	xdef InitialisePlayer
	xdef HidePlayer
	xdef SetupSpriteData
	xdef ScrollSprites
	xdef RenderPlayerScore
	xdef deadSprite 	; used in items
	xdef UpdatePlayerFallingAnimation
	xdef InstallPlayerColorPalette
	xdef SelectNextPlayerSprite
	xdef SpriteEnableAuto

	xdef spriteLagX
	xdef spriteY
	xdef spriteX
	xdef playerXColumn
	xdef playerXColumnLastSafe
	
	xdef playerLevelPausePixels
	xdef playerLevelMissPixels
	
PLAYER_INSTALL_COLOR_PALETTE	equ 0
PLAYER_SPRITE_DATA		equ 4
PLAYER_SPRITE_FALLING_DATA	equ 8	

ResetPlayer:
	bsr	SpriteDisableAuto
	
	move.l	playerSpriteConfig,a0
	move.l	PLAYER_SPRITE_DATA(a0),d0	
	add.l	#6*PLAYER_SPRITE_VERTICAL_BYTES,d0 
	move.l	d0,currentSprite

	move.w	#PATHWAY_CONFIG_FREE,pathwayLastConfig	
	move.w	#0,pathwayMissPending
	
	bsr	SpriteDisableAuto
	move.w	#0,spritePlayerFallingAnimation
	move.w	#PLAYER_INITIAL_X,spriteX
	move.w	#PLAYER_INITIAL_Y,spriteY
	move.w	#PLAYER_INITIAL_Y+16,spriteYEnd
	rts

HidePlayer:
	move.w	#0,spriteX
	move.w	#0,spriteY
	move.w	#0,spriteYEnd
	rts

InitialisePlayer:
	move.l	#PLAYER_LIVES_COUNTER,livesCounterText
	rts
	
ScrollSprites:
	cmp.l	#0,foregroundScrollPixels
	beq	.skip
	sub.w	#1,spriteX
	bra	ScrollItemSprites
.skip:
	rts


UpdatePlayerFallingAnimation:
	move.w	spritePlayerFallingAnimation,d0
	lsr.w	#1,d0
	mulu.w	#PLAYER_SPRITE_VERTICAL_BYTES,d0

	move.l	playerSpriteConfig,a0
	move.l	PLAYER_SPRITE_FALLING_DATA(a0),a0	
	
	add.l	d0,a0
	move.l	a0,currentSprite
	add.w	#1,spritePlayerFallingAnimation
	cmp.w	#4<<1,spritePlayerFallingAnimation
	blt	.dontResetAnimation
	move.w	#0,spritePlayerFallingAnimation
	bsr	HidePlayer
.dontResetAnimation:
	rts


UpdatePlayer:
	move.l	playerSpriteConfig,a0
	move.l	PLAYER_SPRITE_DATA(a0),d0
	move.w	playerPausePixels,d2
	;; right
	cmp.w	spriteR,d2
	bge	.skipRight
	move.w	playerMovePixels,d1
	add.w	d1,spriteX
	add.l	#7*PLAYER_SPRITE_VERTICAL_BYTES,d0 
	move.l	d0,currentSprite

.skipRight
	cmp.w	#0,spriteR
	beq	.notRight
	sub.w	#1,spriteR
	cmp.w   spriteR,d2
	ble	.notRight
	add.l	#6*PLAYER_SPRITE_VERTICAL_BYTES,d0 
	move.l	d0,currentSprite
.notRight:
	;; up
	cmp.w	spriteU,d2
	bge	.skipUp
	cmp.w   #PLAYER_TOP_Y,spriteY
	ble     .skipUp
	move.w	playerMovePixels,d1	
	sub.w	d1,spriteY
	sub.w	d1,spriteYEnd	
	add.l	#1*PLAYER_SPRITE_VERTICAL_BYTES,d0 
	move.l	d0,currentSprite	
.skipUp:
	cmp.w	#0,spriteU
	beq	.notUp
	sub.w	#1,spriteU
	cmp.w   spriteU,d2
	ble	.notUp
	move.l	d0,currentSprite	
.notUp:
	;; down
	cmp.w	spriteD,d2
	bge	.skipDown
	cmp.w   #PLAYER_BOTTOM_Y,spriteY
	bge     .skipDown
	move.w	playerMovePixels,d1
	add.w	d1,spriteY
	add.w	d1,spriteYEnd	
	add.l	#3*PLAYER_SPRITE_VERTICAL_BYTES,d0 
	move.l	d0,currentSprite		
.skipDown:
	cmp.w	#0,spriteD
	beq	.notDown	
	sub.w	#1,spriteD
	cmp.w   spriteD,d2
	ble	.notDown
	add.l	#2*PLAYER_SPRITE_VERTICAL_BYTES,d0 
	move.l	d0,currentSprite			
.notDown:
	;; left
	cmp.w	spriteL,d2
	bge	.skipLeft
	move.w	playerMovePixels,d1
	sub.w	d1,spriteX
	add.l	#5*PLAYER_SPRITE_VERTICAL_BYTES,d0 
	move.l	d0,currentSprite				
.skipLeft
	cmp.w	#0,spriteL
	beq	.notLeft
	sub.w	#1,spriteL
	cmp.w   spriteL,d2
	ble	.notLeft
	add.l	#4*PLAYER_SPRITE_VERTICAL_BYTES,d0 
	move.l	d0,currentSprite					
.notLeft:
	cmp.w	#$cf,spriteX
	blt	.noScroll
.noScroll:
	rts


ProcessJoystick:
	;; 812
	;; 7 3
	;; 654
	jsr	ReadJoystick
	cmp.w	#0,spriteR
	bne	.skip
	cmp.w	#0,spriteU
	bne	.skip
	cmp.w	#0,spriteD
	bne	.skip
	cmp.w	#0,spriteL
	bne	.skip	

	cmp.w	#0,spriteAutoMoveEnabled
	beq	.autoMoveDisabled

	;; Set fast as default, will be overridden to correct speed
	move.w	#PLAYER_FAST_PAUSE_PIXELS,playerPausePixels
	move.w	#PLAYER_FAST_CHECK_MISS_PIXELS,playerMissPixels
		
	bsr	GetNextAutoMove
	cmp.w	#1,d0
	beq	.skip

.autoMoveDisabled:
	cmp.b	#3,joystickpos
 	bne	.notRight
	PlayerMoveRight
.notRight:
	cmp.b	#1,joystickpos
 	bne	.notUp
	PlayerMoveUp
.notUp:
	cmp.b	#5,joystickpos
 	bne	.notDown
	PlayerMoveDown
.notDown:
	cmp.b	#7,joystickpos
 	bne	.notLeft
	PlayerMoveLeft
.notLeft:	
.skip:
	rts

SpriteEnableAuto:
	PlaySound Whoosh
	CompareScore SCORE_ARROW_SUBTRACTION
	ble	.toZero
	AddToScore SCORE_ARROW_SUBTRACTION
	bra	.done
.toZero:
	ResetScore
.done:
	move.w	#1,spriteAutoMoveEnabled
	bsr	RenderPlayerScore
	rts

SpriteDisableAuto:
	move.w	#0,spriteAutoMoveEnabled
	move.w	#PLAYER_JUMP_PIXELS,playerJumpPixels
	move.w	#PLAYER_MOVE_PIXELS,playerMovePixels
	move.w	playerLevelPausePixels,playerPausePixels
	move.w	playerLevelMissPixels,playerMissPixels		
	rts
	
SetupSpriteData:
	move.l	currentSprite,a0
	move.w	spriteLagX,d0
	move.w	d0,d1
	andi	#1,d1

	lsr.l	#1,d0
	move.b	d0,1(a0)	;spriteHStart
	move.w	spriteY,d0
	move.b	d0,(a0)		;spriteVStart
	andi.w	#$100,d0
	cmp.w	#0,d0
	beq	.s1
	ori.w	#$4,d1
.s1:
	move.w	spriteYEnd,d0
	move.b	d0,2(a0)	;spriteVStop
	move.l	a0,SPR0PTH(a6)

	andi.w	#$100,d0
	cmp.w	#0,d0
	beq	.s2
	ori.w	#$2,d1
.s2:	
	
	move.b	d1,3(a0)	;spriteControl	
	
	jsr 	SetupItemSpriteData
	
	move.l	#deadSprite,SPR1PTH(a6) ; unused - could only use if sprite resused player sprite palette
	move.l	#deadSprite,SPR6PTH(a6) ; unused - incompatible with oversize playfield data fetch
	move.l	#deadSprite,SPR7PTH(a6)	; unused - incompatible with oversize playfield data fetch
	rts

InstallPlayerColorPalette:
	move.l	playerSpriteConfig,a0
	move.l	PLAYER_INSTALL_COLOR_PALETTE(a0),a1
	jsr	(a1)
	rts
	
InstallPigColorPalette:	
	include "out/sprite_pig-0-palette.s"
	rts

InstallRobotColorPalette:	
	include "out/sprite_robot-0-palette.s"
	rts

InstallTankColorPalette:	
	include "out/sprite_tank-0-palette.s"
	rts			

CheckPlayerMiss:
	;; check if player has fallen off the left side of the play area
	cmpi.w	#PLAYER_INITIAL_X-15,spriteX
	blt	.doBigBang

	move.w	playerMissPixels,d1
	cmp.w	spriteR,d1
	beq	.check
	move.w	playerMissPixels,d1
	cmp.w	spriteU,d1	
	beq	.check
	move.w	playerMissPixels,d1
	cmp.w	spriteD,d1	
	beq	.check
	move.w	playerMissPixels,d1
	cmp.w	spriteL,d1	
	beq	.check
	rts

.check:
	cmp.w	#1,pathwayMissPending
	beq	.doBigBang

	move.w	#PATHWAY_CONFIG_FREE,pathwayLastConfig		
	
	move.l	pathwayMapPtr,a2	
	move.l	foregroundMapPtr,a3

	;; calculate the a2 offset of the top right tile based on foreground scroll
	move.l	foregroundScrollX,d0		
	lsr.l   #FOREGROUND_SCROLL_TILE_INDEX_CONVERT,d0
	lsr.l	#1,d0
	and.b   #$f0,d0
	add.l	d0,a2
	add.l	d0,a3	


	;; add the offset based on the sprite's x position
	move.w	spriteX,d0
	;; move.w	spriteLagX,d0
	cmpi.w  #PLAYER_LEFT_X,d0
	blt	.doBigBang
	sub.w	#PLAYER_LEFT_X,d0
	lsr.w	#4,d0      	; x columns
	
	move.l	#(FOREGROUND_PLAYAREA_WIDTH_WORDS/2)-1,d1
	sub.w	d0,d1
	mulu.w  #FOREGROUND_PLAYAREA_HEIGHT_WORDS*2,d1
	sub.l	d1,a2		; player x if y == bottom ?
	sub.l	d1,a3		; player x if y == bottom ?	


	;; add the offset based on the sprite's y postion
	move.w	#PLAYER_BOTTOM_Y,d0
	sub.w	spriteY,d0
	lsr.w	#4,d0      	; y columns
	sub.l	d1,d1
	move.w	#FOREGROUND_PLAYAREA_HEIGHT_WORDS-1,d1
	sub.w	d0,d1
	lsl.w	#1,d1
	add.l	d1,a2
	add.l	d1,a3	

	;; a2 now points at the pathway tile under the sprite
	move.l	a2,pathwayPlayerTileAddress	
	move.w	(a2),d0
	move.w	d0,spriteCurrentPathwayTile
	bsr	CheckDirection
	
	cmp.w	#$78e,d0
	bge	.noBigBang

	;; a3 now points at the tile under the sprite
	move.l	a3,foregroundPlayerTileAddress
	move.w	(a3),d0	
	
	cmp.w	#FOREGROUND_TILE_EMPTY,d0	; empty tile
	bge	.doBigBang	

	cmp.w	#FOREGROUND_TILE_ENDLEVEL,d0
	beq	.levelComplete
	
	cmp.w	#$78e,d0
	bge	.noBigBang

.doBigBang:
	jmp	BigBang

.levelComplete:
	jmp	LevelComplete
	
.noBigBang:
	move.w	(a3),d0	
	cmp.w	#$1e00,d0
	blt	.dontRenderPathway		
	move.w	#2,pathwayRenderPending
	move.w	#0,pathwayFadeCount
	jsr	InstallTilePalette		
.dontRenderPathway:

	cmp.w	#$f02,d0
	beq	.clearPathway
	cmp.w	#$1682,d0
	beq	.clearPathway	
	bra	.dontClearPathway
.clearPathway:
	move.w	#2,pathwayClearPending
	move.l  playerXColumn,playerXColumnLastSafe


	move.l	#PLAYER_BOTTOM_Y,d0	
	sub.w	spriteY,d0
	lsr.w	#4,d0      	; y columns
	move.w	#FOREGROUND_PLAYAREA_HEIGHT_WORDS-1,d1
	sub.l	d0,d1
	mulu.w	#2,d1
	sub.l	d1,a3
	sub.l	d1,a2	
	move.l	a3,startForegroundMapPtr
	move.l	a2,startPathwayMapPtr	
	
.dontClearPathway:

	jsr	DetectItemCollisions		
	rts


GetNextAutoMove:
	move.w	spriteCurrentPathwayTile,d0
	lsr.w	#4,d0

	cmp.w	#$708,d0
	beq	.horizontal
	cmp.w	#$690,d0
	beq	.topLeft
	cmp.w	#$5a0,d0
	beq	.leftBottom
	cmp.w	#$4b0,d0
	beq	.rightBottom
	cmp.w	#$528,d0
	beq	.topRight
	cmp.w	#$618,d0
	beq	.vertical
	bra	.skip
.horizontal:
	cmp.w	#PLAYER_MOVE_RIGHT,spriteLastMove
	beq	.goRight
	bra	.goLeft
.topLeft:
	cmp.w	#PLAYER_MOVE_RIGHT,spriteLastMove
	beq	.goUp
	bra	.goLeft
.leftBottom:
	cmp.w	#PLAYER_MOVE_RIGHT,spriteLastMove
	beq	.goDown
	bra	.goLeft	
.topRight:
	cmp.w	#PLAYER_MOVE_DOWN,spriteLastMove
	beq	.goRight
	bra	.goUp
.rightBottom:
	cmp.w	#PLAYER_MOVE_UP,spriteLastMove
	beq	.goRight
	bra	.goDown
.vertical:
	cmp.w	#PLAYER_MOVE_UP,spriteLastMove
	beq	.goUp
	bra	.goDown
.default:	
	bra	.skip

.goRight:
	PlayerMoveRight
	bra	.done
.goUp:
	PlayerMoveUp
	bra	.done
.goDown:
	PlayerMoveDown
	bra	.done	
.goLeft:
	PlayerMoveLeft
	bra	.done
.done:
	move.w	#1,d0
	rts
.skip:
	bsr	SpriteDisableAuto	
	move.w	#0,d0
	rts
	
CheckDirection:
	move.w	playerMissPixels,d1
	cmp.w	#$7080,d0 	; dark horizontal
	beq	.horizontal
	cmp.w	#$708c,d0	; light horizontal
	beq	.horizontal

	cmp.w	#$6900,d0	; dark left-top
	beq	.topLeft
	cmp.w	#$690c,d0	; light left-top
	beq	.topLeft

	cmp.w	#$5a00,d0	; dark left-bottom
	beq	.leftBottom
	cmp.w	#$5a0c,d0	; light left-bottom
	beq	.leftBottom			

	cmp.w	#$4b00,d0	; dark right-bottom
	beq	.rightBottom
	cmp.w	#$4b0c,d0	; light right-bottom
	beq	.rightBottom

	cmp.w	#$5280,d0	; dark top-right
	beq	.topRight
	cmp.w	#$528c,d0	; light top-right
	beq	.topRight

	cmp.w	#$6180,d0	; dark vertical
	beq	.vertical
	cmp.w	#$618c,d0	; light vertical
	beq	.vertical	

	cmp.w	#0,d0
	beq	.ok
	jmp	BigBang		
	
.horizontal:
	move.w	#PATHWAY_CONFIG_HORIZONTAL,pathwayLastConfig
	cmp.w	spriteR,d1
	beq	.ok
	cmp.w	spriteL,d1
	beq	.ok	
	jmp	BigBang
.vertical:
	move.w	#PATHWAY_CONFIG_VERTICAL,pathwayLastConfig
	cmp.w	spriteU,d1
	beq	.ok
	cmp.w	spriteD,d1
	beq	.ok
	jmp	BigBang
.topLeft:
	move.w	#PATHWAY_CONFIG_TOP_LEFT,pathwayLastConfig		
	cmp.w	spriteR,d1
	beq	.ok
	cmp.w	spriteD,d1
	beq	.ok	
	jmp	BigBang
.topRight:
	move.w	#PATHWAY_CONFIG_TOP_RIGHT,pathwayLastConfig		
	cmp.w	spriteD,d1
	beq	.ok
	cmp.w	spriteL,d1
	beq	.ok		
	jmp	BigBang			
.rightBottom:
	move.w	#PATHWAY_CONFIG_BOT_RIGHT,pathwayLastConfig	
	cmp.w	spriteU,d1
	beq	.ok
	cmp.w	spriteL,d1
	beq	.ok		
	jmp	BigBang		
.leftBottom:
	move.w	#PATHWAY_CONFIG_BOT_LEFT,pathwayLastConfig	
	cmp.w	spriteR,d1
	beq	.ok
	cmp.w	spriteU,d1
	beq	.ok		
	jmp	BigBang	
.ok:
	rts

	
SelectNextPlayerSprite:
	cmp.l	#tankPlayerSpriteConfig,playerSpriteConfig
	beq	.s1
	add.l	#3*4,playerSpriteConfig
	bra	.done
.s1:
	move.l	#pigPlayerSpriteConfig,playerSpriteConfig
.done:
	bsr	InstallPlayerColorPalette	
	rts


UpdatePlayerScore:
	AddToScore 10
RenderPlayerScore:
	jsr	RenderScore
	move.l	playerXColumn,d0
	move.w	#PANEL_COLUMNS_REMAINING_X,d1
	jsr	RenderNumber5	
	rts
	
	
pigPlayerSpriteConfig:
	dc.l	InstallPigColorPalette
	dc.l	spritePig
	dc.l	spriteFalling1

robotPlayerSpriteConfig:
	dc.l	InstallRobotColorPalette
	dc.l	spriteRobot
	dc.l	spriteFallingRobot1

tankPlayerSpriteConfig:
	dc.l	InstallTankColorPalette
	dc.l	spriteTank
	dc.l	spriteFallingTank1	

playerSpriteConfig:
	dc.l	pigPlayerSpriteConfig
	
	include "sprite_data.i"

spritePlayerFallingAnimation:
	dc.w	0
currentSpriteOffset:
	dc.l	0
currentSprite:
	dc.l	spritePig
deadSprite:
	dc.l	0
spriteR:
	dc.w	0
spriteL:
	dc.w	0
spriteU:
	dc.w	0
spriteD:
	dc.w	0	
spriteLagX:
	dc.w	0
spriteX:
	dc.w	$0
spriteY:
	dc.w	$e4
spriteYEnd:
	dc.w	$f5
spriteCurrentPathwayTile:
	dc.w	0
spriteLastMove:
	dc.w	0
spriteAutoMoveEnabled:
	dc.w	0
playerMovePixels:
	dc.w	PLAYER_MOVE_PIXELS
playerJumpPixels:
	dc.w	PLAYER_JUMP_PIXELS
playerPausePixels:
	dc.w	0
playerMissPixels:
	dc.w	0
playerLevelPausePixels:
	dc.w	0
playerLevelMissPixels
	dc.w	0
pathwayLastConfig:
	dc.w	PATHWAY_CONFIG_FREE
pathwayMissPending:
	dc.w	0
playerXColumn:
	dc.l	0
playerXColumnLastSafe:
	dc.l	0	