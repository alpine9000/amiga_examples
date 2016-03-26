	include "includes.i"

	xdef DisplayBitplane
		
LoadImage:
	;; d0 - size
	;; a1 - start address
	;; a2 - InstallColorPalette(X) address

	lea	bitplanes3,a0
	bsr	LoadDiskData		; load data from disk

	;; move.l	nextbitplane,a1		; decompress into offscreen bitplanesp(1/2)
	
	;; a0 = Input buffer to be decompressed. Must be 16-bit aligned!
	;; a1 = Output buffer. Points to the end of the data at exit
	jsr	Depack

	jsr 	WaitVerticalBlank	; avoid tearing when we show the new image
	jsr	(a2)			; install new color palette
	jsr	DisplayBitplane		; display new image

	rts
	

DisplayBitplane:
	;; a0 - bitplane address
	movem.l	d0/a0-a1,-(sp)
	moveq.l	#0,d0
	move.l	a0,a1
	lea 	copperListBplPtr,a0
	jsr	PokeBitplanePointers
	movem.l (sp)+,d0/a0-a1
	rts

PokeBitplanePointers:
	; d0 = frame offset in bytes
	; a0 = BPLP copper list address
	; a1 = bitplanes pointer
	movem.l	d0-a6,-(sp)
	add.l	d0,a1 ; Offset for odd/even frames
	moveq	#SCREEN_BIT_DEPTH-1,d0
.bitplaneloop:
	move.l 	a1,d1
	move.w	d1,2(a0)
	swap	d1
	move.w  d1,6(a0)
	lea	SCREEN_WIDTH_BYTES(a1),a1
	addq	#8,a0
	dbra	d0,.bitplaneloop
	movem.l (sp)+,d0-a6
	rts

	
