	include "includes.i"
	
	xdef UpdatePig
	xdef ProcessJoystick
	xdef InitialisePig
	xdef SetupSpriteData
	xdef spriteX

InitialisePig:
	move.w	#$c0,spriteX
	rts
	
UpdatePig:	
	;; right
	cmp.w	#PIG_PAUSE_PIXELS,spriteR
	ble	.skipRight
	add.w	#PIG_MOVE_PIXELS,spriteX
.skipRight
	cmp.w	#0,spriteR
	beq	.notRight
	sub.w	#1,spriteR
.notRight:
	;; up
	cmp.w	#PIG_PAUSE_PIXELS,spriteU
	ble	.skipUp
	sub.w	#PIG_MOVE_PIXELS,spriteY
	sub.w	#PIG_MOVE_PIXELS,spriteYEnd	
.skipUp:
	cmp.w	#0,spriteU
	beq	.notUp
	sub.w	#1,spriteU
.notUp:
	;; down
	cmp.w	#PIG_PAUSE_PIXELS,spriteD
	ble	.skipDown
	add.w	#PIG_MOVE_PIXELS,spriteY
	add.w	#PIG_MOVE_PIXELS,spriteYEnd	
.skipDown:
	cmp.w	#0,spriteD
	beq	.notDown
	sub.w	#1,spriteD
.notDown:
	;; left

	cmp.w	#PIG_PAUSE_PIXELS,spriteL
	ble	.skipLeft
	sub.w	#PIG_MOVE_PIXELS,spriteX
.skipLeft
	cmp.w	#0,spriteL
	beq	.notLeft
	sub.w	#1,spriteL
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
	move.w	#PIG_JUMP_PIXELS+PIG_PAUSE_PIXELS,spriteR
	move.l	#spritePigRight,currentSprite			
.notRight:
	cmp.b	#1,joystickpos
 	bne	.notUp
	move.w	#PIG_JUMP_PIXELS+PIG_PAUSE_PIXELS,spriteU
	move.l	#spritePigUp,currentSprite		
.notUp:
	cmp.b	#5,joystickpos
 	bne	.notDown
	move.w	#PIG_JUMP_PIXELS+PIG_PAUSE_PIXELS,spriteD
	move.l	#spritePigDown,currentSprite	
.notDown:
	cmp.b	#7,joystickpos
 	bne	.notLeft
	move.w	#PIG_JUMP_PIXELS+PIG_PAUSE_PIXELS,spriteL
	move.l	#spritePigLeft,currentSprite
.notLeft:	
.skip:
	rts


SetupSpriteData:
	move.l	currentSprite,a0
	move.w	spriteLagX,d0
	move.w	spriteX,spriteLagX
	move.w	d0,d1
	andi	#1,d1
	move.b	d1,3(a0)	;spriteControl
	lsr.l	#1,d0
	move.b	d0,1(a0)	;spriteHStart
	move.w	spriteY,d0
	move.b	d0,(a0)		;spriteVStart
	move.w	spriteYEnd,d0
	move.b	d0,2(a0)	;spriteVStop
	move.l	a0,SPR0PTH(a6)

	move.l	#deadSprite,SPR1PTH(a6)
	move.l	#deadSprite,SPR2PTH(a6)
	move.l	#deadSprite,SPR3PTH(a6)
	move.l	#deadSprite,SPR4PTH(a6)
	move.l	#deadSprite,SPR5PTH(a6)
	move.l	#deadSprite,SPR6PTH(a6)
	move.l	#deadSprite,SPR7PTH(a6)		
	rts
	
	
spritePigUp:
	dc.w	0,0
	dc.w	0,0
	incbin	"out/sprite_pig_up.bin"
	dc.l	0
spritePigDown:
	dc.w	0,0
	dc.w	0,0
	incbin	"out/sprite_pig_down.bin"
	dc.l	0
spritePigLeft:
	dc.w	0,0
	dc.w	0,0
	incbin	"out/sprite_pig_left.bin"
	dc.l	0
spritePigRight:
	dc.w	0,0
	dc.w	0,0
	incbin	"out/sprite_pig_right.bin"
	dc.l	0	

currentSprite:
	dc.l	spritePigRight
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