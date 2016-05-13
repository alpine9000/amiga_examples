	xdef	RenderCounter
	xdef	ResetCounter
	xdef	IncrementCounter
	xdef	DecrementCounter
	
RenderCounter:
	lea	panel,a0
	move.w	#20,d1
	jsr	DrawText8
	rts


ResetCounter:
	move.l	#"0000",(a0)
	rts


IncrementCounter:
	move.l	a0,a1
	add.l	#3,a0
.loop:
	sub.l	d0,d0
	move.b	(a0),d0
	addq.b	#1,d0
	cmp.b	#'9',d0
	ble	.done
	move.b	#'0',d0
	move.b	d0,(a0)	
	sub.l	#1,a0
	cmp.l	a1,a0
	blt	.startOfText
	bra	.loop
.done:
	move.b	d0,(a0)
.startOfText:
	rts


DecrementCounter:
	move.l	a0,a1	
	add.l	#3,a0
.loop:
	sub.l	d0,d0
	move.b	(a0),d0
	cmp.b	#'0',d0
	beq	.dontWrap
	subq.b	#1,d0
	bra	.done
.dontWrap:
	move.b	#'9',d0
	move.b	d0,(a0)	
	sub.l	#1,a0
	cmp.l	a1,a0
	blt	.startOfText	
	bra	.loop
.done:
	move.b	d0,(a0)
.startOfText:
	rts	
