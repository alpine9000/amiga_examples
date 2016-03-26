	include "includes.i"
	
	xdef 	PokeBitplanePointers
	xdef	copperList
	xdef	onscreen
	xdef	offscreen
	xdef	copperListBplPtr
	
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

	jsr	SwitchBuffers		
	
	move.w	#(INTF_SETCLR|INTF_VERTB|INTF_INTEN),INTENA(a6)	
 	move.w	#(DMAF_BLITTER|DMAF_SETCLR!DMAF_MASTER),DMACON(a6) 		

	move.l	onscreen,a0
	move.l	#4,d0		 ; color#
	move.w	#SCREEN_HEIGHT,d1 ; height
	jsr	BlitFillColor
	move.l	offscreen,a0
	move.l	#4,d0		 ; color#
	move.w	#SCREEN_HEIGHT,d1 ; height
	jsr	BlitFillColor	

	jsr	Init		; enable the playfield		

.mainLoop:
	move.l	offscreen,a0
	move.l	#4,d0		; color#
	move.w	#25,d1
	jsr	BlitFillColor

	move.l	direction,d0
	add.l	d0,xpos
	move.l	xpos,d0
	move.l	#15,d1
	move.l	offscreen,a0
	lea	text,a1
	jsr	DrawText

	jsr 	WaitVerticalBlank	
	jsr	SwitchBuffers

	cmp.l	#SCREEN_WIDTH-((endText-text)*FONT_WIDTH),xpos
	ble	.notRightEdge
	move.l	direction,d0
	muls.w	#-1,d0
	move.l	d0,direction
	bra	.mainLoop
.notRightEdge:
	cmp.l	#0,xpos
	bne	.notLeftEdge
	move.l	direction,d0
	muls.w	#-1,d0
	move.l	d0,direction
.notLeftEdge:
	bra	.mainLoop
	
text:
	dc.b	"My first text on an Amiga!"
endText:	
	dc.b	0
	align	4
xpos:
	dc.l	0
direction:
	dc.l	2
	
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
onscreen:
	dc.l	bitplanes1
offscreen:
	dc.l	bitplanes2
	section .bss	
bitplanes1:
	ds.b	IMAGESIZE+(512)
bitplanes2:
	ds.b	IMAGESIZE+(512*2)
startUserstack:
	ds.b	$1000		; size of stack
userstack:


