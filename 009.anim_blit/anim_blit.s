	include "../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
	include "constants.i"
	
entry:
	lea 	CUSTOM,a6
	bsr	init
	
	lea	bitplanes(pc),a0
	lea	emoji,a1
	lea	emojiMask,a2
.mainLoop:
	bra.s	.mainLoop

	include	"blit.s"
	include "init.s"

level3InterruptHandler:
	movem.l	d0-a6,-(sp)	
	move.w	#INTF_VERTB,INTREQ(a6)	; clear interrupt bit	

.moveBlitterObject:	
	lea	xpos(pc),a3
	lea	ypos(pc),a4
	add.l	#1,xpos		; move the blitter object one pixel to the left
	add.l	#1,ypos		; move the blitter object one pixel down
	bsr.s 	blitObject64	; blit 64 pixel object (x=d0,y=d1,background=a0,object=a1,mask=a2)
	cmp.l	#SCREEN_WIDTH-BLIT_BOB_WIDTH64+16,xpos	; check if we need to wrap the x
	bne.s	.skip
	move.l	#0,xpos					; wrap x back to 0
.skip:
	cmp.l	#SCREEN_HEIGHT-BLIT_BOB_HEIGHT64,ypos	; check if we need to wrap the y
	bne.s	.done
	move.l	#0,ypos					; wrap y back to 0
.done:

		
.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte

xpos:	dc.l	0
ypos:	dc.l	0
	
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

emoji:
	incbin	"out/emoji.bin"

emojiMask:	
	incbin	"out/emoji-mask.bin"