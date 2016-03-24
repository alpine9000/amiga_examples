	include "includes.i"

	xdef 	LoadNextImage	
	xdef 	SetupImage
	
LoadNextImage:
	movem.l	d0-a6,-(sp)
	lea	imageLookupTable,a1	
	add.l	imageIndex,a1
	cmp.l	#0,(a1)		; lookup table is terminated with 0
	bne	.showImage
	move.l	#0,imageIndex
	lea	imageLookupTable,a1	
.showImage
	move.l	a1,a3
	move.l	(a1),a2		; address of InsallColorPalette(X)
	move.l	4(a3),a1	; address of compressed image on disk
	move.l	8(a3),d0	; size of compressed image
	jsr	LoadImage
	add.l	#12,imageIndex  ; 3 words of data in LUT per image
	movem.l (sp)+,d0-a6
	rts
	
LoadImage:
	;; d0 - size
	;; a1 - start address
	;; a2 - InstallColorPalette(X) address

	lea	bitplanes3,a0
	bsr	LoadDiskData		; load data from disk

	move.l	nextbitplane,a1		; decompress into offscreen bitplanesp(1/2)
	
	;; a0 = Input buffer to be decompressed. Must be 16-bit aligned!
	;; a1 = Output buffer. Points to the end of the data at exit
	jsr	Depack

	jsr 	WaitVerticalBlank	; avoid tearing when we show the new image
	jsr	(a2)			; install new color palette
	bsr	SetupImage		; display new image

	;; toggle offscreen bitplane
	cmp.l	#bitplanes1,nextbitplane
	beq	.setbitplanes2
.setbitplanes1:
	move.l	#bitplanes1,nextbitplane
	bra	.done
.setbitplanes2:
	move.l	#bitplanes2,nextbitplane	
.done:
	rts
	

SetupImage:
	;; a1 - bitplanes address
	movem.l	d0-a6,-(sp)
	if INTERLACE==1
	;; poke the bitplane pointers for the two copper lists.
	move.l	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH,d0
	lea 	copperListAlternate,a0
	jsr	PokeBitplanePointers
	endif
	
	moveq.l	#0,d0
	lea 	copperList,a0
	jsr	PokeBitplanePointers
	movem.l (sp)+,d0-a6
	rts


imageIndex:
	dc.l	0
nextbitplane:
	dc.l	bitplanes1	
	
