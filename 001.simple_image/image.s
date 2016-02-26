	include ../include/registers.i
	include hardware/dmabits.i
	include hardware/intbits.i
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH_BYTES	equ (320/8)
SCREEN_BIT_DEPTH	equ	4

	
entry:	
	lea	level3InterruptHandler(pc),a3
	move.l	a3,LVL3_INT_VECTOR

	lea 	CUSTOM,a1

	;; install copper list and enable DMA
	lea	copper(pc),a0
	move.l	a0,cop1lc(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	
.mainLoop:
	bra.b	.mainLoop

level3InterruptHandler:
	movem.l	d0-a6,-(sp)

.checkVerticalBlank:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_VERTB,d0	
	beq.s	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; Clear interrupt bit	

.resetBitplanePointers:
	lea	bitplanes,a1
	lea	$dff0e0,a2
	moveq	#SCREEN_BIT_DEPTH,d0
.bitplaneloop:
	move.l	a1,(a2)
	lea	SCREEN_WIDTH_BYTES(a1),a1 ; Bit plane data is interleaved
	addq	#4,a2
	dbra	d0,.bitplaneloop
	
.checkCopper:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_COPER,d0	
	beq.s	.interruptComplete
.copperInterrupt:
	move.w	#INTF_COPER,INTREQ(a5)	; Clear interrupt bit	
	
.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte

copper:

	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPLCON0,(SCREEN_BIT_DEPTH<<12)|$200 ; Set color depth and enable COLOR
	dc.w	BPL1MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES

	rem	// Original copper list from https://github.com/vilcans/amiga-startup
	dc.l	$008e2c81,$00902cc1
	dc.l	$00920038,$009400d0
	dc.w	$0100,(SCREEN_BIT_DEPTH<<12)|$200
	dc.l	$01020000,$01060000,$010c0011
	dc.w	$108,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.w	$10a,SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES
	dc.l	$01fc0000
	erem
	
	include	"out/image-copper.s"

	dc.l	$fffffffe	
bitplanes:
	incbin	"out/image-data.bin"
	