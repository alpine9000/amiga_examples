
	if TRACKLOADER=0
; from Photon http://coppershade.org/asmskool/SOURCES/Developing-Demo-Effects/DDE2/Coppershade-DDE2/PhotonsMiniWrapper1.04!.S	
StartupFromOS:			
	move.l	4.w,a6		;Exec library base address in a6
	sub.l	a4,a4
	btst 	#0,297(a6)	;68000 CPU?
	beq.s 	.yes68k
	lea 	GetVBR(PC),a5	;else fetch vector base address to a4:
	jsr 	-30(a6)		;enter Supervisor mode

	    *--- save view+coppers ---*

.yes68k:
	lea 	GfxLib(PC),a1 	;either way return to here and open
	jsr 	-408(a6)	;graphics library
	tst.l 	d0		;if not OK,
	beq.s 	quit		;exit program.
	move.l 	d0,a5		;a5=gfxbase

	move.l 	a5,a6
	move.l 	34(a6),-(sp)
	sub.l 	a1,a1		;blank screen to trigger screen switch
	jsr 	-222(a6)	;on Amigas with graphics cards

	    *--- save int+dma ---*

	lea 	$dff000,a6
	bsr 	WaitEOF		;wait out the current frame
	move.l 	$1c(a6),-(sp)	;save intena+intreq
	move.w 	2(a6),-(sp)	;and dma
	move.l 	$6c(a4),-(sp)	;and also the VB int vector for sport.
	bsr 	AllOff		;turn off all interrupts+DMA

	    *--- call demo ---*

	movem.l a4-a6,-(sp)
	move.l	a7,longJump
	jsr	Entry2
LongJump:	
	move.l	longJump,a7
	movem.l (sp)+,a4-a6

	    *--- restore all ---*

	bsr 	WaitEOF		;wait out the demo's last frame
	bsr 	AllOff		;turn off all interrupts+DMA
	move.l 	(sp)+,$6c(a4)	;restore VB vector
	move.l 	38(a5),$80(a6)	;and copper pointers
	move.l 	50(a5),$84(a6)
	addq.w 	#1,d2		;$7fff->$8000 = master enable bit
	or.w 	d2,(sp)
	move.w 	(sp)+,$96(a6)	;restore DMA
	or.w 	d2,(sp)
	move.w 	(sp)+,$9a(a6)	;restore interrupt mask
	or.w 	(sp)+,d2
	bsr.s 	IntReqD2	;restore interrupt requests

	move.l 	a5,a6
	move.l 	(sp)+,a1
	jsr 	-222(a6)	;restore OS screen

	    *--- close lib+exit ---*

	move.l 	a6,a1		;close graphics library
	move.l 	4.w,a6
	jsr 	-414(a6)
quit:
	moveq	 #0,d0		;clear error return code to OS
	rts			;back to AmigaDOS/Workbench.

GetVBR:
	dc.w 	$4e7a,$c801 	;hex for "movec VBR,a4"
	rte			;return from Supervisor mode

longJump:
	dc.l	0
GfxLib:
	dc.b 	"graphics.library",0,0

WaitEOF:			;wait for end of frame
	bsr.s 	WaitBlitter
	move.w 	#$138,d0
WaitRaster:			;Wait for scanline d0. Trashes d1.
	.l:	move.l 4(a6),d1
	lsr.l 	#1,d1
	lsr.w 	#7,d1
	cmp.w 	d0,d1
	bne.s 	.l		;wait until it matches (eq)
	rts
AllOff:
	move.w 	#$7fff,d2 	;clear all bits
	move.w 	d2,$96(a6)	;in DMACON,
	move.w 	d2,$9a(a6)	;INTENA,
IntReqD2:
	move.w 	d2,$9c(a6)	;and INTREQ
	move.w 	d2,$9c(a6)	;twice for A4000 compatibility
	rts

WaitBlitter:			;wait until blitter is finished
	tst.w 	(a6)		;for compatibility with A1000
	.loop:	btst #6,2(a6)
	bne.s 	.loop
	rts
	endif
