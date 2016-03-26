	include "includes.i"
	
	xdef 	PokeBitplanePointers
	xdef	copperList
	xdef 	copperListAlternate
	xdef 	bitplanes1
	xdef 	bitplanes2
	xdef 	bitplanes3
	xdef	Module
	xdef	copperListBplPtr
	xdef	copperListAlternateBplPtr
	
byteMap:
	dc.l	Entry
	dc.l	endCode-byteMap

Entry:
	lea	userstack,a7
	lea 	CUSTOM,a6

	move	#$7ff,DMACON(a6)	; disable all dma
	move	#$7fff,INTENA(a6) 	; disable all interrupts		
	
	jsr	InstallPalette

	lea	Level3InterruptHandler,a3
 	move.l	a3,LVL3_INT_VECTOR			
	
	move.w	#(INTF_SETCLR|INTF_VERTB|INTF_INTEN),INTENA(a6)	

	lea	bitplanes1,a0
	move.l	#4,d0		;color
	jsr	CpuFillColor


	jsr	DisplayBitplane	; select it	

	if 0
	lea	bitplanes2,a0
	move.l	#3,d0		;color
	jsr	CpuFillColor
	endif

	
	jsr	Init		; enable the playfield
	
.mainLoop:
	jsr 	WaitVerticalBlank
	jsr 	WaitVerticalBlank
	jsr 	WaitVerticalBlank
	jsr 	WaitVerticalBlank
	jsr 	WaitVerticalBlank	

	;; blitobject64
	;; d0 - xpos
	;; d1 - ypos
	;; a0 - display
	;; a1 - object
	;; a2 - mask

	;; add.l	#1,xpos
	move.l  #4,xpos
	move.l	xpos,d0
	move.l	#50,d1
	lea	bitplanes1,a0
	if 1
	sub.l	#2,a0
	endif
	lea	font,a1
	lea	fontMask,a2
	jsr	blitObject64

	bra	.mainLoop

xpos:
	dc.l	0
Level3InterruptHandler:
	movem.l	d0-a6,-(sp)
	lea	CUSTOM,a6
.checkVerticalBlank:
	move.w	INTREQR(a6),d0
	and.w	#INTF_VERTB,d0	
	beq.s	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a6)	; clear interrupt bit	
	
.checkCopper:
	move.w	INTREQR(a6),d0
	and.w	#INTF_COPER,d0	
	beq.s	.interruptComplete
.copperInterrupt:
	move.w	#INTF_COPER,INTREQ(a6)	; clear interrupt bit	
	
.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte	

	
copperList:
copperListBplPtr:
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
	dc.w	$106,$c00	;AGA sprites, palette and dual playfield reset
	dc.w	$1FC,0		;AGA sprites and burst reset
	dc.l	$fffffffe
	dc.l	$fffffffe			

InstallPalette:
	include	"out/font-palette.s"
	rts

font:
	incbin	"out/font.bin"
fontMask:
	incbin	"out/font-mask.bin"	

	section .bss	
bitplanes1:
	ds.b	IMAGESIZE+(512)
bitplanes2:
	ds.b	IMAGESIZE+(512*2)
bitplanes3:
	ds.b	IMAGESIZE+(512*3)
startUserstack:
	ds.b	$1000		; size of stack
userstack:


