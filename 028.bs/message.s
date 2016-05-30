	include "includes.i"
	xdef 	Message
	xdef	InitialiseMessagePanel
	xdef	ShowMessagePanel
	xdef	HideMessagePanel
	xdef	SavePanel
	xdef    RestorePanel
	
SavePanel:
	movem.l	d0-a6,-(sp)
	move.w	#(32*4)<<6|(8),d0
	lea	mpanel,a0
	move.l	#splash+BOB_TOTAL_SAVE,a2
	add.l	#(40*4*8),a0
	jsr	SimpleBlit
	WaitBlitter	
	move.w	#1,panelSaved
	movem.l	(sp)+,d0-a6
	rts

RestorePanel:
	cmp.w	#0,panelSaved
	beq	.skip
	movem.l	d0-a6,-(sp)
	move.w	#(32*4)<<6|(8),d0
	move.l	#splash+BOB_TOTAL_SAVE,a0
	lea	mpanel,a2
	add.l	#(40*4*8),a2
	jsr	SimpleBlit
	WaitBlitter		
	movem.l	(sp)+,d0-a6
.skip:
	rts
	
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
	bsr	SavePanel	
	move.w	d0,d1
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
	bsr	RestorePanel	
	rts

InitialiseMessagePanel:
	lea	mpanelCopperListBpl1Ptr,a0
	lea	mpanel,a1
	jsr	PokePanelBitplanePointers
	rts

panelSaved:
	dc.w	0
mpanel:
	incbin "out/mpanel.bin"