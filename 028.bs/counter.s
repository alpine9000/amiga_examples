	xdef	RenderCounter
	xdef	ResetCounter
	xdef	IncrementCounter
	xdef	DecrementCounter
	xdef    RenderNumber5
	xdef    RenderNumber4	
	
RenderCounter:
	;; d0.w x position
	;; a1.l	text
	lea	panel,a0
	move.w	#20,d1
	jsr	DrawText8
	rts

RenderNumber4:
	;; d0.l	number
	;; d1.w x position
	move.l	d1,d3
	move.l	#4,d2
	bsr	ToAscii
	move.l	a0,a1
	lea	panel,a0
	move.w	#20,d1
	move.w	d3,d0
	jsr	DrawText8
	rts

RenderNumber5:
	;; d0.l	number
	;; d1.w x position
	move.l	d1,d3
	move.l	#5,d2
	bsr	ToAscii
	move.l	a0,a1
	lea	panel,a0
	move.w	#20,d1
	move.w	d3,d0
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


	
ToAscii:
	;; d0.l number
	;; d2.l numb chars
	;; a0.l buffer
	;; 	movem.l d0-d2/a1,-(a7)
	lea	staticBuffer,a0
	move.l	a0,a1
	add.l	d2,a0
	move.b	#0,(a0)
	moveq #10,d2
.loop:
	divu.w	d2,d0
	swap	d0
	addi.b	#"0",d0
	move.b	d0,-(a0)
	move.b	#0,d0
	swap	d0
	tst.w	d0
	bne.s	.loop
.loop2:
	cmp.l	a0,a1
	beq	.done
	move.b	#'0',-(a0)
	bra	.loop2
.done:
	;; movem.l (a7)+,d0-d2/a1
	rts

staticBuffer:
	dc.b	"00000"
	dc.b	0

