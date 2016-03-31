	include "includes.i"

	xdef BlitFillColor
	xdef BlitScroll

;;       A(mask) B(bob)  C(bg)   D(dest)
;;       -       -       -       - 
;;       0       0       0       0 
;;       0       0       1       1 
;;       0       1       0       0 
;;       0       1       1       1 
;;       1       0       0       0 
;;       1       0       1       0 
;;       1       1       0       1 
;;       1       1       1       1
	
BlitFillColor:
	;; kills a0,d2,d3,d5,d5
	;; a0 - bitplane
	;; d0 - color#
	;; d1 - height
	;; d2 - ypos

	;; 	movem.l	d2-d5/a0,-(sp)
	mulu.w	#BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH,d2
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
	WaitBlitter

	move.w	#0,BLTCON1(A6)
	move.w  d5,BLTCON0(A6)
	move.w 	#BITPLANE_WIDTH_BYTES*(SCREEN_BIT_DEPTH-1),BLTDMOD(a6)
	move.l 	a0,BLTDPTH(a6) 

	lsl.w	#6,d4	
	ori.w	#BITPLANE_WIDTH_WORDS,d4
        move.w	d4,BLTSIZE(a6)
	add.b	#1,d3
	add.w	#BITPLANE_WIDTH_BYTES,a0
	cmp.b	#SCREEN_BIT_DEPTH,d3 		; all planes for a single line done ?	
	bne	.loop				; no ? do the next plane

	;; movem.l (sp)+,d2-d5/a0
	rts



BlitScroll:
	;; kills a0,d1,d2
	;; a0 - bitplane
	;; d1 - height
	;; d2 - ypos

	;; 	movem.l	d2-d5/a0,-(sp)
	add.l	d1,d2	;point to end of data for ascending mode
	mulu.w	#BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH,d2
	add.l	d2,a0

	WaitBlitter

	move.w	#$2,BLTCON1(a6)
	move.w  #$1000|BLIT_SRCA|BLIT_DEST|$f0,BLTCON0(a6)
	move.w 	#-2,BLTAMOD(a6)
	move.w 	#-2,BLTDMOD(a6)
	move.l 	a0,BLTAPTH(a6) 	
	move.l 	a0,BLTDPTH(a6)
	move.w	#$0000,BLTAFWM(a6)
	move.w	#$ffff,BLTALWM(a6)	
	
	mulu.w	#SCREEN_BIT_DEPTH,d1
	lsl.w	#6,d1	
	ori.w	#BITPLANE_WIDTH_WORDS+1,d1
        move.w	d1,BLTSIZE(a6)

	;; movem.l (sp)+,d2-d5/a0
	rts
		