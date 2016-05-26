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
	add.l	d0,a0
	lea 	backgroundTilemap,a1	
	add.l	#BITPLANE_WIDTH_BYTES-2,a0 ; dest
	move.w	(a2),d0  	; source tile
	move.l	backgroundScrollX,d2
	lsr.b	#BACKGROUND_SCROLL_SHIFT_CONVERT,d2		; convert to pixels
	andi.w	#$f,d2		; find the shift component		

	;;  this is where the old baloon was triggered - won't work anymore

	cmp.l	#backgroundBitplanes2,backgroundOffscreen
	bne	.dontProcessBobs
	cmp.w	#0,d0
	beq	.addCloud
	cmp.w	#$900,d0
	beq	.addCloud	
	cmp.w	#$c00,d0
	beq	.addBaloon
	bra	.dontProcessBobs
.addCloud:
	move.w	d2,d1
	jsr	AddBobCloud
	bra	.skip
.addBaloon:
	move.w	d2,d1
	jsr	AddBobBaloon
	bra	.skip	
	
.dontProcessBobs:
	cmp.w	#0,d0
	beq	.skip
	cmp.w	#$c00,d0
	beq	.skip
	cmp.w	#$900,d0
	beq	.skip	
	bra	.blit
.skip:
	move.l	#$8,d0		
.blit:
	add.w	d0,a1	
	jsr	BlitBackgroundTile

	
	rts
	
OldRenderBackgroundTile:	
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
	jsr	ClearBobs
	move.l	#0,backgroundScrollX
.skip:


	if 1 			; new background tile render method

	jsr	RestoreBobBackgrounds
	move.l	backgroundOffscreen,a0
	bsr	RenderBackgroundTile
	
	add.l	#2,a2
	add.l	#BACKGROUND_SCROLL_PIXELS,backgroundScrollX
	move.l	backgroundOffscreen,a0
	bsr	RenderBackgroundTile
	sub.l	#BACKGROUND_SCROLL_PIXELS,backgroundScrollX
	sub.l	#2,a2

	else

	jsr	RestoreBobBackgrounds
	move.l	backgroundOffscreen,a0
	bsr	OldRenderBackgroundTile	
	
	endif

	cmp.l	#SCREEN_WIDTH*2,backgroundScrollX
	ble	.dontRenderBobs
	jsr	RenderBob
.dontRenderBobs:
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

	