	include "includes.i"

	xref LoadNextImage
	
LoadNextImage:
	movem.l	d0-a6,-(sp)
	lea	imageLookupTable,a1	
	add.l	imageIndex,a1
	cmp.l	#0,(a1)		; lookup table is terminated with 0
	bne	.showImage
	move.l	#0,imageIndex
	lea	imageLookupTable,a1	
.showImage
	move.l	a1,a2
	move.l	(a1),a1		; address of InsallColorPalette(X)
	move.l	4(a2),a2	; address of LoadImage(X)
	jsr	(a2)
	add.l	#8,imageIndex
	movem.l (sp)+,d0-a6
	rts
	
LoadImage1:
	;; a1 - start address
	lea	InstallColorPalette,a0
	move.l	imageSize,d0
	bsr	DoLoadImage
	jsr	InstallColorPalette
	lea	bitplanes,a1
	bsr	SetupImage
	rts
	
LoadImage2:
	;; a1 - start address
	lea	InstallColorPalette2,a0
	move.l	imageSize,d0
	bsr	DoLoadImage
	jsr	InstallColorPalette2
	lea	bitplanes2,a1
	bsr	SetupImage
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

DoLoadImage:
	;; a0 - destination address
	;; a1 - start address
	;; d0 - size
	movem.l	d0-a6,-(sp)
	lea 	$dff002,a6			;Loader uses this custom base addr

	move.l	d0,d1
	
	move.l	a1,d0
	move.l	#startCode,d2
	sub.l	d2,d0		; offset from start of this module
	lsr.l	#6,d0		; bytes -> sectors
	lsr.l	#3,d0		
	add.l	#2,d0		; offset for bootblock

	
	add.l	#512,d1
	lsr.l	#6,d1		; bytes -> sectors
	lsr.l	#3,d1
	neg.w	d1
	jsr 	LoadMFMB	
	
	movem.l (sp)+,d0-a6
	rts

imageLookupTable:
	dc.l	InstallColorPalette
	dc.l	LoadImage2
	dc.l	InstallColorPalette2
	dc.l	LoadImage1
	dc.l	InstallColorPalette3
	dc.l	LoadImage2	
	dc.l	InstallColorPalette4
	dc.l	LoadImage1	
	dc.l	InstallColorPalette5
	dc.l	LoadImage2	
	dc.l	InstallColorPalette6
	dc.l	LoadImage1	
	dc.l	0

imageIndex:
	dc.l	0
	