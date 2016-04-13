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

	jsr	Init		  ; enable the playfield		

	move.l	#0,d1 			; x pos 
	move.l	#0,d2			; shift counter
	move.l	#0,d3
MainLoop:		
	jsr 	WaitVerticalBlank
	move.l	d1,d0		    ; x position in pixels
	jsr 	HoriScrollPlayfield ; returns bitplane pointer offset in d0
	jsr 	SwitchBuffers	    ; takes bitplane pointer offset in d0
	add.l	#1,d1
.backfill:
	move.l	onscreen,a0
	add.l	d0,a0
	add.l	#BITPLANE_WIDTH_BYTES-2,a0 ; dest
	lea 	tilemap,a1
	lea	map,a2
	add.l	d3,a2
	add.w	(a2),a1 	; source tile
	jsr	BlitTile

	move.l	offscreen,a0
	add.l	d0,a0
	add.l	#BITPLANE_WIDTH_BYTES-2,a0 ; dest
	lea 	tilemap,a1
	lea	map,a2
	add.l	d3,a2
	add.w	(a2),a1 	; source tile
	jsr	BlitTile	
	add.l	#2,d3
	
	cmp.l	#15,d2	
	bne	.s1	
	move.l	#0,d2
	bra	.s2
.s1:
	add.l	#1,d2
.s2:
	bra	MainLoop

	
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
	include	"out/tilemap-palette.s"
	rts

onscreen:
	dc.l	bitplanes1
offscreen:
	dc.l	bitplanes2

tilemap:
	incbin "out/tilemap.bin"
	
bitplanes1:
	ds.b	IMAGESIZE
	ds.b	BITPLANE_WIDTH_BYTES*20
bitplanes2:
	ds.b	IMAGESIZE
	ds.b	BITPLANE_WIDTH_BYTES*20
	
map:
	include "out/main-map.s"
	
	section .bss
startUserstack:
	ds.b	$1000		; size of stack
userstack:


