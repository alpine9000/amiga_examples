	include "includes.i"

	xdef HoriScrollPlayfield
	
HoriScrollPlayfield:
	;; d0 - x position in pixels
	;; out:
	;; d0 - bitplane pointer increment in bytes
	movem.l	d1-a6,-(sp)
	move.l	d0,d1
	lsr.l   #3,d0		; bytes to scroll
	move.l  d0,d3		; save bitplane pointer increment (bytes) for return value
	and.l   #$F,d1		; pixels = 0xf - (hpos - (hpos_bytes*8))
	move.l  #$F,d0
	sub.l   d1,d0		; bits to delay	
	bsr	SetupHoriScrollBitDelay
	move.l	d3,d0		; retstore d0 for return value
	movem.l (sp)+,d1-a6
	rts

SetupHoriScrollBitDelay:
	;; d0 = number of bits to scroll
	movem.l	d0/d1,-(sp)
	move.w	d0,d1
	lsl.w	#4,d1
	or.w	d1,d0
	move.w  d0,BPLCON1(a6)
	movem.l (sp)+,d0/d1
	rts
	