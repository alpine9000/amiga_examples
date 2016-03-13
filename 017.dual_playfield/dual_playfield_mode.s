	include "../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	include "constants.i"
	
entry:
	lea 	CUSTOM,a6	
	bsr	init
.mainLoop:
	bsr 	waitVerticalBlank
	bra	.mainLoop
	
	include "init.s"
	include "utils.s"


pokeBitplanePointers:
 	;; a0 = BPLP copper list address
	;; a1 = address of playfield's interleaved bitplane data
	movem.l	d0-a6,-(sp)
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

	
installColorPalette:
	;; these palette files set the correct colors for each playfield
	;; playfield1 uses COLOR00 -> COLOR07
	include "out/playfield1-palette.s"
	;; playfield2 uses COLOR08 -> COLOR15
	include "out/playfield2-palette.s"
	rts
	
copper:
pf1_bitplanepointers:
	;; this is where bitplanes are assigned to playfields
	;; http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0079.html
	;; for 3 bitplanes per playfield, playfield1 gets bitplanes 1,3,5
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
pf2_bitplanepointers:
	;; for 3 bitplanes per playfield, playfield2 gets bitplanes 2,4,6
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0

	dc.l	$fffffffe

pf1_bitplanes:
	incbin	"out/playfield1.bin"

pf2_bitplanes:
	incbin	"out/playfield2.bin"