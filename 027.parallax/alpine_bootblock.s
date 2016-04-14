*** hardware trackloader bootblock
*** original BootLoader.S by Photon	;NOTE: PC-relative code is PREFERRED.
*** see http://coppershade.org/asmskool/SOURCES/Photon-snippets/DDE5-BootLoader.S
*** this version hacked by alpine9000	

	include "../include/registers.i"

LoaderVars	equ	$100		;Useful variables, see CPUinfo:
Loader		equ	$120		;start of load script

MyUserStack	equ	USERSTACK_ADDRESS ;SSP is at a safe place, but set user
					  ;stack.

MFMsync		equ	$4489		;AmigaDOS standard sync marker.
MFMlen		equ	12980		;Legacy trackdata read length in bytes

ShortWt:MACRO				;CPU-independent nop;nop replacement
	tst.w 	(a6)
	ENDM

    *** Boot Block starts here ***

Boot:	dc.b 	'DOS',0
	dc.l 	0,880

BootCode:	;gathers some data, turns off OS, copies itself to $100

    *--- Fetch system info ---*

	move.l 	4.w,a6			;execbase (will soon be destroyed)
	move.l 	294(a6),d4		;CPUinfo in lowest byte for your use.
	sub.l 	a4,a4			;VBR will always be 0 when booting
					;from floppy. No GetVBR needed.
    *--- Fastmem available? ---*

	if 1
	move.l	#$20004,d1		;fast+largest
	else
	move.l	#$20002,d1		;chip+largest
	endif
	jsr 	-216(a6)		;AvailMem()
	move.l 	d0,d5

	sub.l	#2048,d5		;leave room for stacks to grow
	moveq 	#4,d1
	jsr 	-198(a6)		;AllocMem()
	and.l 	#-8,d0
	move.l 	d0,a5			;Start Address
	
    *--- OS off ---*			;you're nice'n all, but now you die.

	lea 	$dff002,a6		;Loader uses this custom base addr

	tst.w 	(a6)			;wait out blitter
.wblit:	btst 	#6,(a6)
	bne.s 	.wblit

	move.l	#$7fff7fff,d1
	move.l	d1,$9a-2(a6)		;disable interrupts & req
	move.w	d1,$9c-2(a6)		;play it again Sam
	sub.w 	#$20,d1			;don't affect Sprite DMA until Vblank
	move.w 	d1,$96-2(a6)		;disable DMA

	lea 	MyUserStack,a7		;some safe place compatible with 
					;platform requirements
    *--- Copy rest of code/data to fixed address ---*

	lea 	CopyStart(PC),a0
	lea 	(LoaderVars).w,a1
	moveq 	#(BootE-CopyStart)/8,d2
.copyl:	move.l 	(a0)+,(a1)+
	move.l 	(a0)+,(a1)+
	dbf 	d2,.copyl
	JMP 	(Loader).w		;Info from Exec passed in 4 registers

********************  $100.w  ********************

CopyStart:

CPUinfo:	dc.l 0			;$100
FastMemSize:	dc.l 0			;$104
SysVBR:		dc.l 0			;$108
FastMemStart:	dc.l 0			;$10c

MFMcyl:		dc.w 0
MFMhead:	dc.w 0
MFMdrv:		dc.w 0
MFMchk:		dc.l 0

		dc.w 0			;padding to $120
		dc.w 0			;
		dc.w 0			;

LoadScript:				;At $120, sysinfo in 4 regs, a6=$dff002
	lea 	CPUinfo(PC),a3		;Use this for PC-rel in a pinch.
	movem.l d4/d5/a4/a5,(a3)
	bsr.s 	WaitEOF
	lea 	NullCop(PC),a0
	move.l 	a0,$80-2(a6)		;blank copper
	move.w 	#$87d0,$96-2(a6)	;enable DMA (sprites enabled when used)

    *--- load first part ---*

	lea	BASE_ADDRESS,a0 	; main entry point

	if 1
	moveq 	#2,d0			;from sector 2
	move.w 	#-1,d1			;num sectors, - ==Step0
	jsr 	LoadMFMB

	move.l	4(a0),d1
	add.l	#512,d1
	lsr.l	#6,d1
	lsr.l	#3,d1
	moveq 	#2,d0			;from sector 2
	jsr 	LoadMFMB
	
	lea 	$dff000,a6		;restore plain custombase addr for demo

	move.l	(a0),a0
	jmp     (a0)		; -> main entry point
	
	else

	-moveq 	#2,d0			;from sector 2
	move.w 	#-((mainEnd-mainStart)/512),d1;num sectors, - ==Step0
	jsr 	LoadMFMB
	
	jmp     (a0)		; -> main entry point

	endif

    *** MFMLoader.S by Photon ***	;requires a6=$dff002

WaitEOF:
	btst	 #0,5-2(a6)
	beq.s	 WaitEOF
.w1:	cmp.b	#$37,6-2(a6)
	bne.s	.w1
.w2:	cmp.b	#$37,6-2(a6)		;wait for last PAL line, $138
	beq.s	.w2
	rts

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
	;; 	lea	(MFMbuf).w,a1
	lea	(MFMbuf),a1
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

NullCop:
	dc.w	$1fc,0
	dc.w	$100,$0200
	dc.w	$96,$0020		;ensure sprite DMA is off until needed
	dc.w	$ffdf,$fffe
	dc.l	-2
BootE:

	*** Boot Block ends here ***

	dc.b	"BootLoader by Photon/Scoopex"
	;pad bootblock to correct size
	cnop	0,1024

;MFMbuf is placed here after bootblock end, $3c0.w or so when copied.
MFMbuf	equ	LoaderVars+(BootE-CopyStart)
MFMbufE	equ 	MFMbuf+MFMlen	;lowest free address. $372e for a full bootblock.
	
mainStart:
	incbin  "out/main.bin"
	cnop    0,512
mainEnd:	
	end

