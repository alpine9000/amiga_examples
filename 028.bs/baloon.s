	include "includes.i"
	
	if BALOON_BOB=1
	
	xdef	RenderBaloon
	xdef    baloonSaveOffscreen
	xdef    baloonSaveOnscreen
	xdef    baloonLastSaveOffscreen
	xdef    baloonLastSaveOnscreen
	xdef	DisableBaloon
	xdef	EnableBaloon
	xdef	TriggerBaloon	

BALOON_BLIT_WIDTH_BYTES	equ 6
BALOON_BLIT_WIDTH_WORDS equ BALOON_BLIT_WIDTH_BYTES/2

DisableBaloon:
	bsr	RestoreBaloonBackground
	move.w	#0,baloonsEnabled
	move.l	baloonStartX,baloonX
	rts

EnableBaloon:
	move.w	#1,baloonsEnabled
	rts

TriggerBaloon:
	cmp.w	#1,baloonsEnabled
	bne	.skip
	;; d0.w - y tile index
	lsl.w	#4,d0
	move.l	#0,baloonLastSaveOffscreen
	move.l	#0,baloonLastSaveOnscreen	
	move.w	d0,baloonY	
	move.l	baloonStartX,baloonX
	move.w	#2,baloonsEnabled
.skip:
	rts	
	
RestoreBaloonBackground:
	bsr	RestorePreviousBaloonBackground
	move.l	baloonSaveOffscreen,a0
	move.l	baloonSaveOnscreen,baloonSaveOffscreen
	move.l	a0,baloonSaveOnscreen	

	move.l	baloonLastSaveOffscreen,a0
	move.l	baloonLastSaveOnscreen,baloonLastSaveOffscreen
	move.l	a0,baloonLastSaveOnscreen
	bsr	RestorePreviousBaloonBackground
	rts
	

	
RestorePreviousBaloonBackground:
	cmp.l	#0,baloonLastSaveOffscreen
	beq	.skip
	
	move.l	baloonX,d2	
	add.l	#16<<BACKGROUND_SCROLL_SHIFT_CONVERT,d2
	cmp.l	#0<<BACKGROUND_SCROLL_SHIFT_CONVERT,d2
	bgt	.dontReset
	move.l	#0,baloonLastSaveOffscreen
	move.l	#0,baloonLastSaveOnscreen	
	move.w	#1,baloonsEnabled
	;; move.l	baloonStartX,baloonX
	rts
.dontReset:
	if 0
	move.l	baloonLastSaveOffscreen,d0
	move.l	backgroundOffscreen,d1

	sub.l	d1,d0
	
	divu.w	#BITPLANE_WIDTH_BYTES,d0
	swap	d0

	cmp.w	#BITPLANE_WIDTH_BYTES,d0
	bge	.1word
	cmp.w	#BITPLANE_WIDTH_BYTES-2,d0
	bge	.2word	
	bra	.normal

.1word:
	bsr	RestorePreviousBaloonBackground1Word
	rts
.2word:
	bsr	RestorePreviousBaloonBackground2Word
	rts
.normal:	
	endif
	WaitBlitter	
	move.w	#0,BLTCON1(a6)		;
	move.w	#BC0F_SRCA|BC0F_DEST|$f0,BLTCON0(a6)
	
	move.w 	#0,BLTAMOD(a6)
	move.w 	#BITPLANE_WIDTH_BYTES-BALOON_BLIT_WIDTH_BYTES,BLTDMOD(a6)	;

	move.l 	baloonSaveOffscreen,BLTAPTH(a6) 	; source
	move.l 	baloonLastSaveOffscreen,BLTDPTH(a6)	; dest
	move.w	#$ffff,BLTAFWM(a6)
	move.w	#$ffff,BLTALWM(a6)
	move.w 	#(32*SCREEN_BIT_DEPTH)<<6|(BALOON_BLIT_WIDTH_WORDS),BLTSIZE(a6)	;rectangle size, starts blit
	move.l	#0,baloonLastSaveOffscreen
.skip:
	rts

RestorePreviousBaloonBackground1Word:
	cmp.l	#0,baloonLastSaveOffscreen
	beq	.skip
	WaitBlitter	
	move.w	#0,BLTCON1(a6)		;
	move.w	#BC0F_SRCA|BC0F_DEST|$f0,BLTCON0(a6)
	
	move.w 	#4,BLTAMOD(a6)
	move.w 	#BITPLANE_WIDTH_BYTES-BALOON_BLIT_WIDTH_BYTES+4,BLTDMOD(a6)	;

	move.l 	baloonSaveOffscreen,BLTAPTH(a6) 	; source
	move.l 	baloonLastSaveOffscreen,BLTDPTH(a6)	; dest
	move.w	#$ffff,BLTAFWM(a6)
	move.w	#$ffff,BLTALWM(a6)
	move.w 	#(32*SCREEN_BIT_DEPTH)<<6|(1),BLTSIZE(a6)	;rectangle size, starts blit
	move.l	#0,baloonLastSaveOffscreen
.skip:
	rts

RestorePreviousBaloonBackground2Word:
	cmp.l	#0,baloonLastSaveOffscreen
	beq	.skip
	WaitBlitter	
	move.w	#0,BLTCON1(a6)		;
	move.w	#BC0F_SRCA|BC0F_DEST|$f0,BLTCON0(a6)
	
	move.w 	#2,BLTAMOD(a6)
	move.w 	#BITPLANE_WIDTH_BYTES-BALOON_BLIT_WIDTH_BYTES+2,BLTDMOD(a6)	;

	move.l 	baloonSaveOffscreen,BLTAPTH(a6) 	; source
	move.l 	baloonLastSaveOffscreen,BLTDPTH(a6)	; dest
	move.w	#$ffff,BLTAFWM(a6)
	move.w	#$ffff,BLTALWM(a6)
	move.w 	#(32*SCREEN_BIT_DEPTH)<<6|(BALOON_BLIT_WIDTH_WORDS-1),BLTSIZE(a6)	;rectangle size, starts blit
	move.l	#0,baloonLastSaveOffscreen
.skip:
	rts		

SaveBaloonBackground:
	;; a0.l	source bitplane data
	WaitBlitter	
	move.w	#0,BLTCON1(a6)		;
	move.w	#BC0F_SRCA|BC0F_DEST|$f0,BLTCON0(a6)

	move.w 	#BITPLANE_WIDTH_BYTES-BALOON_BLIT_WIDTH_BYTES,BLTAMOD(a6)	
	move.w 	#0,BLTDMOD(a6)

	move.l 	a0,BLTAPTH(a6) ; source
	move.l 	baloonSaveOffscreen,BLTDPTH(a6)	; dest
	move.w	#$ffff,BLTAFWM(a6)
	move.w	#$ffff,BLTALWM(a6)
 	move.w 	#(32*SCREEN_BIT_DEPTH)<<6|(BALOON_BLIT_WIDTH_WORDS),BLTSIZE(a6)	;rectangle size, starts blit
	move.l	a0,baloonLastSaveOffscreen
	rts	
	
	
RenderBaloon:

	cmp.w	#2,baloonsEnabled
	beq	.renderBaloon
	rts
.renderBaloon:

	bsr	RestorePreviousBaloonBackground
	
	move.l	baloonX,d2
	add.l	backgroundScrollX,d2
	move.l	baloonDeltaX,d1
	add.l	d1,baloonX

	move.w	baloonY,d1
	mulu.w	#BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH,d1	
	
	move.l	d2,d0
	lsr.w	#BACKGROUND_SCROLL_SHIFT_CONVERT,d0 ; convert to pixels
	lsr.w   #3,d0		; bytes to scroll

	move.l	backgroundOffscreen,a0
	add.l	d0,a0
	add.l	d1,a0

	lea 	backgroundTilemap,a1	
	add.w	#$c00,a1 	; source tile

	bsr	SaveBaloonBackground
	
	WaitBlitter	
	move.w	#0,BLTCON1(a6)		;

	move.l	d2,d0
	lsr.w	#BACKGROUND_SCROLL_SHIFT_CONVERT,d0 ; convert to pixels	
	lsl.w	#8,d0	; BLIT_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT
	lsl.w	#4,d0 	; BLIT_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT

	move.w	d0,BLTCON1(A6)

	ori.w   #BC0F_SRCA|BC0F_SRCB|BC0F_SRCC|BC0F_DEST|$ca,d0
	;;       A(mask) B(bob)  C(bg)   D(dest)
	
	move.w	d0,BLTCON0(a6)

	move.w 	#0,BLTAMOD(a6)	; mask
	move.w 	#BACKGROUND_TILEMAP_WIDTH_BYTES-BALOON_BLIT_WIDTH_BYTES,BLTBMOD(a6) ; bob
	move.w 	#BITPLANE_WIDTH_BYTES-BALOON_BLIT_WIDTH_BYTES,BLTCMOD(a6)	    ; background	
	move.w 	#BITPLANE_WIDTH_BYTES-BALOON_BLIT_WIDTH_BYTES,BLTDMOD(a6)	    ; dest

	move.l 	#baloonMask,BLTAPTH(a6)	; mask
	move.l	a1,BLTBPTH(a6) 		; bob
	move.l 	a0,BLTCPTH(a6)		; bg
	move.l 	a0,BLTDPTH(a6)		; dest
	
	move.w	#$ffff,BLTAFWM(a6)
	move.w	#$0000,BLTALWM(a6)
	move.w 	#(32*SCREEN_BIT_DEPTH)<<6|(BALOON_BLIT_WIDTH_WORDS),BLTSIZE(a6)	;rectangle size, starts blit

	WaitBlitter	
.dontRenderBaloon:
	rts		

baloonSaveOffscreen:
	dc.l	baloonSave1
baloonSaveOnscreen:
	dc.l	baloonSave2
baloonX:	
	dc.l	(320-16)<<BACKGROUND_SCROLL_SHIFT_CONVERT
baloonY:	
	dc.w	20
baloonDeltaX:
	dc.l	-24
baloonStartX:
	dc.l	(320-32)<<BACKGROUND_SCROLL_SHIFT_CONVERT
baloonEndX:
	dc.l	0
	
baloonsEnabled:
	dc.w	0
baloonMask:
	incbin	"out/baloonMask-mask.bin"

baloonSave1:
	ds.b	BALOON_BLIT_WIDTH_BYTES*32*3
baloonSave2:
	ds.b	BALOON_BLIT_WIDTH_BYTES*32*3
baloonLastSaveOffscreen:
	dc.l	0
baloonLastSaveOnscreen:
	dc.l	0
	endif