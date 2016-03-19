
	include "includes.i"

	xref Init
	
	;; custom chip base globally in a6
Init:
	movem.l	d0-a6,-(sp)
	move	#$7ff,DMACON(a6)	; disable all dma
	move	#$7fff,INTENA(a6) ; disable all interrupts	

	;; set up default palette
	jsr	InstallColorPalette

	if INTERLACE == 1
	;; poke the bitplane pointers for the two copper lists.
	move.l	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH,d0
	lea 	copperListAlternate,a0
	jsr	PokeBitplanePointers
	endif
	
	moveq.l	#0,d0
	lea 	copperList,a0
	jsr	PokeBitplanePointers
	
	;; set up playfield
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a6)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a6)

	move.w	#(RASTER_X_START/2-SCREEN_RES),DDFSTRT(a6)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a6)

	if HAM_MODE == 1
HAMBIT	equ HOMOD
	else
HAMBIT	equ 0
	endif
	
	if INTERLACE == 1
	move.w	#(SCREEN_BIT_DEPTH<<12)|COLOR_ON|HAMBIT|LACE,BPLCON0(a6)
	move.w	#2*SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL1MOD(a6)
	move.w	#2*SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL2MOD(a6)
	else
	move.w	#(SCREEN_BIT_DEPTH<<12)|COLOR_ON|HAMBIT,BPLCON0(a6)
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL1MOD(a6)
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL2MOD(a6)
	endif	

	;; install copper list, then enable dma and selected interrupts
	lea	copperList,a0
	move.l	a0,COP1LC(a6)
 	move.w  COPJMP1(a6),d0
	move.w	#(DMAF_BLITTER|DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)
	;; move.w	#(INTF_SETCLR|INTF_VERTB|INTF_INTEN),INTENA(a6)
	movem.l (sp)+,d0-a6
	rts