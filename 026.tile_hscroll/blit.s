	include "includes.i"

	xdef BlitFillColor
	xdef BlitScroll
	xdef BlitTile
	
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
	move.w	#BC0F_DEST|$FF,d5		; yes ? all ones
	bra	.doblit
.zero
	move.w	#BC0F_DEST|$0,d5		; no ? all zeros
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
	;; left scroll a screen wide region
	;; a0 - dest bitplane pointer
	;; a1 - source bitplane pointer
	;; d0 - number of pixels to left shift on blit
	;; d1 - height in pixels
	;; d2 - y destination in pixels

	movem.l	d0-d2/a0-a1,-(sp)
	add.l	d1,d2			; point to end of data for descending mode
	mulu.w	#BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH,d2
	add.l	d2,a0			; end of dest bitplane
	add.l	d2,a1			; end of source bitplane

	WaitBlitter

	swap	d0			; lsl.l #ASHIFTSHIFT,d0
	lsr.l   #4,d0			; d0 has ASHIFTSHIFT bits set
	ori.w	#BC1F_DESC,d0		; BLTCON1 value. shift and descending mode
	move.w	d0,BLTCON1(a6)		;
	and.w	#$f000,d0		; keep the shift, remove the rest
	ori.w	#BC0F_SRCB|BC0F_SRCC|BC0F_DEST|$ca,d0 ; BLTCON0 value. shift, dma and logic function
	move.w	d0,BLTCON0(a6)
	
	move.w 	#0,BLTBMOD(a6)		; no modulo, blitting full width data
	move.w 	#0,BLTCMOD(a6)		;
	move.w 	#0,BLTDMOD(a6)		;
	move.l 	a1,BLTBPTH(a6) 		; source
	move.l 	a1,BLTCPTH(a6) 		; background
	move.l 	a0,BLTDPTH(a6)		; dest
	move.w	#$0000,BLTAFWM(a6) 	; A DMA is disabled, but the channel is still used in the logic function
	move.w	#$ffff,BLTALWM(a6) 	; as we use it for masking
	move.w	#$ffff,BLTADAT(a6) 	; preload source mask so only BLTA?WM mask is used		
	
	mulu.w	#SCREEN_BIT_DEPTH,d1
	lsl.w	#6,d1	
	ori.w	#BITPLANE_WIDTH_WORDS,d1
        move.w	d1,BLTSIZE(a6)

	movem.l (sp)+,d0-d2/a0-a1
	rts



BlitTile:
	;; a0 - dest bitplane pointer
	;; a1 - source bitplane pointer
	;; d2 - y destination in pixels

	WaitBlitter

	move.w	#0,BLTCON1(a6)		;
	move.w	#BC0F_SRCA|BC0F_DEST|$f0,BLTCON0(a6)
	
	move.w 	#SCREEN_WIDTH_BYTES,BLTAMOD(a6)
	move.w 	#SCREEN_WIDTH_BYTES,BLTDMOD(a6)		;
	move.l 	a1,BLTAPTH(a6) 		; source
	move.l 	a0,BLTDPTH(a6)		; dest
	move.w	#$ffff,BLTAFWM(a6)
	move.w	#$ffff,BLTALWM(a6)
	move.w 	#((SCREEN_HEIGHT/2)*SCREEN_BIT_DEPTH)<<6|(1),BLTSIZE(a6)	;rectangle size, starts blit

	WaitBlitter

	add.l	#BITPLANE_WIDTH_BYTES*(SCREEN_HEIGHT/2)*SCREEN_BIT_DEPTH,a0
	add.l	#BITPLANE_WIDTH_BYTES*(SCREEN_HEIGHT/2)*SCREEN_BIT_DEPTH,a1
	move.l 	a1,BLTAPTH(a6) 		; source
	move.l 	a0,BLTDPTH(a6)		; dest
	move.w 	#((SCREEN_HEIGHT/2)*SCREEN_BIT_DEPTH)<<6|(1),BLTSIZE(a6)	;rectangle size, starts blit	
	rts
			