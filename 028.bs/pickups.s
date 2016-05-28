	include "includes.i"

	xdef	InitialisePickups
	xdef	UsePickup
	xdef	PickupEye
	xdef	PickupClock
	xdef	PickupArrow
	xdef	FlashPickup				
	xdef	ResetPickups
	
PICKUP_OFFSET 		equ	(SCREEN_WIDTH_BYTES*PANEL_BIT_DEPTH*17)+(272/8)
PICKUP_NUM_FLASHES	equ	6

ResetPickupItem:	macro
	cmp.w	#0,has\1Pickup
	beq	.\@skip
	move.w	#PICKUP_NUM_FLASHES,has\1Pickup
	bsr	Show\1Pickup
.\@skip:
	endm
	
ResetPickups:
	move.l	#0,lastPickupFrameCount
	ResetPickupItem	Arrow
	ResetPickupItem	Clock
	ResetPickupItem	Eye	
	rts

InitialisePickups:
	move.w	#0,hasEyePickup
	move.w	#0,hasArrowPickup
	move.w	#0,hasClockPickup
	bsr	HideEyePickup
	bsr	HideArrowPickup
	bsr	HideClockPickup
	rts
	
	
UsePickup:
	move.l	frameCount,d0
	sub.l	lastPickupFrameCount,d0
	cmp.l	#50,d0
	blt	.done

	move.l	frameCount,lastPickupFrameCount
	cmp.w	#0,hasEyePickup
	bne	.useEye
	cmp.w	#0,hasClockPickup
	bne	.useClock
	cmp.w	#0,hasArrowPickup
	bne	.useArrow	
	bra	.done
.useEye:
	PlaySound Whoosh
	bsr	HideEyePickup
	move.w	#0,hasEyePickup
	jsr	RevealPathway
	bra	.done
.useClock:
	PlaySound Whoosh
	bsr	HideClockPickup
	move.w	#0,hasClockPickup
	jsr	FreezeScrolling
	bra	.done
.useArrow:
	move.l	foregroundPlayerTileAddress,a0
	cmp.w	#0,a0
	beq	.done
	move.w	(a0),d0
	cmp.w	#$f02,d0	; dont active on safe columns
	beq	.done
	cmp.w	#$1682,d0	; dont active on safe zones
	beq	.done	
	PlaySound Whoosh
	bsr	HideArrowPickup
	move.w	#0,hasArrowPickup
	jsr	SpriteEnableAuto
	bra	.done
.done:
	rts
	

FlashItem:	macro
	move.w	has\1Pickup,d0
	cmp.w	#PICKUP_NUM_FLASHES,d0
	beq	.\@skip
	cmp.w	#0,d0
	beq	.\@skip
	btst	#0,d0
	bne	.\@on
	bsr	Hide\1Pickup
	bra	.\@done
.\@on:
	bsr	Show\1Pickup
.\@done:
	add.w	#1,has\1Pickup
.\@skip
	endm
	
FlashPickup:
	cmp.w	#0,flashCount
	bgt	.skip
	move.w	#8,flashCount

	FlashItem Arrow
	FlashItem Clock
	FlashItem Eye	
.skip:
	sub.w	#1,flashCount
	rts
	
	
PickupItem: macro
	PlaySound Whoosh
	cmp.w	#0,has\1Pickup
	beq	.\@doPickup
	jsr	\2
	bra	.\@done
.\@doPickup:	
	bsr	Show\1Pickup
	move.w	#1,has\1Pickup
.\@done:
	endm

PickupClock:
	PickupItem Clock,FreezeScrolling
	rts

PickupEye:
	PickupItem Eye,RevealPathway
	rts
	
PickupArrow:	
	PickupItem Arrow,SpriteEnableAuto
	rts
	
ShowEyePickup:
	move.w	#0,d0
	move.w	#0,d1
	bsr	BlitPickup
	rts

HideEyePickup:
	move.w	#0,d0
	move.w	#1,d1
	bsr	BlitPickup
	rts
	
ShowClockPickup:
	move.w	#1,d0
	move.w	#0,d1
	bsr	BlitPickup
	rts

HideClockPickup:
	move.w	#1,d0
	move.w	#1,d1
	bsr	BlitPickup
	rts

ShowArrowPickup:
	move.w	#2,d0
	move.w	#0,d1
	bsr	BlitPickup
	rts

HideArrowPickup:
	move.w	#2,d0
	move.w	#1,d1
	bsr	BlitPickup
	rts		


BlitPickup:
	WaitBlitter	
	;; d0.w	pickup index
	;; 0 - eye, 1 - clock, 2 - arrow, 3 - blank
	;; d1.w	blank
	;; 0 - not blank, 1 - blank
	move.w 	#BC0F_SRCA|BC0F_DEST|$f0,BLTCON0(a6)
	lea	pickups,a0	
	move.l	#panel+PICKUP_OFFSET,a1	
	lsl.w	#1,d0
	cmp.w	#0,d1
	adda.w	d0,a1	
	beq	.notBlank
	move.w	#48/8,d0
.notBlank:
	adda.w	d0,a0
	move.w 	#0,BLTCON1(a6) 
	move.w 	#$ffff,BLTALWM(a6)
	move.w 	#$ffff,BLTAFWM(a6)
	move.w 	#(64-16)/8,BLTAMOD(a6)
	move.w 	#SCREEN_WIDTH_BYTES-2,BLTDMOD(a6)
	move.l 	a0,BLTAPTH(a6)	;source graphic top left corner
	move.l  a1,BLTDPTH(a6) ;destination top left corner	
	move.w 	#(14*PANEL_BIT_DEPTH)<<6|(1),BLTSIZE(a6)
	rts

hasClockPickup:
	dc.w	0
hasEyePickup:
	dc.w	0
hasArrowPickup:
	dc.w	0	
lastPickupFrameCount:
	dc.l	0
flashCount:
	dc.w	0

revealMessageText:
	dc.b	"SHOW ME THE BOARD!"
	dc.b	0
	align 4
pickups:
	incbin "out/pickups.bin"
