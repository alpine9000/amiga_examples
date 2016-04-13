	include "includes.i"

	xdef HoriScrollPlayfield
	
HoriScrollPlayfield:
	;; d0 - fg x position in pixels
	;; d1 - bg x position in pixels	
	;; 	movem.l	d0-d6,-(sp)
	
	move.w	d0,d3
	move.w	d1,d0
	
	move.w	d1,d2
	lsr.w   #3,d0		; bytes to scroll
	and.w   #$F,d2		; pixels = 0xf - (hpos - (hpos_bytes*8))
	move.w  #$F,d0
	sub.w   d2,d0		; bits to delay	
	move.w	d0,d5		; d5 == bg bits to delay

	move.w	d3,d0
	move.w	d0,d2
	lsr.w   #3,d0		; bytes to scroll
	and.w   #$F,d2		; pixels = 0xf - (hpos - (hpos_bytes*8))
	move.w  #$F,d0
	sub.w   d2,d0		; bits to delay

	lsl.w	#4,d5
	or.w	d5,d0	

	move.w  d0,BPLCON1(a6)	
	
	;; movem.l (sp)+,d0-d6
	rts

	