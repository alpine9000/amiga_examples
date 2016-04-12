	include "includes.i"

	xdef HoriScrollPlayfield
	
HoriScrollPlayfield:
	;; d0 - fg x position in pixels
	;; d1 - bg x position in pixels	
	;; out:
	;; d0 - fg bitplane pointer increment in bytes
	;; d1 - bg bitplane pointer increment in bytes	
	movem.l	d2-a6,-(sp)

	move.l	d0,d3
	move.l	d1,d0
	
	move.l	d1,d2
	lsr.l   #3,d0		; bytes to scroll
	move.l  d0,d4		; save bitplane pointer increment (bytes) for return value
	and.l   #$F,d2		; pixels = 0xf - (hpos - (hpos_bytes*8))
	move.l  #$F,d0
	sub.l   d2,d0		; bits to delay	
	move.l	d0,d5		; d5 == bg bits to delay

	move.l	d3,d0
	move.l	d0,d2
	lsr.l   #3,d0		; bytes to scroll
	move.l  d0,d3		; save bitplane pointer increment (bytes) for return value
	and.l   #$F,d2		; pixels = 0xf - (hpos - (hpos_bytes*8))
	move.l  #$F,d0
	sub.l   d2,d0		; bits to delay

	lsl.w	#4,d5
	or.w	d5,d0	

	move.w  d0,BPLCON1(a6)	
	
	move.l	d3,d0		; restore d0 for return value
	move.l	d4,d1		; restore d1 for return value
	movem.l (sp)+,d2-a6
	rts

	