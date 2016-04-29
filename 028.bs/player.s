	include "includes.i"

	xdef CheckPlayerMiss
	xdef UpdatePlayer
	xdef ProcessJoystick
	xdef InitialisePlayer
	xdef HidePlayer
	xdef SetupSpriteData
	xdef ScrollSprites
	xdef deadSprite 	; used in items
	xdef UpdatePlayerFallingAnimation
	xdef InstallPlayerColorPalette
	xdef SelectNextPlayerSprite

	xdef spriteLagX
	xdef spriteY
	
PLAYER_INSTALL_COLOR_PALETTE	equ 0
PLAYER_SPRITE_DATA		equ 4
PLAYER_SPRITE_FALLING_DATA	equ 8	

InitialisePlayer:
	move.l	playerSpriteConfig,a0
	move.l	PLAYER_SPRITE_DATA(a0),d0	
	add.l	#6*PLAYER_SPRITE_VERTICAL_BYTES,d0 
	move.l	d0,currentSprite
	
	move.w	#0,spritePlayerFallingAnimation
	move.w	#PLAYER_INITIAL_X,spriteX
	move.w	#PLAYER_INITIAL_Y,spriteY
	move.w	#PLAYER_INITIAL_Y+16,spriteYEnd
	rts


HidePlayer:
	move.w	#$f000,spriteX
	rts			


ScrollSprites:
	sub.w	#1,spriteX
	bra	ScrollItemSprites
	rts


UpdatePlayerFallingAnimation:
	move.w	spritePlayerFallingAnimation,d0
	lsr.w	#1,d0
	mulu.w	#PLAYER_SPRITE_VERTICAL_BYTES,d0
	;; move.l	#spriteFalling1,a0

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
	;; right
	cmp.w	#PLAYER_PAUSE_PIXELS,spriteR
	ble	.skipRight
	add.w	#PLAYER_MOVE_PIXELS,spriteX
	add.l	#7*PLAYER_SPRITE_VERTICAL_BYTES,d0 
	move.l	d0,currentSprite

.skipRight
	cmp.w	#0,spriteR
	beq	.notRight
	sub.w	#1,spriteR
	cmp.w   #PLAYER_PAUSE_PIXELS,spriteR
	bge	.notRight
	add.l	#6*PLAYER_SPRITE_VERTICAL_BYTES,d0 
	move.l	d0,currentSprite
.notRight:
	;; up
	cmp.w	#PLAYER_PAUSE_PIXELS,spriteU
	ble	.skipUp
	cmp.w   #PLAYER_TOP_Y,spriteY
	ble     .skipUp
	sub.w	#PLAYER_MOVE_PIXELS,spriteY
	sub.w	#PLAYER_MOVE_PIXELS,spriteYEnd	
	add.l	#1*PLAYER_SPRITE_VERTICAL_BYTES,d0 
	move.l	d0,currentSprite	
.skipUp:
	cmp.w	#0,spriteU
	beq	.notUp
	sub.w	#1,spriteU
	cmp.w   #PLAYER_PAUSE_PIXELS,spriteU
	bge	.notUp
	move.l	d0,currentSprite	
.notUp:
	;; down
	cmp.w	#PLAYER_PAUSE_PIXELS,spriteD
	ble	.skipDown
	cmp.w   #PLAYER_BOTTOM_Y,spriteY
	bge     .skipDown
	add.w	#PLAYER_MOVE_PIXELS,spriteY
	add.w	#PLAYER_MOVE_PIXELS,spriteYEnd	
	add.l	#3*PLAYER_SPRITE_VERTICAL_BYTES,d0 
	move.l	d0,currentSprite		
.skipDown:
	cmp.w	#0,spriteD
	beq	.notDown	
	sub.w	#1,spriteD
	cmp.w   #PLAYER_PAUSE_PIXELS,spriteD
	bge	.notDown
	add.l	#2*PLAYER_SPRITE_VERTICAL_BYTES,d0 
	move.l	d0,currentSprite			
.notDown:
	;; left
	cmp.w	#PLAYER_PAUSE_PIXELS,spriteL
	ble	.skipLeft
	sub.w	#PLAYER_MOVE_PIXELS,spriteX
	add.l	#5*PLAYER_SPRITE_VERTICAL_BYTES,d0 
	move.l	d0,currentSprite				
.skipLeft
	cmp.w	#0,spriteL
	beq	.notLeft
	sub.w	#1,spriteL
	cmp.w   #PLAYER_PAUSE_PIXELS,spriteL
	bge	.notLeft
	add.l	#4*PLAYER_SPRITE_VERTICAL_BYTES,d0 
	move.l	d0,currentSprite					
.notLeft:
	cmp.w	#$cf,spriteX
	blt	.noScroll
	move.w	#1,moving
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
	
	cmp.b	#3,joystickpos
 	bne	.notRight
	move.w	#PLAYER_JUMP_PIXELS+PLAYER_PAUSE_PIXELS,spriteR
.notRight:
	cmp.b	#1,joystickpos
 	bne	.notUp
	move.w	#PLAYER_JUMP_PIXELS+PLAYER_PAUSE_PIXELS,spriteU
.notUp:
	cmp.b	#5,joystickpos
 	bne	.notDown
	move.w	#PLAYER_JUMP_PIXELS+PLAYER_PAUSE_PIXELS,spriteD
.notDown:
	cmp.b	#7,joystickpos
 	bne	.notLeft
	move.w	#PLAYER_JUMP_PIXELS+PLAYER_PAUSE_PIXELS,spriteL
.notLeft:	
.skip:
	rts


SetupSpriteData:
	move.l	currentSprite,a0
	move.w	spriteLagX,d0
	move.w	spriteX,spriteLagX
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
	
	move.l	#ITEM_NUM_SLOTS-1,d0
.loop:
	jsr 	SetupItemSpriteData
	dbra	d0,.loop
	
	move.l	#deadSprite,SPR1PTH(a6)
	move.l	#deadSprite,SPR3PTH(a6)
	move.l	#deadSprite,SPR4PTH(a6)
	move.l	#deadSprite,SPR5PTH(a6)
	move.l	#deadSprite,SPR6PTH(a6)
	move.l	#deadSprite,SPR7PTH(a6)		
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

CheckPlayerMiss:

	cmp.w	#PLAYER_CHECK_MISS_PIXELS,spriteR
	beq	.check
	cmp.w	#PLAYER_CHECK_MISS_PIXELS,spriteU
	beq	.check	
	cmp.w	#PLAYER_CHECK_MISS_PIXELS,spriteD
	beq	.check	
	cmp.w	#PLAYER_CHECK_MISS_PIXELS,spriteL
	beq	.check	
	rts

.check:
	lea	pathwayMap,a2
	lea	map,a3

	;; calculate the a2 offset of the top right tile based on foreground scroll
	move.l	foregroundScrollX,d0		
	lsr.l   #FOREGROUND_SCROLL_TILE_INDEX_CONVERT,d0
	lsr.l	#1,d0
	and.b   #$f0,d0
	add.l	d0,a2
	add.l	d0,a3	


	;; add the offset based on the sprite's x position
	move.w	spriteLagX,d0
	cmpi.w  #PLAYER_LEFT_X,d0
	blt	.doBigBang
	sub.w	#PLAYER_LEFT_X,d0
	lsr.w	#4,d0      	; x columns
	move.w	d0,pathwayXIndex
	
	move.l	#(FOREGROUND_PLAYAREA_WIDTH_WORDS/2)-1,d1
	sub.w	d0,d1
	mulu.w  #FOREGROUND_PLAYAREA_HEIGHT_WORDS*2,d1
	sub.l	d1,a2		; player x if y == bottom ?
	sub.l	d1,a3		; player x if y == bottom ?	


	;; add the offset based on the sprite's y postion
	move.w	#PLAYER_BOTTOM_Y,d0
	sub.w	spriteY,d0
	lsr.w	#4,d0      	; y columns
	move.w	d0,pathwayYIndex
	sub.l	d1,d1
	move.w	#FOREGROUND_PLAYAREA_HEIGHT_WORDS-1,d1
	sub.w	d0,d1
	lsl.w	#1,d1
	add.l	d1,a2
	add.l	d1,a3	

	;; a2 now points at the tile under the sprite
	move.w	(a2),d0
	cmp.w	#$78e,d0
	bge	.noBigBang

	move.w	(a3),d0	
	cmp.w	#$78e,d0
	bge	.noBigBang

.doBigBang:
	jmp	BigBang

.noBigBang:
	move.w	(a3),d0	
	cmp.w	#$1e00,d0
	blt	.dontRenderPathway		
	move.w	#2,pathwayRenderPending
.dontRenderPathway:	
	rts

SelectNextPlayerSprite:
	cmp.l	#pigPlayerSpriteConfig,playerSpriteConfig
	bne	.s1
	move.l	#robotPlayerSpriteConfig,playerSpriteConfig
	bra	.done
.s1:
	move.l	#pigPlayerSpriteConfig,playerSpriteConfig
.done:
	bsr	InstallPlayerColorPalette	
	rts
	
pigPlayerSpriteConfig:
	dc.l	InstallPigColorPalette
	dc.l	spritePig
	dc.l	spriteFalling1

robotPlayerSpriteConfig:
	dc.l	InstallRobotColorPalette
	dc.l	spriteRobot
	dc.l	spriteFallingRobot1

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
	