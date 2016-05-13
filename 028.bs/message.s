	include "includes.i"
	xdef 	Message
	xdef	InitialiseMessagePanel
	xdef	ShowMessagePanel
	xdef	HideMessagePanel
	
Message:
	;; a0 - bitplane
	;; a1 - text
	;; d1 - ypos

	move.w	#SCREEN_WIDTH/2,d0
	move.l	a1,a2
.loop:
	cmp.b 	#0,(a2)+
	beq	.lengthComplete
	sub.w	#4,d0
	bra	.loop
	
.lengthComplete:
	move.w	d0,d1
	move.w	#(32*4)<<6|(8),d0
	lea	mpanelOrig,a0
	lea	mpanel,a2
	add.l	#(40*4*8),a2
	jsr	SimpleBlit
	
	lea	mpanel,a0
	move.w	d1,d0
	move.w	#11,d1
	jsr	DrawMaskedText8
	bsr	ShowMessagePanel
	rts

ShowMessagePanel:
	jsr	WaitVerticalBlank
	lea	mpanelCopperList,a0
	move.l	a0,COP1LC(a6)
	rts


HideMessagePanel:
	jsr	WaitVerticalBlank
	lea	copperList,a0
	move.l	a0,COP1LC(a6)
	rts

InitialiseMessagePanel:
	lea	mpanelCopperListBpl1Ptr,a0
	lea	mpanel,a1
	jsr	PokePanelBitplanePointers
	rts

mpanel:
	incbin "out/mpanel.bin"
mpanelOrig:
	incbin "out/mpanelOrig.bin"