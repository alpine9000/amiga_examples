	idnt	"test.c"
	opt	0
	opt	NQLPSMRBT
	section	"CODE",code
	public	_blah
	cnop	0,4
_blah
	movem.l	l2,-(a7)
	moveq	#0,d0
	move.w	(6+l4,a7),d0
	move.l	#320,-(a7)
	move.l	d0,-(a7)
	public	__lmods
	jsr	__lmods
	addq.w	#8,a7
l1
l2	reg
l4	equ	0
	rts
; stacksize=8
