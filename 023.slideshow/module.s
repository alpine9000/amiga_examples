	xdef	LoadModule

LoadModule:
	movem.l	d0-a6,-(sp)
	lea	bitplanes1,a0
	lea	compressedModule,a1
	move.l	#endCompressedModule,d0
	sub.l	#compressedModule,d0
	;; a0 - destination address
	;; a1 - start address
	;; d0 - size
	jsr	LoadDiskData

	;; a0 - input buffer to be decompressed. Must be 16-bit aligned!
	;; a1 - output buffer. Points to the end of the data at exit
	lea	bitplanes1,a0
	lea	Module,a1
	jsr	Depack
	
	movem.l (sp)+,d0-a6
	rts