*** MFMLoader.S by Photon ***	;requires a6=$dff002

	xdef 	LoadMFMB

MFMsync		equ	$4489		;AmigaDOS standard sync marker.
MFMlen		equ	12980		;Legacy trackdata read length in bytes	
	
ShortWt:MACRO				;CPU-independent nop;nop replacement
	tst.w 	(a6)
	ENDM

MFMcyl:		dc.w 0
MFMhead:	dc.w 0
MFMdrv:		dc.w 0
MFMchk:		dc.l 0

LoadMFMB:		;loadsectors.a0=dst,d0=startsec.W,d1=nrsecs.W(-=Step0)
	MOVEM.L	D0-D7/A0-A6,-(SP)
	lea	$bfd100,a4
	bsr	MotorOn
	tst.w	d1			;if neg length,then Step0 first
	bpl.s	.NoSt0
	neg.w	d1
.St0:	btst	#4,$f01(a4)		;head on cyl 0?
	beq.s	.Rdy0
	bsr.s	StepOut
	bra.s	.St0
.Rdy0:	lea	MFMcyl(PC),a1
	clr.w	(a1)
.NoSt0:	and.l	#$ffff,d0
	divu	#22,d0			;startcyl
	sub.w	MFMcyl(PC),d0		;delta-step
	beq.s	.StRdy
	bmi.s	.StOut
	subq.w	#1,d0
.StIn:	bsr.s	StepIn
	dbf	d0,.StIn
	bra.s	.StRdy
	not.w	d0			;=neg+sub#1
.StOut:	bsr.s	StepOut
	dbf	d0,.StIn
.StRdy:	swap	d0			;startsec within cyl
	cmp.w	#11,d0
	blt.s	.Head0
	sub.w	#11,d0
	bra.s	.Head1
.Head0:	bset	#2,(a4)
	lea	MFMhead(PC),a1
	clr.w	(a1)
	bsr	LoadTrak		;read track+decode
	beq.s	.End
.Head1:	bclr	#2,(a4)			;Head 1
	lea	MFMhead(PC),a1
	move.w	#1,(a1)
	bsr	LoadTrak		;read track+decode
	beq.s	.End
	bsr.s	StepIn			;1 cyl forward
	bra.s	.Head0
.End:	bsr.s	MotorOff
	MOVEM.L	(SP)+,D0-D7/A0-A6
	RTS

StepOut:
	bset	#1,(a4)
	lea	MFMcyl(PC),a1
	subq.w	#1,(a1)
	ShortWt
	bclr	#0,(a4)
	ShortWt
	bset	#0,(a4)
	bsr.s	StepWt
	RTS

StepIn:
	bclr	#1,(a4)
	lea	MFMcyl(PC),a1
	addq.w	#1,(a1)
	ShortWt
	bclr	#0,(a4)
	ShortWt
	bset	#0,(a4)
	bsr.s	StepWt
	RTS

StepWt:
	moveq	#67,d6			;wait >3 ms
LeaveLine:
.loop1:	move.b	6-2(a6),d7
.loop2:	cmp.b	6-2(a6),d7
	beq.s	.loop2
	dbf	d6,.loop1
	RTS

MotorOn:
	move.w	MFMdrv(PC),d7
	addq.w	#3,d7
	or.b	#$78,(a4)
	bset	d7,(a4)
	ShortWt
	bclr	#7,(a4)			;turns motor on
	ShortWt
	bclr	d7,(a4)
	ShortWt
.DiskR:	btst	#5,$f01(a4)		;wait until motor running
	bne.s	.DiskR
	RTS

MotorOff:
	move.w	MFMdrv(PC),d7
	addq.w	#3,d7
	bset	d7,(a4)
	ShortWt
	bset	#7,(a4)
	ShortWt
	bclr	d7,(a4)
	RTS

LoadTrak:		;loadtrack+decode.a0=dst,d0=secoffs,d1=secsleft
	MOVE.W	D0,-(SP)
	MOVE.W	D1,-(SP)
	lea	MFMbuf,a1
	move.w	#2,$9c-2(a6)		;Clr Req
	move.l	a1,$20-2(a6)
	move.w	#$8210,$96-2(a6)	;DskEna
	move.w	#MFMsync,$7e-2(a6)
	move.w	#$9500,$9e-2(a6)
	move.w	#$4000,$24-2(a6)
	move.w	#$8000+MFMlen/2,$24-2(a6);DskLen(12980)+DmaEn
	move.w	#$8000+MFMlen/2,$24-2(a6);start reading MFMdata
.Wrdy:
	btst	#1,$1f-2(a6)		;wait until data read
	beq.s	.Wrdy
	move.w	d0,d2
	add.w	d1,d2			;highest sec# (d0=lowest)
	cmp.w	#11,d2
	ble.s	.NoOvr
	moveq	#11,d2
.NoOvr:	sub.w	d0,d2			;nrsecs
	move.l	#$55555555,d3		;and-const
	move.w	d2,d1
	subq.w	#1,d1			;loopctr
.FindS:	cmp.w	#MFMsync,(a1)+		;search for a sync word
	bne.s	.FindS
	cmp.b	(a1),d3			;search for 0-nibble
	bne.s	.FindS
	move.l	(a1)+,d4		;decode fmtbyte/trk#,sec#,eow#
	move.l	(a1)+,d5
	and.w	d3,d4
	and.w	d3,d5
	add.w	d4,d4
	or.w	d5,d4
	lsr.w	#8,d4			;sec#
	sub.w	d0,d4			;do we want this sec?
	bmi.s	.Skip
	cmp.w	d2,d4
	blt.s	.DeCode
.Skip:	lea	48+1024(a1),a1		;nope
	bra.s	.FindS
.DeCode:lea	40(a1),a1		;found a sec,skip unnecessary data
	move.l	a1,d6
	lea	MFMchk(PC),a1
	clr.l	(a1)
	move.l	d6,a1
	move.l	(a1)+,d6		;decode data chksum.L
	move.l	(a1)+,d5
	and.l	d3,d6
	and.l	d3,d5
	add.l	d6,d6
	or.l	d5,d6			;chksum
	lea	512(a1),a2
	add.w	d4,d4			;x512
	lsl.w	#8,d4
	lea	(a0,d4.w),a3		;dest addr for this sec
	moveq	#127,d7
.DClup:	move.l	(a1)+,d4
	move.l	(a2)+,d5
	and.l	d3,d4
	and.l	d3,d5
	eor.l	d4,d6			;EOR with checksum
	eor.l	d5,d6			;EOR with checksum
	add.l	d4,d4
	or.l	d5,d4
	move.l	d4,(a3)+
	dbf	d7,.DClup		;chksum should now be 0 if correct
	lea	MFMchk(PC),a1
	or.l	d6,(a1)			;or with track total chksum
	move.l	a2,a1
	dbf	d1,.FindS		;decode next sec
	MOVE.W	(SP)+,D1
	MOVE.W	(SP)+,D0
	move.l	MFMchk(PC),d3		;track total chksum OK?
	bne	LoadTrak		;no,retry
	moveq	#0,d0			;set to start of track
	move.w	d2,d3
	add.w	d3,d3
	lsl.w	#8,d3
	add.w	d3,a0
	sub.w	d2,d1			;sub #secs loaded
	RTS

;MFMbuf is placed here after bootblock end, $3c0.w or so when copied.
MFMbuf:	
	dcb.b	MFMlen
