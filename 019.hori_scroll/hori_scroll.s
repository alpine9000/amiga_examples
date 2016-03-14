	include "../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
	include "constants.i"

entry:
	lea 	CUSTOM,a6	
	bsr	init


.mainLoop:
	bsr 	waitVerticalBlank
	;; 	bsr	scrollPlayfield
	bsr 	horiScrollPlayfield
	bra	.mainLoop


setupBitScroll:
	;; d0 = number of bits to scroll
	movem.l	d0/d1,-(sp)
	lsl.w	#4,d0
	move.w	hpos,d1
	or.w	d1,d0
	move.w  d0,BPLCON1(a6)
	movem.l (sp)+,d0/d1
	rts
	
horiScrollPlayfield:
	movem.l	d0-a6,-(sp)
	move.l	#0,d0
	lea 	copper(pc),a0
	bsr	pokeBitplanePointers
	add.w	#1,hpos
	cmp.w	#7,hpos
	ble	.ok
	move.w	#0,hpos
.ok
	move.w	hpos,d0
	bsr	setupBitScroll
.done:
	movem.l (sp)+,d0-a6
	rts
	
	
scrollPlayfield:
	movem.l	d0-a6,-(sp)
	move.l	vpos,d0
	lea 	copper(pc),a0
	bsr	pokeBitplanePointers
	cmp.l	#1,directionUp
	beq	.up
	add.l	#SCROLL_SPEED*SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH,vpos
	cmp.l	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH*256,vpos
	bge	.switchToUp
	bra	.done
.switchToUp:
	move.l	#1,directionUp
	move.l	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH*256,vpos
	bra	.done
.up:
	sub.l	#SCROLL_SPEED*SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH,vpos
	cmp.l	#0,vpos
	ble	.switchToDown
	bra	.done
.switchToDown:
	move.l	#0,directionUp
	move.l	#0,vpos
	bra	.done
.done:
	movem.l (sp)+,d0-a6
	rts
	
	include "init.s"
	include "utils.s"
	
pokeBitplanePointers:
	;; d0 = scroll offset
	;; a0 = BPLP copper list address
	movem.l	d0-a6,-(sp)
	lea	bitplanes(pc),a1
	add.l	d0, a1
	moveq	#SCREEN_BIT_DEPTH-1,d0
.bitplaneloop:
	move.l 	a1,d1
	move.w	d1,2(a0)
	swap	d1
	move.w  d1,6(a0)
	lea	SCREEN_WIDTH_BYTES(a1),a1
	addq	#8,a0
	dbra	d0,.bitplaneloop
	movem.l (sp)+,d0-a6
	rts

	
installColorPalette:
	include "out/image-palette.s"
	rts

vpos:
	dc.l	0
hpos:
	dc.w	7
directionUp:
	dc.l	0
	
copper:
	;; bitplane pointers must be first else poking addresses will be incorrect
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
	dc.l	$fffffffe

bitplanes:
	incbin	"out/image.bin"