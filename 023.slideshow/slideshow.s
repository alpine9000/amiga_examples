	include "includes.i"

	xref	InstallColorPalette
	xref 	PokeBitplanePointers
	xref	copperList
	xref 	copperListAlternate
	xref 	MFMbuf
	xref	level3InterruptHandler

IMAGESIZE	equ	endbitplanes-InstallColorPalette

byteMap:
	dc.l	Entry
	dc.l	endCode-byteMap

Entry:
	move.l	#userstack,a7
	lea 	CUSTOM,a6
	
	lea	InstallColorPalette,a1
	bsr	LoadImage1
	jsr	Init	
	
.mainLoop:
	jsr 	WaitVerticalBlank

	cmp.l	#0,doLoad
	beq	.updateCounter

.image1:
	cmp.l	#0,imageIndex
	bne	.image2
	lea	InstallColorPalette2,a1
	bsr	LoadImage2

.image2:
	cmp.l	#1,imageIndex
	bne	.image3
	lea	InstallColorPalette3,a1
	bsr	LoadImage1

.image3:
	cmp.l	#2,imageIndex
	bne	.image4
	lea	InstallColorPalette4,a1
	bsr	LoadImage2

.image4:
	cmp.l	#3,imageIndex
	bne	.image5
	lea	InstallColorPalette5,a1
	bsr	LoadImage1

.image5:
	cmp.l	#4,imageIndex
	bne	.image6	
	lea	InstallColorPalette6,a1
	bsr	LoadImage2

.image6:
	cmp.l	#5,imageIndex
	bne	.image7	
	lea	InstallColorPalette,a1
	bsr	LoadImage1
	move.l	#0,imageIndex
	bra	.updateCounter

.image7:
.incr
	add.l	#1,imageIndex

.updateCounter:
	move.l	#0,doLoad
	cmp.l	#50*5,counter
	beq	.display
	add.l	#1,counter
	bra	.done

.display:
	move.l	#0,counter
	move.l	#1,doLoad	
.done
	bra	.mainLoop

doLoad:
	dc.l	0
counter:
	dc.l	0
imageIndex:
	dc.l	0

level3InterruptHandler:
	movem.l	d0-a6,-(sp)
	lea	CUSTOM,a6
.checkVerticalBlank:
	move.w	INTREQR(a6),d0
	and.w	#INTF_VERTB,d0	
	beq.s	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a6)	; clear interrupt bit	
	if INTERLACE==1
	btst	#VPOSRLOFBIT,VPOSR(a6)
	beq.s	.lof
	lea	copperListAlternate,a0
	move.l	a0,COP1LC(a6)
	bra	.done
.lof:
	lea	copperList,a0
	 move.l	a0,COP1LC(a6)
.done
	endif ; INTERLACE==1
.checkCopper:
	move.w	INTREQR(a6),d0
	and.w	#INTF_COPER,d0	
	beq.s	.interruptComplete
.copperInterrupt:
	move.w	#INTF_COPER,INTREQ(a6)	; clear interrupt bit	
	
.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte	
	
LoadImage1:
	;; a1 - start address
	lea	InstallColorPalette,a0
	move.l	#IMAGESIZE,d0
	bsr	DoLoadImage
	jsr	InstallColorPalette
	lea	bitplanes,a1
	bsr	SetupImage
	rts
	
LoadImage2:
	;; a1 - start address
	lea	InstallColorPalette2,a0
	move.l	#IMAGESIZE,d0
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

	if INTERLACE==1
copperListAlternate:
	;; bitplane pointers must be first else poking addresses will be incorrect
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0
	dc.l	$fffffffe
	endif; INTERLACE==1
	
copperList:
	;; bitplane pointers must be first else poking addresses will be incorrect
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0
	dc.l	$fffffffe		

	section .photo		
InstallColorPalette:
	include "out/mr-palette.s"
	rts
bitplanes:
	if HAM_MODE==1
	incbin	"out/mr-ham.bin"
	else
	incbin	"out/mr.bin"
	endif
endbitplanes:


	cnop	0,512
InstallColorPalette2:
	include "out/catwoman-palette.s"
	rts
bitplanes2:	
	if HAM_MODE==1
	incbin	"out/catwoman-ham.bin"
	else
	incbin	"out/catwoman.bin"
	endif
endbitplanes2:


	cnop	0,512	
InstallColorPalette3:
	include "out/batgirl-palette.s"
	rts
	if HAM_MODE==1
	incbin	"out/batgirl-ham.bin"
	else
	incbin	"out/batgirl.bin"
	endif
endbitplanes3:


	cnop	0,512
InstallColorPalette4:
	include "out/kb-palette.s"
	rts
	if HAM_MODE==1
	incbin	"out/kb-ham.bin"
	else
	incbin	"out/kb.bin"
	endif
endbitplanes4:

	cnop	0,512
InstallColorPalette5:
	include "out/fe-palette.s"
	rts
	if HAM_MODE==1
	incbin	"out/fe-ham.bin"
	else
	incbin	"out/fe.bin"
	endif
endbitplanes5:

	cnop	0,512
InstallColorPalette6:
	include "out/ww-palette.s"
	rts
	if HAM_MODE==1
	incbin	"out/ww-ham.bin"
	else
	incbin	"out/ww.bin"
	endif
endbitplanes6:		