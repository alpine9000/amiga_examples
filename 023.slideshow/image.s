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
	move.l	12(a3),a3	; address of LoadImage(X)
	jsr	(a3)
	add.l	#16,imageIndex
	movem.l (sp)+,d0-a6
	rts

Callback:
	;; d0 = Number of bytes decompressed so far
	;; a0 = Callback argument
	move.l	a6,-(sp)
	lea 	CUSTOM,a6
	move.w  d0,COLOR00(a6)		;  Set wild background colors as we decompress
	move.l	(sp)+,a6
	rts	
	
LoadImage1:
	;; d0 - size
	;; a1 - start address
	;; a2 - InstallColorPalette(X) address
	if 0
	move.l	bitplanesp3,a0	; Load compressed data into bitplanes3
	endif

	move.l	bitplanesp1,a0	
	bsr	DoLoadImage

	if 0
	;; Decompress
	; a0 = compressed data
	; a1 = decompressed data destination
	move.l	bitplanesp1,a1
	; a2 = progress callback, can be zero if no callback is desired.
	lea	Callback(pc),a2
	bsr 	ShrinklerDecompress 	; -> decompress!
	endif
	
	jsr	(a2)
	move.l	bitplanesp1,a1
	bsr	SetupImage
	rts

LoadImage2:
	;; d0 - size
	;; a1 - start address
	;; a2 - InstallColorPalette(X) address
	if 0
	move.l	bitplanesp3,a0	; Load compressed data into bitplanes3
	endif

	move.l	bitplanesp2,a0
	bsr	DoLoadImage

	if 0
	;; Decompress
	; a0 = compressed data
	; a1 = decompressed data destination
	move.l	bitplanesp2,a1
	; a2 = progress callback, can be zero if no callback is desired.
	lea	Callback(pc),a2
	bsr 	ShrinklerDecompress 	; -> decompress!
	endif
	
	jsr	(a2)
	move.l	bitplanesp2,a1
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
	dc.l	imageData1
	dc.l	endImageData1-imageData1
	dc.l	LoadImage2
	
	dc.l	InstallColorPalette2
	dc.l	imageData2
	dc.l	endImageData2-imageData2
	dc.l	LoadImage1

	dc.l	InstallColorPalette3
	dc.l	imageData3
	dc.l	endImageData3-imageData3	
	dc.l	LoadImage2	

	dc.l	InstallColorPalette4
	dc.l	imageData4
	dc.l	endImageData4-imageData4		
	dc.l	LoadImage1	

	dc.l	InstallColorPalette5
	dc.l	imageData5
	dc.l	endImageData5-imageData5			
	dc.l	LoadImage2	

	dc.l	InstallColorPalette6
	dc.l	imageData6
	dc.l	endImageData6-imageData6				
	dc.l	LoadImage1	
	dc.l	0

imageIndex:
	dc.l	0


	include "../tools/external/shrinkler/ShrinklerDecompress.S"


	
	section .photo		

	cnop	0,512
imageData1:	
	if HAM_MODE==1
	incbin	"out/mr-ham.bin"
	else
	incbin	"out/mr.bin"
	endif
endImageData1:	
	
	cnop	0,512
imageData2:	
	if HAM_MODE==1
	incbin	"out/catwoman-ham.bin"
	else
	incbin	"out/catwoman.bin"
	endif
endImageData2:		

	cnop	0,512
imageData3:	
	if HAM_MODE==1
	incbin	"out/batgirl-ham.bin"
	else
	incbin	"out/batgirl.bin"
	endif
endImageData3:
	
	cnop	0,512
imageData4:	
	if HAM_MODE==1
	incbin	"out/kb-ham.bin"
	else
	incbin	"out/kb.bin"
	endif
endImageData4:	
	
	cnop	0,512
imageData5:	
	if HAM_MODE==1
	incbin	"out/fe-ham.bin"
	else
	incbin	"out/fe.bin"
	endif
endImageData5:	
	
	cnop	0,512
imageData6:	
	if HAM_MODE==1
	incbin	"out/ww-ham.bin"
	else
	incbin	"out/ww.bin"
	endif
endImageData6:			