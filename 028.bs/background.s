	include "includes.i"

	xdef	InitialiseBackground
	xdef	RenderNextBackgroundFrame
	xdef	backgroundScrollX
	xdef	backgroundOnscreen
	xdef	backgroundOffscreen
	xdef	backgroundTilemap
	
InitialiseBackground:
	move.l	#0,backgroundScrollX
	move.l	backgroundOffscreen,a0
	move.l	#0,d0
	move.l	#256+10,d1
	move.l	#0,d2
	jsr	BlitFillColor
	jsr     WaitVerticalBlank
	jsr	SwitchBuffers
	move.l	backgroundOffscreen,a0
	move.l	#0,d0
	move.l	#256+10,d1
	move.l	#0,d2
	jsr	BlitFillColor
	rts
	
RenderBackgroundTile:	
	;; a2 - map
	move.l	backgroundScrollX,d0
	lsr.w	#BACKGROUND_SCROLL_SHIFT_CONVERT,d0 ; convert to pixels
	lsr.w   #3,d0		; bytes to scroll
	move.l	backgroundOffscreen,a0
	add.l	d0,a0
	lea 	backgroundTilemap,a1	
	add.l	#BITPLANE_WIDTH_BYTES-2,a0 ; dest
	move.w	(a2),d0  	; source tile
	add.w	d0,a1
	move.l	backgroundScrollX,d2
	lsr.b	#BACKGROUND_SCROLL_SHIFT_CONVERT,d2		; convert to pixels
	andi.w	#$f,d2		; find the shift component		


	if BALOON_BOB=1	
	cmp.w	#$306,d0
	bne	.dontTriggerBaloon
	move.w	d2,d0
	jsr	TriggerBaloon
.dontTriggerBaloon:
	endif	
	
	jsr	BlitBackgroundTile
	cmp.l   #backgroundBitplanes1,backgroundOffscreen
	bne	.offsetSub
	add.l	#backgroundBitplanes2-backgroundBitplanes1,a0
	bra	.doBlit
.offsetSub:
	sub.l	#backgroundBitplanes2-backgroundBitplanes1,a0
.doBlit:
	jsr	BlitBackgroundTile	
	rts

RenderNextBackgroundFrame:
	lea	backgroundMap,a2
	move.l	backgroundScrollX,d0
	lsr.l	#BACKGROUND_SCROLL_TILE_INDEX_CONVERT,d0
	and.b	#$fe,d0
	add.l	d0,a2
	cmp.w	#$FFFF,20(a2)
	bne	.skip
	move.l	#0,backgroundScrollX
.skip:

	if BALOON_BOB=1
	jsr	RenderBaloon
	endif
	bsr	RenderBackgroundTile
	
	rts
	
	
backgroundScrollX:
	dc.l	0	
backgroundTilemap:
	incbin "out/background.bin"	
backgroundMap:
	include "out/background-map.s"
	dc.w	$FFFF

backgroundOnscreen:
	dc.l	backgroundBitplanes1
backgroundOffscreen:
	dc.l	backgroundBitplanes2

	
	section .bss
backgroundBitplanes1:
	ds.b	IMAGESIZE
	ds.b	LINESIZE*10
backgroundBitplanes2:
	ds.b	IMAGESIZE
	ds.b	LINESIZE*10

	