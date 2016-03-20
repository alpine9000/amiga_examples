	include "../include/bplconbits.i"
	;; custom chip base globally in a6
init:
	movem.l	d0-a6,-(sp)
	move	#$7ff,DMACON(a6)	; disable all dma
	move	#$7fff,INTENA(a6) ; disable all interrupts	

	;; set up default palette
	bsr	installColorPalette

	;; poke playfield 1 bitplane pointers
	lea 	pf1_bitplanepointers(pc),a0
	lea	pf1_bitplanes(pc),a1
	bsr	pokeBitplanePointers

	;; poke playfield 2 bitplane pointers
	lea 	pf2_bitplanepointers(pc),a0
	lea	pf2_bitplanes(pc),a1
	bsr	pokeBitplanePointers	
	
	;; set up playfield
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a6)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a6)
	
	move.w	#(RASTER_X_START/2-SCREEN_RES),DDFSTRT(a6)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a6)

	;; enabled 2x the bitplanes as 2x playfields
	move.w	#((SCREEN_BIT_DEPTH*2)<<12)|COLOR_ON|DBLPF,BPLCON0(a6)
	;; set playfield2 to have priority
	move.w	#PF2PRI,BPLCON2(a6)
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL1MOD(a6)
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL2MOD(a6)

	

	;; install copper list, then enable dma and selected interrupts
	lea	copper(pc),a0
	move.l	a0,COP1LC(a6)
 	move.w  COPJMP1(a6),d0
	move.w	#(DMAF_BLITTER|DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)
	;; move.w	#(INTF_SETCLR|INTF_VERTB|INTF_INTEN),INTENA(a6)
	movem.l (sp)+,d0-a6
	rts