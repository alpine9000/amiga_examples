	include "includes.i"
	include "P6112-Options.i"
	
	xdef 	PokeBitplanePointers
	xdef	Level3InterruptHandler
	xdef	copperList
	xdef 	copperListAlternate
	xdef 	bitplanesp1
	xdef 	bitplanesp2
	xdef 	bitplanesp3
	xdef	Module1
	
byteMap:
	dc.l	Entry
	dc.l	endCode-byteMap

Entry:
	move.l	userstack,a7
	lea 	CUSTOM,a6

	move	#$7ff,DMACON(a6)	; disable all dma
	move	#$7fff,INTENA(a6) 	; disable all interrupts		
	
	move.w  d0,COLOR00(a6)		; black screen
	jsr	LoadModule

	lea	Level3InterruptHandler,a3
 	move.l	a3,LVL3_INT_VECTOR			
	
	;; initialise P61
	lea 	Module1,a0
	move.l	(a0),a0
	sub.l 	a1,a1
	sub.l 	a2,a2
	moveq 	#0,d0
	jsr 	P61_Init

	move.w	#(INTF_SETCLR|INTF_VERTB|INTF_INTEN),INTENA(a6)	

	move.l	bitplanesp2,a0	; setup an empty bitplane
	move.l	#IMAGESIZE,d0
	jsr	ClearMemory	; clear it
	jsr	WaitBlitter	; make sure it's clear

	move.l	a0,a1
	bsr	SetupImage	; select it
	
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
	movem.l	d0-a6,-(sp)
	;; jsr 	P61_Music		; and call the playroutine manually.
	movem.l	(sp)+,d0-a6	

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

	;; Module1:
	;; incbin "../assets/P61.sowhat-intro"			;usecode $9410
	
	align	4
	
bitplanesp1:
	dc.l	endCode
bitplanesp2:
	dc.l	endCode+(512)+IMAGESIZE
bitplanesp3:
	dc.l	endCode+(512*2)+(2*IMAGESIZE)
userstack:
	dc.l	endCode+(512*3)+(3*IMAGESIZE)+$1000
Module1:
	dc.l	endCode+(512*3)+(3*IMAGESIZE)+$1000+4