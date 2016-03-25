	include "includes.i"
	include "P6112-Options.i"
	
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
	
	move.w  d0,COLOR00(a6)		; black screen
	jsr	LoadModule

	lea	Level3InterruptHandler,a3
 	move.l	a3,LVL3_INT_VECTOR			
	
	;; initialise P61
	lea	Module,a0
	sub.l 	a1,a1
	sub.l 	a2,a2
	moveq 	#0,d0
	jsr 	P61_Init

	move.w	#(INTF_SETCLR|INTF_VERTB|INTF_INTEN),INTENA(a6)	

	lea	bitplanes2,a0
	move.l	#IMAGESIZE/4,d0
.clear:
	move.l	#0,(a0)+
	dbra	d0,.clear
	
	lea	bitplanes2,a1
	bsr	SetupImage	; select it

	jsr 	WaitVerticalBlank	

	
	jsr	Init		; enable the playfield
	
	move.l	#50*10,d0
.loop:
	jsr 	WaitVerticalBlank
	dbra	d0,.loop
	
	jsr	LoadNextImage				



.mainLoop:
	jsr 	WaitVerticalBlank

	cmp.l	#50*SECONDS_WAIT,counter
	bne	.updateCounter
	jsr	LoadNextImage
	move.l	#0,counter
	bra	.done
.updateCounter:
	add.l	#1,counter
.done:
	bra	.mainLoop

counter:
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
	if INTERLACE==1
	btst	#VPOSRLOFBIT,VPOSR(a6)
	beq.s	.lof
	lea	copperList,a0
	move.l	a0,COP1LC(a6)
 	move.w  COPJMP1(a6),d0
	bra	.done
.lof:
	lea	copperListAlternate,a0
	 move.l	a0,COP1LC(a6)
 	move.w  COPJMP1(a6),d0
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


Playrtn:
	include "../shared/P6112-Play.i"
	
	if INTERLACE==1
copperListAlternate:
copperListAlternateBplPtr:
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
	endif; INTERLACE==1
	
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
	
	align	4

	section .bss

bitplanes1:	
	ds.b	IMAGESIZE+512
bitplanes2:
	ds.b	IMAGESIZE+(512*2)
bitplanes3:
	ds.b	IMAGESIZE+(512*3)
Module:
	ds.b	111700		; size of uncompressed module
startUserstack:
	ds.b	$1000		; size of stack
userstack:
