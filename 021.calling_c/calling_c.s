	include "includes.i"

	xref	InstallColorPalette
	;; xref	PokeBitplanePointers ;; We don't need the ASM version of this for this example
	xref	copperList
	xref 	copperListAlternate
	xref	bitplanes
	
Entry:
	lea 	CUSTOM,a6	
	jsr	Init
	
.mainLoop:
	jsr 	WaitVerticalBlank

	if INTERLACE==1
	btst	#VPOSRLOFBIT,VPOSR(a6)
	beq.s	.lof
	lea	copperListAlternate(pc),a0
	move.l	a0,COP1LC(a6)
	bra	.done
.lof:
	lea	copperList(pc),a0
	move.l	a0,COP1LC(a6)
.done
	endif; INTERLACE==1
	bra	.mainLoop

;===========================================================
; We don't need the ASM version of this for this example
	if 0
PokeBitplanePointers:
	; d0 = frame offset in bytes;
	; a0 = BPLP copper list address 
	movem.l	d0-a6,-(sp)
	lea	bitplanes,a1
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
	endif
;===========================================================	
	
InstallColorPalette:
	include "out/image-palette.s"
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

bitplanes:
	if HAM_MODE==1
	incbin	"out/image-ham.bin"
	else
	incbin	"out/image.bin"
	endif