	xdef 	WaitVerticalBlank
	xdef	WaitRaster
	xdef	Depack
	
	
WaitVerticalBlank:	
	movem.l d0-a6,-(sp)
.loop	move.l	$dff004,d0
	and.l	#$1ff00,d0
	cmp.l	#303<<8,d0
	bne.b	.loop
	movem.l (sp)+,d0-a6
	rts	


WaitRaster:		;wait for rasterline d0.w. Modifies d0-d2/a0.
	movem.l d0-a6,-(sp)
	move.l #$1ff00,d2
	lsl.l #8,d0
	and.l d2,d0
	lea $dff004,a0
.wr:	move.l (a0),d1
	and.l d2,d1
	cmp.l d1,d0
	bne.s .wr
	movem.l (sp)+,d0-a6
	rts


Depack:
	;a0 = input buffer to be decompressed. Must be 16-bit aligned!
	;a1 = output buffer. Points to the end of the data at exit
	movem.l	d0-a6,-(sp)	
	bsr	doynaxdepack		; decompress data
	movem.l (sp)+,d0-a6
	rts

	;; this is one FAST decompression routine!
	include "../tools/external/doynamite68k/depacker_doynax.asm"


