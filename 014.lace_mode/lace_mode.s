	include "../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
	include "constants.i"
	
entry:
	lea 	CUSTOM,a6	
	bsr	init
	
.mainLoop:
	bsr 	waitVerticalBlank

	if INTERLACE == 1
	btst.w	#VPOSRLOFBIT,VPOSR(a6)
	beq.s	.lof
	lea	copper(pc),a0
	move.l	a0,COP1LC(a6)
	bra	.done
.lof:
	lea	copperLOF(pc),a0
	move.l	a0,COP1LC(a6)
.done
	endif
	bra	.mainLoop
	
	include "init.s"
	include "utils.s"

	
pokeBitplanePointers: 		; d0 = frame offset in bytes, a0 = BPLP copper list address
	movem.l	d0-a6,-(sp)
	lea	bitplanes(pc),a1
	add.l	d0,a1 ; Offset for odd/even frames
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

copperLOF:
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