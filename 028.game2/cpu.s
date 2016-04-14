	include	"includes.i"

	xdef CpuFillColor

CpuFillColor:
	;; d0 - color index
	;; a0 - bitplane pointer
	movem.l	d1-d4/a0,-(sp)
	move.w	#(SCREEN_HEIGHT)-1,d2
.fillLine
	move.b	#0,d1				; bitplane #
.fillBitplane:
	move.w	#(SCREEN_WIDTH_BYTES/4)-1,d3 	; long word moves, so / 4
	btst	d1,d0				; is the color's bit set in this plane?
	beq	.zero
	move.l	#$FFFFFFFF,d4			; yes ? all ones
	bra	.loop
.zero
	move.l	#0,d4				; no ? all zeros	
.loop:
	move.l	d4,(a0)+			; write the data to the plane's line 
	dbra	d3,.loop
	add.b	#1,d1
	cmp.b	#SCREEN_BIT_DEPTH,d1 		; all planes for a single line done ?
	bne	.fillBitplane			; no ? do the next plane
	dbra	d2,.fillLine			; yes ? do the next line
	movem.l	(sp)+,d1-d4/a0
	rts