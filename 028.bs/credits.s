	include "includes.i"
	xdef	Credits

CREDITS_COLOR_DEPTH	equ 4

FillColor:
	;; kills a0,d2,d3,d5,d5
	;; a0 - bitplane
	;; d0 - color#
	;; d1 - height
	;; d2 - ypos

	movem.l	d2-d5/a0,-(sp)
	mulu.w	#BITPLANE_WIDTH_BYTES*CREDITS_COLOR_DEPTH,d2
	add.l	d2,a0
	move.b	#0,d3				; bitplane #
.loop:
	move.w	d1,d4		
	btst	d3,d0				; is the color's bit set in this plane?
	beq	.zero
	move.w	#BC0F_DEST|$FF,d5		; yes ? all ones
	bra	.doblit
.zero
	move.w	#BC0F_DEST|$0,d5		; no ? all zeros
.doblit
	WaitBlitter
	
	move.w	#0,BLTCON1(A6)
	move.w  d5,BLTCON0(A6)
	move.w 	#BITPLANE_WIDTH_BYTES*(CREDITS_COLOR_DEPTH-1),BLTDMOD(a6)
	move.l 	a0,BLTDPTH(a6) 

	lsl.w	#6,d4	
	ori.w	#BITPLANE_WIDTH_WORDS,d4
        move.w	d4,BLTSIZE(a6)
	add.b	#1,d3
	add.w	#BITPLANE_WIDTH_BYTES,a0
	cmp.b	#CREDITS_COLOR_DEPTH,d3 		; all planes for a single line done ?	
	bne	.loop				; no ? do the next plane

	movem.l (sp)+,d2-d5/a0
	rts

Credits:

	lea	foregroundBitplanes1,a0
	move.l	#0,d0
	move.l	#256,d1
	move.l	#0,d2
	jsr	FillColor

	bsr	RenderText
	
	jsr	WaitVerticalBlank
	jsr	PlayNextSound
	;; poke bitplane pointers
	lea	foregroundBitplanes1,a1
	lea     copperListBplPtr(pc),a2
	moveq	#CREDITS_COLOR_DEPTH-1,d0
.bitplaneloop:
	move.l 	a1,d1
	move.w	d1,2(a2)
	swap	d1
	move.w  d1,6(a2)
	lea	BITPLANE_WIDTH_BYTES(a1),a1 ; bit plane data is interleaved
	addq	#8,a2
	dbra	d0,.bitplaneloop

	move.w	#(RASTER_X_START/2-SCREEN_RES)-8,DDFSTRT(a6)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a6)
	
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a6)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a6)

	move.w	#BITPLANE_WIDTH_BYTES*CREDITS_COLOR_DEPTH-SCREEN_WIDTH_BYTES-2,BPL1MOD(a6)
	move.w	#BITPLANE_WIDTH_BYTES*CREDITS_COLOR_DEPTH-SCREEN_WIDTH_BYTES-2,BPL2MOD(a6)	

	move.w	#(CREDITS_COLOR_DEPTH<<12)|$200,BPLCON0(a6)
	move.w	#0,BPLCON1(a6)	

	move.w	#0,COLOR00(a6)
	move.w	#$F00,COLOR06(a6)		
	
	;; install copper list, then enable dma
	lea	copperList(pc),a0
	move.l	a0,COP1LC(a6)	
	
	jsr	WaitForJoystick
	PlaySound Jump	
	
	rts


RenderText:
	lea	credits,a1

	move.w	#40,d0
	move.w	#20,d1	
.loop:
	cmp.b	#0,(a1)
	beq	.done
	lea	foregroundBitplanes1,a0
 	jsr	DrawWSMaskedText8
.findNull:
	cmp.b	#0,(a1)+
	bne	.findNull
	add.w	#10,d1
	bra	.loop	
.done:
	rts


credits:
	dc.b	"           BLOCKY SKIES"
	dc.b	0
	dc.b	" "
	dc.b	0	
	dc.b	"GAME DESIGN   CHIPMUNK"
	dc.b	0	
	dc.b	"   GRAPHICS   CHIPMUNK"
	dc.b	0	
	dc.b	"      MUSIC   Simone \"JMD\" Bernacchia"
	dc.b	0	
	dc.b	"       CODE   ALPINE9000"
	dc.b	0
	dc.b	"     LEVELS   CHIPMUNK & ALPINE9000"
	dc.b	0	
	dc.b	" "
	dc.b	0	
	dc.b	"             THANKS"
	dc.b	0
	dc.b	" "
	dc.b	0		
	dc.b	"TRACKLOADER   PHOTON/SCOOPEX"	
	dc.b	0	
	dc.b	" P6112 CODE   GURU & PHOTON/SCOOPEX"
	dc.b	0
	dc.b	"    WIN-UAE   TONI WILEN"
	dc.b	0
	dc.b	"     FS-UAE   Frode Solheim"
	dc.b	0
	dc.b	" VASM/VLINK   PHX & Volker"
	align	4
copperList:
copperListBplPtr:
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0
	include	"out/credits_copperlist.i"
	dc.l	$fffffffe		
	