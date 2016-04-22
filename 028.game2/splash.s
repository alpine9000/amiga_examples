	include "includes.i"

	xdef	ShowSplash

SPLASH_COLOR_DEPTH		equ 5
SPLASH_SCREEN_WIDTH_BYTES	equ 40


SplashPokeBitplanePointers:
	; a0 = BPLP copper list address
	; a1 = bitplanes pointer
	lea	splashCopperListBplPtr,a0
	lea	splash,a1
	moveq	#SPLASH_COLOR_DEPTH-1,d0
.bitplaneloop:
	move.l 	a1,d1
	move.w	d1,2(a0)
	swap	d1
	move.w  d1,6(a0)
	lea	SPLASH_SCREEN_WIDTH_BYTES(a1),a1
	addq	#8,a0
	dbra	d0,.bitplaneloop
	rts

	
ShowSplash:
	bsr	SplashPokeBitplanePointers
	lea 	CUSTOM,a1
	lea	splashCopperList(pc),a0
	move.l	a0,COP1LC(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
.wait:
	jsr	WaitVerticalBlank
	jsr	ProcessJoystick
	btst.b	#0,joystick
	beq	.wait
	rts


splashCopperList:
splashCopperListBplPtr:	
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
	dc.w    DIWSTRT,$2c81
	dc.w	DIWSTOP,$2cc1
	dc.w	BPLCON0,(SPLASH_COLOR_DEPTH<<12)|$200 ; set color depth and enable COLOR
	dc.w	BPL1MOD,SPLASH_SCREEN_WIDTH_BYTES*SPLASH_COLOR_DEPTH-SPLASH_SCREEN_WIDTH_BYTES
	dc.w	BPL2MOD,SPLASH_SCREEN_WIDTH_BYTES*SPLASH_COLOR_DEPTH-SPLASH_SCREEN_WIDTH_BYTES
	include "out/splash-copper-list.s"
	dc.l	$fffffffe	

splash:	
	incbin "out/splash.bin"	
