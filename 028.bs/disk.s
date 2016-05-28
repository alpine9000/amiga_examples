	xdef	LoadDiskData


LoadDiskData:
	;; a0 - destination address
	;; a1 - start address
	;; d0 - size
	movem.l	d0-a6,-(sp)
	if TRACKLOADER=1	
	lea 	$dff002,a6	; LoadMFMB uses this custom base addr

	move.l	d0,d1
	
	move.l	a1,d0
	move.l	#startCode,d2
	sub.l	d2,d0		; offset from start of this module
	lsr.l	#6,d0		; bytes -> sectors
	lsr.l	#3,d0		
	add.l	#2,d0		; offset for bootblock

	
	add.l	#512,d1
	lsr.l	#6,d1		; bytes -> sectors
	lsr.l	#3,d1
	neg.w	d1
	jsr 	LoadMFMB	; load the data!
	else

	lsr.l	#2,d0
	sub.l	#1,d0
.loop:
	move.l	(a1)+,(a0)+
	dbra	d0,.loop

	endif
	movem.l (sp)+,d0-a6


	rts
