	include "../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
	include "constants.i"
	
entry:
	lea 	CUSTOM,a6
	bsr	init
	bsr.s	installColorPalette
	
.mainLoop:
	bsr 	waitVerticalBlank
	cmpi.w	#0,cycle
	bne.s	.alternate
	move.w	#1,cycle
	bsr.s	pokeBitplanePointers2
	bra	.done
.alternate:
	move.w	#0,cycle
	bsr.s	pokeBitplanePointers
.done
	bra	.mainLoop
	
	include "init.s"
	include "utils.s"

pokeBitplanePointers:	
	;; poke bitplane pointers
	movem.l	d0-a6,-(sp)
	lea	bitplanes(pc),a1
	lea     copper(pc),a2
	moveq	#SCREEN_BIT_DEPTH-1,d0
.bitplaneloop:
	move.l 	a1,d1
	move.w	d1,2(a2)
	swap	d1
	move.w  d1,6(a2)
	lea	SCREEN_WIDTH_BYTES(a1),a1 ; bit plane data is interleaved
	addq	#8,a2
	dbra	d0,.bitplaneloop
	movem.l (sp)+,d0-a6
	rts

pokeBitplanePointers2:
	;; poke bitplane pointers
	movem.l	d0-a6,-(sp)
	lea	bitplanes(pc),a1
	add.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH,a1
	lea     copper(pc),a2
	moveq	#SCREEN_BIT_DEPTH-1,d0
.bitplaneloop:
	move.l 	a1,d1
	move.w	d1,2(a2)
	swap	d1
	move.w  d1,6(a2)
	lea	SCREEN_WIDTH_BYTES(a1),a1 ; bit plane data is interleaved
	addq	#8,a2
	dbra	d0,.bitplaneloop
	movem.l (sp)+,d0-a6
	rts

	
	
installColorPalette:
	include "out/image-palette.s"
	rts

cycle:
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
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0

	dc.l	$fffffffe	

bitplanes:
	incbin	"out/image-ham.bin"