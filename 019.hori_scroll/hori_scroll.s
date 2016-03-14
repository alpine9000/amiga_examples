	include "../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
	include "constants.i"

Entry:
	lea 	CUSTOM,a6	
	bsr	Init


.mainLoop:
	bsr 	WaitVerticalBlank

	move.l	#0,bitplaneAddress
	bsr 	HoriScrollPlayfield
	bsr	VertScrollPlayfield
	lea 	copper(pc),a0
	move.l	bitplaneAddress,d0
	bsr	PokeBitplanePointers

	bsr	UpdateHoriScrollPos
	bsr	UpdateVertScrollPos
	bra	.mainLoop


SetupHoriScrollBitDelay:
	;; d0 = number of bits to scroll
	movem.l	d0/d1,-(sp)
	move.w	d0,d1
	lsl.w	#4,d1
	or.w	d1,d0
	move.w  d0,BPLCON1(a6)
	movem.l (sp)+,d0/d1
	rts


HoriScrollPlayfield:
	movem.l	d0-a6,-(sp)
	move.l	hpos,d0
	lsr.l	#3,d0		;bytes to scroll
	add.l	d0,bitplaneAddress
	move.l	hpos,d1
	and.l	#$F,d1
	move.l	#$F,d0
	sub.l	d1,d0		;bits to delay
	bsr	SetupHoriScrollBitDelay
.done:
	movem.l (sp)+,d0-a6
	rts


UpdateHoriScrollPos:
	movem.l	d0-a6,-(sp)
	cmp.l	#1,directionLeft
	beq	.left
	add.l	#1,hpos
	cmp.l	#SCREEN_WIDTH,hpos
	bge	.switchToLeft
	bra	.done
.switchToLeft:
	move.l	#1,directionLeft
	move.l	#SCREEN_WIDTH-1,hpos
	bra	.done
.left:
	sub.l	#1,hpos
	cmp.l	#0,hpos
	ble	.switchToRight
	bra	.done
.switchToRight:
	move.l	#0,directionLeft
	move.l	#0,hpos
	bra	.done
.done:
	movem.l (sp)+,d0-a6
	rts


UpdateVertScrollPos:
	movem.l	d0-a6,-(sp)
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


VertScrollPlayfield:
	movem.l	d0-a6,-(sp)
	move.l	vpos,d0
	add.l	d0,bitplaneAddress
	movem.l (sp)+,d0-a6
	rts
	

PokeBitplanePointers:
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
	
InstallColorPalette:
	include "out/image-palette.s"
	rts

	include "init.s"
	include "utils.s"

bitplaneAddress:
	dc.l	0
vpos:
	dc.l	0
hpos:
	dc.l	0
directionUp:
	dc.l	0
directionLeft:
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