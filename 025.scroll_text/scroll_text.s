	include "includes.i"
	
	xdef	copperList
	xdef	onscreen
	xdef	offscreen
	xdef	copperListBplPtr

Y_POS	equ	8
NUM_LINES	equ	27
	
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

	move.l	offscreen,a0
	move.l	#BACKGROUND_COLOR,d0
	move.w	#SCREEN_HEIGHT,d1
	move.w	#0,d2		  ; ypos
	jsr	BlitFillColor	
	
	WaitBlitter
	jsr	Init		  ; enable the playfield		

MainLoop:		
	jsr 	WaitVerticalBlank

	jsr	InstallPalette	


	;; jsr	GreyPalette	

	;; move.w #$500,COLOR00(a6)
	
	jsr	SwitchBuffers			

	move.l	#NUM_LINES-1,d3
.loop:
	bsr	UpdateLine
	dbra	d3,.loop
	
	
	bra	MainLoop


UpdateLine:
	;; d3 - line number
	movem.l	d0-a6,-(sp)
	lea.l	textlut,a2
	move.l  d3,d4
	mulu.w	#16,d4
	add.l	d4,a2		; index into LUT	
	cmp.l	#8,8(a2)
	bne	.shift

.drawtext:
	move.l	#BITPLANE_WIDTH-16,d0	; xpos
	move.l	onscreen,a0
	move.l	#FONT_HEIGHT+1,d1	; ypos	
	move.l	d3,d4
	mulu.w	d3,d1
	bsr	GetNextChar
	jsr	BlitChar8	
	move.l	#0,8(a2)
.shift:
	move.l	offscreen,a0 	; dest
	move.l	onscreen,a1	; src
	move.l	#FONT_HEIGHT,d1	; height
	move.l	#FONT_HEIGHT+1,d2 ; ypos
	mulu.w	d3,d2
Test:	

	;; move.l	#1,d0
 	move.l	12(a2),d0
	jsr	BlitScroll
	;; add.l	#1,8(a2)
	add.l	d0,8(a2)
	movem.l	(sp)+,d0-a6
	rts
	
charbuffer:
	dc.b	0
	dc.b	0

shiftcounter:
	dc.l	8

textlut:
	dc.l	text1
	dc.l	text2
	dc.l	8
	dc.l	1
	dc.l	text3
	dc.l	text4
	dc.l	8
	dc.l	2
	dc.l	text5
	dc.l	text4
	dc.l	8
	dc.l	4
	dc.l	text3
	dc.l	text2
	dc.l	8
	dc.l	8
	dc.l	text1
	dc.l	text2
	dc.l	8
	dc.l	4
	dc.l	text3
	dc.l	text4
	dc.l	8
	dc.l	2
	dc.l	text1
	dc.l	text3
	dc.l	8
	dc.l	1
	dc.l	text5
	dc.l	text1
	dc.l	8
	dc.l	2
	dc.l	text1
	dc.l	text2
	dc.l	8
	dc.l	4
	dc.l	text3
	dc.l	text1
	dc.l	8
	dc.l	8
	dc.l	text5
	dc.l	text5
	dc.l	8
	dc.l	4
	dc.l	text4
	dc.l	text4
	dc.l	8
	dc.l	2
	dc.l	text2
	dc.l	text4
	dc.l	8
	dc.l	1
	dc.l	text1
	dc.l	text2
	dc.l	8
	dc.l	2
	dc.l	text4
	dc.l	text5
	dc.l	8
	dc.l	4
	dc.l	text2
	dc.l	text3
	dc.l	8
	dc.l	8
	dc.l	text1
	dc.l	text3
	dc.l	8
	dc.l	4
	dc.l	text3
	dc.l	text4
	dc.l	8
	dc.l	2
	dc.l	text5
	dc.l	text2
	dc.l	8
	dc.l	1
	dc.l	text3
	dc.l	text3
	dc.l	8
	dc.l	2
	dc.l	text1
	dc.l	text4
	dc.l	8
	dc.l	4
	dc.l	text4
	dc.l	text3
	dc.l	8
	dc.l	8
	dc.l	text2
	dc.l	text3
	dc.l	8
	dc.l	4
	dc.l	text4
	dc.l	text5
	dc.l	8
	dc.l	2
	dc.l	text1
	dc.l	text2
	dc.l	8
	dc.l	1
	dc.l	text3
	dc.l	text4
	dc.l	8
	dc.l	2
	dc.l	text3
	dc.l	text2
	dc.l	8
	dc.l	4
	dc.l	text1
	dc.l	text2
	dc.l	8
	dc.l	8
	dc.l	text3
	dc.l	text4
	dc.l	8
	dc.l	4
	dc.l	text4
	dc.l	text5
	dc.l	8
	dc.l	2
	
	
text1:
	dc.b	"In this chapter, you will learn how to use the Amiga's graphics coprocessor (or Copper) and its simple instruction set to organize mid-screen register value modifications and pointer register set-up during the  vertical blanking  interval. The chapter shows how to organize Copperinstructions into Copper lists, how to use Copper lists in interlacedmode, and how to use the Copper with the blitter. The Copper is discussed	in this chapter in a general fashion. The chapters that deal withplayfields, sprites, audio, and the blitter contain more specificsuggestions for using the Copper."
	dc.b	0
text2:	
	dc.b	"The Amiga is a family of personal computers sold by Commodore in the 1980s and 1990s. Based on the Motorola 68000 family of microprocessors, the machine has a custom chipset with graphics and sound capabilities that were unprecedented for the price, and a pre-emptive multitasking operating system called AmigaOS."
	dc.b	0
text3:	
	dc.b	"This repo contains example programs I have written as I re-learn how to program an amiga. The programs are written in assembler and directly access the hardware. The target is an Amiga 500 (my long lost friend). Currently I do not own an amiga, so I can only test using UAE, so it's possible they will not work on the real hardware."
	dc.b	0
text4:	
	dc.b	"The Amiga 1000 was officially released in July 1985, but a series of production problems meant it did not become widely available until early 1986. The best selling model, the Amiga 500, was introduced in 1987 and became one of the leading home computers of the late 1980s and early 1990s with four to six million sold.[1] The A3000, introduced in 1990, started the second generation of Amiga systems, followed by the A500+ and the A600. Finally, as the third generation, the A1200 and the A4000 were released in 1992. The platform became particularly popular for gaming and programming demos. It also found a prominent role in the desktop video, video production, and show control business, leading to affordable video editing systems such as the Video Toaster. The Amiga's native ability to simultaneously play back multiple digital sound samples made it a popular platform for early 'tracker' music software. The relatively powerful processor and ability to access several megabytes of memory led to the development of several 3D rendering packages, including LightWave 3D, Imagine, Aladdin 4D, and TurboSilver."
	dc.b	0
text5:	
	dc.b	"Although early Commodore advertisements attempt to cast the computer as an all-purpose business machine, especially when outfitted with the Amiga Sidecar PC compatibility addon, the Amiga was most commercially successful as a home computer, with a wide range of games and creative software.[2][3] It was also a less expensive alternative to the Apple Macintosh and IBM PC as a general-purpose business or home computer. Initially, the Amiga was developed alongside various Commodore PC clones, but Commodore later left the PC market. Poor marketing and the failure of the later models to repeat the technological advances of the first systems meant that the Amiga quickly lost its market share to competing platforms, such as the fourth generation game consoles, Apple Macintosh, and later IBM PC compatibles.[1] Commodore ultimately went bankrupt in April 1994 after the 'make or break' Amiga CD32 model failed in the marketplace."
	dc.b	0
endText:	
	dc.b	0
	align	4


GetNextChar:
	movem.l	a2-a3,-(sp)
	lea.l	textlut,a2
	mulu.w	#16,d4		;
	add.l	d4,a2		; index into LUT
	move.l	(a2),a3		; address of next char
	cmp.b	#0,(a3)
	bne	.moreText
.wrapText:
	move.l  4(a2),(a2)
.moreText:	
	sub.l	d2,d2
	move.l	(a2),a3
	move.b	(a3),d2
	add.l	#1,(a2)
	movem.l	(sp)+,a2-a3
	rts
	
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


