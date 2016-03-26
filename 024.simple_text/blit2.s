	include "includes.i"

	xdef BlitFillColor

BLIT_LF_MINTERM		equ $ff
BLIT_DEST		equ $100
BLIT_SRCC	    	equ $200
BLIT_SRCB	    	equ $400
BLIT_SRCA	    	equ $800
	

BlitFillColor:
	;; d0 - color#
	;; d1 - height
	movem.l	d0-a6,-(sp)
	move.b	#0,d3				; bitplane #
.loop:
	move.w	d1,d4		
	btst	d3,d0				; is the color's bit set in this plane?
	beq	.zero
	move.l	#BLIT_DEST|$FF,d2		; yes ? all ones
	bra	.doblit
.zero
	move.l	#BLIT_DEST|$0,d2			; no ? all zeros
.doblit
	jsr	WaitBlitter

	move.w	#0,BLTCON1(A6)
	move.w  d2,BLTCON0(A6)
	move.w 	#SCREEN_WIDTH_BYTES*(SCREEN_BIT_DEPTH-1),BLTDMOD(a6)
	move.l 	a0,BLTDPTH(a6) 

	lsl.w	#6,d4	
	ori.w	#SCREEN_WIDTH_WORDS,d4
        move.w	d4,BLTSIZE(a6)
	add.b	#1,d3
	add.l	#SCREEN_WIDTH_BYTES,a0
	cmp.b	#SCREEN_BIT_DEPTH,d3 		; all planes for a single line done ?	
	bne	.loop				; no ? do the next plane
	jsr 	WaitBlitter
	movem.l (sp)+,d0-a6
	rts
