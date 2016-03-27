	include "includes.i"

	xdef BlitFillColor

BLIT_LF_MINTERM		equ $ff

BlitFillColor:
	;; kills a0,d2,d3,d5,d5
	;; a0 - bitplane
	;; d0 - color#
	;; d1 - height
	;; d2 - ypos

	;; 	movem.l	d0-d5/a0,-(sp)
	;; 	movem.l	a0,-(sp)
	mulu.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH,d2
	add.l	d2,a0
	move.b	#0,d3				; bitplane #
.loop:
	move.w	d1,d4		
	btst	d3,d0				; is the color's bit set in this plane?
	beq	.zero
	move.w	#BLIT_DEST|$FF,d5		; yes ? all ones
	bra	.doblit
.zero
	move.w	#BLIT_DEST|$0,d5			; no ? all zeros
.doblit
	jsr	WaitBlitter

	move.w	#0,BLTCON1(A6)
	move.w  d5,BLTCON0(A6)
	move.w 	#SCREEN_WIDTH_BYTES*(SCREEN_BIT_DEPTH-1),BLTDMOD(a6)
	move.l 	a0,BLTDPTH(a6) 

	lsl.w	#6,d4	
	ori.w	#SCREEN_WIDTH_WORDS,d4
        move.w	d4,BLTSIZE(a6)
	add.b	#1,d3
	add.w	#SCREEN_WIDTH_BYTES,a0
	cmp.b	#SCREEN_BIT_DEPTH,d3 		; all planes for a single line done ?	
	bne	.loop				; no ? do the next plane
	;; 	jsr	WaitBlitter	
	;; movem.l (sp)+,d0-d5/a0
	;; movem.l	(sp)+,a0
	rts
