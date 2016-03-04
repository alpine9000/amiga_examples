	idnt	"test.c"
	opt	0
	opt	NQLPSMRBT
	section	"CODE",code
	public	_main
	cnop	0,4
_main
	subq.w	#8,a7
	movem.l	l2,-(a7)
	moveq	#16,d0
	move.l	d0,(0+l4,a7)
	move.l	(0+l4,a7),d0
	lsr.l	#2,d0
	move.l	d0,(4+l4,a7)
l1
l2	reg
l4	equ	0
	addq.w	#8,a7
	rts
; stacksize=8
