	include "includes.i"

	xdef SwitchBuffers
	xdef SwitchBackgroundBuffers
	xdef SwitchBackgroundBuffers2	
	xdef PokePanelBitplanePointers

	
	
SwitchBuffers:
	;; offscreen - bitplane address
	
	move.l	foregroundScrollX,d0
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0		; convert to pixels
	lsr.w   #3,d0		; bytes to scroll

	move.l	foregroundOffscreen,a0
	move.l	foregroundOnscreen,foregroundOffscreen
	move.l	a0,foregroundOnscreen
	move.l	a0,a1

	lea 	copperListBpl1Ptr,a0
	bsr	PokeBitplanePointers

	lea 	copperListBpl1Ptr_MP,a0
	bsr	PokeBitplanePointers		

	add.l	#BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*(96-1),d0	
	lea 	copperListBpl1Ptr2_MP,a0
	bsr	PokeBitplanePointers
				
SwitchBackgroundBuffers:

	move.l	backgroundScrollX,d0
	lsr.w	#BACKGROUND_SCROLL_SHIFT_CONVERT,d0		; convert to pixels	
	lsr.w   #3,d0		; bytes to scroll		

	eor.l	#4,bobBufferOffset	
	move.l	backgroundOffscreen,a0
	move.l	backgroundOnscreen,backgroundOffscreen
	move.l	a0,backgroundOnscreen
	move.l	a0,a1
	
	lea 	copperListBpl2Ptr,a0
	bsr.s	PokeBitplanePointers

	lea 	copperListBpl2Ptr_MP,a0
	bsr.s	PokeBitplanePointers	

	add.l	#BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*(96-1),d0
	lea 	copperListBpl2Ptr2_MP,a0
	bsr.s	PokeBitplanePointers

	
	jsr	SwitchItemSpriteBuffers	
	
	rts


SwitchBackgroundBuffers2:
	move.l	backgroundScrollX,d0
	lsr.w	#BACKGROUND_SCROLL_SHIFT_CONVERT,d0		; convert to pixels	
	lsr.w   #3,d0		; bytes to scroll		

	eor.l	#4,bobBufferOffset	
	move.l	backgroundOffscreen,a0
	move.l	backgroundOnscreen,backgroundOffscreen
	move.l	a0,backgroundOnscreen
	move.l	a0,a1

	rts
PokeBitplanePointers:
	; d0 = frame offset in bytes
	; a0 = BPLP copper list address
	; a1 = bitplanes pointer
	movem.l	d0/a1,-(sp)
	add.l	d0,a1 ; bitplane offset
	moveq	#SCREEN_BIT_DEPTH-1,d0
.bitplaneloop:
	move.l 	a1,d1
	move.w	d1,2(a0)
	swap	d1
	move.w  d1,6(a0)
	lea	BITPLANE_WIDTH_BYTES(a1),a1
	addq	#8,a0
	dbra	d0,.bitplaneloop
	movem.l	(sp)+,d0/a1	
	rts

	
PokePanelBitplanePointers:
	; a0 = BPLP copper list address
	; a1 = bitplanes pointer
	moveq	#4-1,d0
.bitplaneloop:
	move.l 	a1,d1
	move.w	d1,2(a0)
	swap	d1
	move.w  d1,6(a0)
	lea	SCREEN_WIDTH_BYTES(a1),a1
	addq	#8,a0
	dbra	d0,.bitplaneloop
	rts

	

	

	
