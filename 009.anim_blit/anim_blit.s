	include "../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
	include "constants.i"
	
entry:
	lea 	CUSTOM,a6
	bsr	init
	
	moveq	#0,d0 		; starting x position for the blitter object
	moveq 	#0,d1		; starting y position for the blitter object
	lea	bitplanes(pc),a0
	lea	emoji,a1
	lea	emojiMask,a2
.mainLoop:
	bsr.s	waitvbl
	addq	#1,d0		; move the blitter object one pixel to the left
	addq	#1,d1		; move the blitter object one pixel down
	bsr.s 	blitObject64	; blit 64 pixel object (x=d0,y=d1,background=a0,object=a1,mask=a2)
	cmp.l	#SCREEN_WIDTH-BLIT_BOB_WIDTH64+16,d0	; check if we need to wrap the x
	bne.s	.skip
	moveq	#0,d0					; wrap x back to zero
.skip:

	cmp.l	#SCREEN_HEIGHT-BLIT_BOB_HEIGHT64,d1	; check if we need to wrap the y
	bne.s	.skip2
	moveq	#0,d1					; wrap y back to the top
.skip2:		
	bra.s	.mainLoop

	include	"utils.s"
	include	"blit.s"
	include "init.s"
	
	
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