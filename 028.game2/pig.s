	include "includes.i"
	
	xdef UpdatePig

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