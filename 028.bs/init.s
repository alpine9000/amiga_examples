	include "includes.i"

	xdef Init

	;; custom chip base globally in a6
Init:
	movem.l	d0-a6,-(sp)
	
	;; set up playfield
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a6)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a6)	

	move.w	#(DMAF_BLITTER|DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)	
	movem.l (sp)+,d0-a6
	rts