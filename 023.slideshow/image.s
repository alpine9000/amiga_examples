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
	
	move.l	bitplanesp3,a0		; load compressed data into bitplanes3
	bsr	DoLoadImage		; load data from disk

	move.l	nextbitplane,a1		; decompress into offscreen bitplanesp(1/2)
	move.l	(a1),a1		
	movem.l	d0-a6,-(sp)	
	bsr	doynaxdepack		; decompress data
	movem.l (sp)+,d0-a6

	jsr 	WaitVerticalBlank	; avoid tearing when we show the new image
	jsr	(a2)			; install new color palette
	bsr	SetupImage		; display new image


	;; toggle offscreen bitplane
	cmp.l	#bitplanesp1,nextbitplane
	beq	.setbitplanesp2
.setbitplanesp1:
	move.l	#bitplanesp1,nextbitplane
	bra	.done
.setbitplanesp2:
	move.l	#bitplanesp2,nextbitplane	
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

DoLoadImage:
	;; a0 - destination address
	;; a1 - start address
	;; d0 - size
	movem.l	d0-a6,-(sp)
	lea 	$dff002,a6	; LoadMFMB uses this custom base addr

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
	jsr 	LoadMFMB	; load the data!
	
	movem.l (sp)+,d0-a6
	rts

imageLookupTable:				; configure slideshow here
	dc.l	InstallColorPalette 		; palette installation routine
	dc.l	imageData1			; compressed image data
	dc.l	endImageData1-imageData1	; compressed image data size
	
	dc.l	InstallColorPalette2
	dc.l	imageData2
	dc.l	endImageData2-imageData2

	dc.l	InstallColorPalette3
	dc.l	imageData3
	dc.l	endImageData3-imageData3	

	dc.l	InstallColorPalette4
	dc.l	imageData4
	dc.l	endImageData4-imageData4		

	dc.l	InstallColorPalette5
	dc.l	imageData5
	dc.l	endImageData5-imageData5			

	dc.l	InstallColorPalette6
	dc.l	imageData6
	dc.l	endImageData6-imageData6				
	
	dc.l	InstallColorPalette7
	dc.l	imageData7
	dc.l	endImageData7-imageData7

	if	INTERLACE==0
	dc.l	InstallColorPalette8
	dc.l	imageData8
	dc.l	endImageData8-imageData8
	endif; INTERLACE==0
	dc.l	0		; terminate list

imageIndex:
	dc.l	0
nextbitplane:
	dc.l	bitplanesp1
	
InstallColorPalette:
	include "out/mr-palette.s"
	rts	
InstallColorPalette2:
	include "out/mr2-palette.s"
	rts
InstallColorPalette3:
	include "out/mr3-palette.s"
	rts
InstallColorPalette4:
	include "out/mr4-palette.s"
	rts
InstallColorPalette5:
	include "out/mr5-palette.s"
	rts
InstallColorPalette6:
	include "out/mr6-palette.s"
	rts
InstallColorPalette7:
	include "out/mr7-palette.s"
	rts
InstallColorPalette8:
	include "out/mr8-palette.s"
	rts		

	;; this is one FAST decompression routine!
	include "../tools/external/doynamite68k/depacker_doynax.asm"
	
	section .photo		; data in this section will not be loaded by the bootloader
	cnop	0,512		; each image must be aligned to a sector boundary
imageData1:			; because I am too lazy to read non aligned data
	if HAM_MODE==1
	incbin	"out/mr-ham.lz"
	else
	incbin	"out/mr.lz"
	endif
endImageData1:	
	
	cnop	0,512		; each image must be aligned to a sector boundary
imageData2:			; because I am too lazy to read non aligned data
	if HAM_MODE==1
	incbin	"out/mr2-ham.lz"
	else
	incbin	"out/mr2.lz"
	endif
endImageData2:		

	cnop	0,512		; each image must be aligned to a sector boundary
imageData3:
	if HAM_MODE==1
	incbin	"out/mr3-ham.lz"
	else
	incbin	"out/mr3.lz"
	endif
endImageData3:
	
	cnop	0,512		; each image must be aligned to a sector boundary
imageData4:	
	if HAM_MODE==1
	incbin	"out/mr4-ham.lz"
	else
	incbin	"out/mr4.lz"
	endif
endImageData4:	
	
	cnop	0,512		; each image must be aligned to a sector boundary
imageData5:
	if HAM_MODE==1
	incbin	"out/mr5-ham.lz"
	else
	incbin	"out/mr5.lz"
	endif
endImageData5:	
	
	cnop	0,512		; each image must be aligned to a sector boundary
imageData6:	
	if HAM_MODE==1
	incbin	"out/mr6-ham.lz"
	else
	incbin	"out/mr6.lz"
	endif
endImageData6:

	cnop	0,512		; each image must be aligned to a sector boundary
imageData7:	
	if HAM_MODE==1
	incbin	"out/mr7-ham.lz"
	else
	incbin	"out/mr7.lz"
	endif
endImageData7:

	if INTERLACE==0
	cnop	0,512		; each image must be aligned to a sector boundary
imageData8:	
	if HAM_MODE==1
	incbin	"out/mr8-ham.lz"
	else
	incbin	"out/mr8.lz"
	endif
endImageData8:
	endif; INTERLACE==0