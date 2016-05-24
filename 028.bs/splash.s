	include "includes.i"

	xdef	ShowSplash
	xdef	splash
	
SPLASH_COLOR_DEPTH		equ 5
SPLASH_SCREEN_WIDTH_BYTES	equ 40

ReloadSplashScreen:
	move.l	#endDiskSplash-diskSplash,d0
	move.l	#splash,a0
	move.l	#diskSplash,a1	
	jsr	LoadDiskData
	rts
	
ShowSplash:
	lea 	CUSTOM,a6
	
	;; set up playfield
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a6)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a6)

	move.w	#(RASTER_X_START/2-SCREEN_RES),DDFSTRT(a6)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a6)
	
	move.w	#(SPLASH_COLOR_DEPTH<<12)|$200,BPLCON0(a6)
	move.w	#SPLASH_SCREEN_WIDTH_BYTES*SPLASH_COLOR_DEPTH-SPLASH_SCREEN_WIDTH_BYTES,BPL1MOD(a6)
	move.w	#SPLASH_SCREEN_WIDTH_BYTES*SPLASH_COLOR_DEPTH-SPLASH_SCREEN_WIDTH_BYTES,BPL2MOD(a6)

	bsr	ReloadSplashScreen
	
	;; poke bitplane pointers
	lea	splash,a1
	lea     splashCopperListBplPtr(pc),a2
	moveq	#SPLASH_COLOR_DEPTH-1,d0
.bitplaneloop:
	move.l 	a1,d1
	move.w	d1,2(a2)
	swap	d1
	move.w  d1,6(a2)
	lea	SPLASH_SCREEN_WIDTH_BYTES(a1),a1 ; bit plane data is interleaved
	addq	#8,a2
	dbra	d0,.bitplaneloop

	;; install copper list, then enable dma
	lea	splashCopperList(pc),a0
	move.l	a0,COP1LC(a6)

	jsr	WaitVerticalBlank	
	;; set up default palette
	include "out/splash-palette.s"

	lea COLOR31(a6),a0
	move.w #$f00,(a0)	
	
	jsr	WaitVerticalBlank			
	move.w	#(DMAF_BLITTER|DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)		
	move.w	#(INTF_SETCLR|INTF_VERTB|INTF_INTEN),INTENA(a6)	

.wait:
	jsr	WaitVerticalBlank
	jsr	WaitForJoystick
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
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0
	dc.l	$fffffffe		


	section	.bss
splash:
	ds.b	endDiskSplash-diskSplash
	cnop	0,1024
	
	section	.noload
diskSplash:
	incbin "out/splash.bin"
endDiskSplash:
	cnop	0,512	