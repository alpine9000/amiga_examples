waitvbl:
	movem.l d0-a6,-(sp)
.loop	move.l	$dff004,d0
	and.l	#$1ff00,d0
	cmp.l	#303<<8,d0
	bne.b	.loop
	movem.l (sp)+,d0-a6
	rts	

