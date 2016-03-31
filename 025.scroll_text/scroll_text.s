	include "includes.i"
	
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
	move.l	#BACKGROUND_COLOR,d0
	move.w	#SCREEN_HEIGHT,d1
	move.w	#0,d2		  ; ypos
	jsr	BlitFillColor
	
	WaitBlitter
	jsr	Init		  ; enable the playfield		

	lea	text,a3
MainLoop:		
	jsr 	WaitVerticalBlank
	;; 	jsr	InstallPalette	

	cmp.l	#8,shiftcounter
	bne	.shift

.drawtext:
	cmp.b	#0,(a3)
	bne	.moreText
.wrapText:
	lea     text,a3
.moreText:	
	move.b	(a3)+,d2
	move.l	#BITPLANE_WIDTH-16,d0	; xpos
	move.l	#16,d1		  	; ypos
	move.l	onscreen,a0
	jsr	BlitChar8
	move.l	#0,shiftcounter
.shift:
	move.l	onscreen,a0
	move.l	#FONT_HEIGHT,d1
	move.l	#16,d2
	jsr	BlitScroll
	add.l	#1,shiftcounter

	;; 	jsr	GreyPalette	
	
	bra	MainLoop

charbuffer:
	dc.b	0
	dc.b	0

shiftcounter:
	dc.l	8
text:
	dc.b	"ABCDEFEGHIJLMNOPQRSTUVWXYZabcdefghijlklmnopqrstuvwxyz" 
endText:	
	dc.b	0
	align	4

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
	dc.l	$fffffffe			

InstallPalette:
	include	"out/font8x8-palette.s"
	rts

GreyPalette:
	include	"out/font8x8-grey.s"
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


