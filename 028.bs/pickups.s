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
PICKUP_DEBOUNCE_FRAMES	equ     10

PICKUP_SAFE_TILE1	equ	$f02
PICKUP_SAFE_TILE2	equ	$1682


ResetPickupItem:	macro
	move.w	#0,pickup\1FlashCounter
	cmp.w	#0,has\1Pickup
	beq	.\@skip
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
	move.w	#0,pickupEyeFlashCounter
	move.w	#0,pickupArrowFlashCounter
	move.w	#0,pickupClockFlashCounter		
	bsr	HideEyePickup
	bsr	HideArrowPickup
	bsr	HideClockPickup
	rts
	

UsePickup:
	move.l	frameCount,d0
	sub.l	lastPickupFrameCount,d0
	cmp.l	#PICKUP_DEBOUNCE_FRAMES,d0
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
	move.w	#PICKUP_NUM_FLASHES,pickupEyeFlashCounter	
	jsr	RevealPathway
	bra	.done
.useClock:
	PlaySound Whoosh
	bsr	HideClockPickup
	move.w	#0,hasClockPickup
	move.w	#PICKUP_NUM_FLASHES,pickupClockFlashCounter	
	jsr	FreezeScrolling
	bra	.done
.useArrow:
	move.l	foregroundPlayerTileAddress,a0
	cmp.w	#0,a0
	beq	.done
	move.w	(a0),d0
	cmp.w	#PICKUP_SAFE_TILE1,d0	; dont active on safe columns
	beq	.done
	cmp.w	#PICKUP_SAFE_TILE2,d0	; dont active on safe zones
	beq	.done	
	PlaySound Whoosh
	move.w	#0,hasArrowPickup
	move.w	#PICKUP_NUM_FLASHES,pickupArrowFlashCounter
	jsr	SpriteEnableAuto
	bra	.done
.done:
	rts


FlashItem:	macro
	move.w	pickup\1FlashCounter,d0
	cmp.w	#0,d0
	beq	.\@skip
	cmp.w	#1,d0
	bgt	.\@continue
	cmp.w	#0,has\1Pickup
	bne	.\@has
	bsr	Hide\1Pickup
	bra	.\@done
.\@has:
	bsr	Show\1Pickup
	bra	.\@done
.\@continue:
	btst	#0,d0
	bne	.\@on
	bsr	Hide\1Pickup
	bra	.\@done
.\@on:
	bsr	Show\1Pickup
.\@done:
	sub.w	#1,pickup\1FlashCounter
.\@skip:
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
	move.w	#PICKUP_NUM_FLASHES,pickup\1FlashCounter
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
pickupArrowFlashCounter:
	dc.w	0
pickupEyeFlashCounter:
	dc.w	0
pickupClockFlashCounter:
	dc.w	0	
lastPickupFrameCount:
	dc.l	0
flashCount:
	dc.w	0

pickups:
	incbin "out/pickups.bin"
