; Copyright 1999-2015 Aske Simon Christensen. See LICENSE.txt for usage terms.

;	auto	wb\Header1\Header1_End\
;	auto	wb\Header1T\Header1T_End\
;	auto	wb\Header2\Header2_End\

INIT_ONE_PROB		=	$8000
ADJUST_SHIFT		=	4
SINGLE_BIT_CONTEXTS	=	1
NUM_CONTEXTS		=	1536
DUMMY_TEXT_LENGTH	=	0

; Exec
LIB_VERSION	=	20
Forbid		=	-132
Permit		=	-138
FreeMem		=	-210
OldOpenLibrary	=	-408
CloseLibrary	=	-414
CacheClearU	=	-636

; Dos
Write		=	-48
Output		=	-60


	align	0,4
Header1:
	move.l	a3,a4
	move.l	(a4)+,d2
	movem.l	d0/a0/a4,-(a7)
.hunk:	lsl.l	#2,d2
	move.l	a4,a5
	move.l	d2,a4
	move.l	(a4)+,d2
	bne.b	.hunk

	move.l	$4.w,a6
	jmp	(a4)

	align	0,4
Header1_End:

Header1T:
	move.l	a3,a4
	move.l	(a4)+,d2
	movem.l	d0/a0/a4,-(a7)
.hunk:	lsl.l	#2,d2
	move.l	a4,a5
	move.l	d2,a4
	move.l	(a4)+,d2
	bne.b	.hunk

TextLengthInstr:
	move.l	#DUMMY_TEXT_LENGTH,d3
	move.l	$4.w,a6
	lea.l	DosName(pc),a1
	jsr	OldOpenLibrary(a6)
	move.l	d0,a6
	jsr	Output(a6)
	move.l	d0,d1
	beq.b	.noout
	lea.l	Header1T_End(pc),a0
	move.l	a0,d2
	jsr	Write(a6)
.noout:	move.l	a6,a1
	move.l	$4.w,a6
	jsr	CloseLibrary(a6)

	jmp	(a4)

DosName:
	dc.b	"dos.library",0

	align	0,4
Header1T_End:

Header2:
	; Detach last hunk
	clr.l	-(a5)

	; Packed data Start
ContextOffsetInstr:
	lea.l	Header2_End(pc),a4

	; Init range decoder state
	moveq.l	#1,d1
	ror.l	#1,d1
	moveq.l	#1,d3
	; Lowest bit of D2 = 0

	move.l	a3,a2
HunkLoop:
	move.l	a2,a1
	addq.l	#4,a1
	; A1 = Hunk Data Destination

	moveq.l	#NUM_CONTEXTS>>4,d6
	lsl.l	#4,d6
.init:	move.w	#INIT_ONE_PROB,-(a7)
	subq.w	#1,d6
	bne.b	.init

;	moveq.l	#0,d6
.lit:
	addq.b	#1,d6
.getlit:
	bsr.b	GetBit
	addx.b	d6,d6
	bcc.b	.getlit
	move.b	d6,(a1)+
.switch:
	bsr.b	GetKind
	bcc.b	.lit
.ref:
	moveq.l	#-1,d6
	bsr.b	GetBit
	bcs.b	.sameoffset
.newref:
	moveq.l	#3,d6
	bsr.b	GetNumber
	moveq.l	#2,d5
	sub.l	d7,d5
	beq.b	.hunkend
.sameoffset:
	moveq.l	#4,d6
	bsr.b	GetNumber
.copyloop:
	move.b	(a1,d5.l),(a1)+
	subq.l	#1,d7
	bne.b	.copyloop
.afterref:
	bsr.b	GetKind
	bcc.b	.lit
	bra.b	.newref
.hunkend:

	; Relocs
	move.l	a3,d5
RelocHunk:
	addq.l	#4,d5
	move.l	a2,a1
.relocloop:
	moveq.l	#5,d6
	bsr.b	GetNumber
	add.l	d7,a1
	lsr.l	#2,d7
	beq.b	NextRelocHunk
	add.l	d5,(a1)
	bra.b	.relocloop

NextRelocHunk:
	move.l	d5,a1
	move.l	-(a1),d5
	lsl.l	#2,d5
	bne.b	RelocHunk
NextHunk:
	lea.l	NUM_CONTEXTS*2(a7),a7

	move.l	(a2),d4
	lsl.l	#2,d4
	move.l	d4,a2
	bne.b	HunkLoop
End:
	cmp.w	#37,LIB_VERSION(a6)
	blt.b	.not204
	jsr	CacheClearU(a6)
.not204:
	jsr	Forbid(a6)
	lea.l	Header2-8(pc),a1
	move.l	(a1),d0
	jsr	FreeMem(a6)
	movem.l	(a7)+,d0/a0
	jmp	Permit(a6)


GetKind:
	move.l	a1,d4
	moveq.l	#1,d6
	and.l	d4,d6
	lsl.w	#8,d6
GetBit:	bra.b	GetBitInner

GetNumber:
	; D6 = Number context

	; Out: Number in D7
	lsl.w	#8,d6
.numberloop:
	addq.b	#2,d6
	bsr.b	GetBitInner
	bcs.b	.numberloop
	moveq.l	#1,d7
	subq.b	#1,d6
.bitsloop:
	bsr.b	GetBitInner
	addx.l	d7,d7
	subq.b	#2,d6
	bcc.b	.bitsloop
	rts

	; D6 = Bit context

	; D1 = Input bit buffer
	; D2 = Range value
	; D3 = Interval size

	; Out: Bit in C and X

readbit:
	add.l	d1,d1
	bne.b	nonewword
	move.l	(a4)+,d1
	addx.l	d1,d1
nonewword:
	addx.w	d2,d2
	add.w	d3,d3
GetBitInner:
	tst.w	d3
	bpl.b	readbit

	lea.l	4+SINGLE_BIT_CONTEXTS*2(a7,d6.l),a5
	add.l	d6,a5
	move.w	(a5),d4
	; D4 = One prob

	lsr.w	#ADJUST_SHIFT,d4
	sub.w	d4,(a5)
	add.w	(a5),d4

	mulu.w	d3,d4
	swap.w	d4

	sub.w	d4,d2
	blo.b	.one
.zero:
	; oneprob = oneprob * (1 - adjust) = oneprob - oneprob * adjust
	sub.w	d4,d3
	; 0 in C and X
	rts
.one:
	; onebrob = 1 - (1 - oneprob) * (1 - adjust) = oneprob - oneprob * adjust + adjust
	add.w	#$ffff>>ADJUST_SHIFT,(a5)
	move.w	d4,d3
	add.w	d4,d2
	; 1 in C and X
	rts

	align	0,4

Header2_End:

	printv	Header1_End-Header1
	printv	Header1T_End-Header1T
	printv	Header2_End-Header2
	printt
	printv	TextLengthInstr+2-Header1T
	printv	ContextOffsetInstr+2-Header2
