	;; see - docs/Howtocode5.txt

	if TRACKLOADER=0
	IFND	EXEC_EXEC_I
	include	"exec/exec.i"
	ENDC
	IFND	LIBRARIES_DOSEXTENS_I
	include	"libraries/dosextens.i"
	ENDC

_LVOForbid	EQU	-132
_LVOFindTask	EQU	-294
_LVOGetMsg	EQU	-372
_LVOReplyMsg	EQU	-378
_LVOWaitPort	EQU	-384
	
	movem.l	d0/a0,-(sp)	;save initial values
	clr.l	returnMsg

	sub.l	a1,a1
	move.l  4.w,a6
	jsr	_LVOFindTask(a6); find us
	move.l	d0,a4

	tst.l	pr_CLI(a4)
	beq.s	fromWorkbench

	;; we were called from the CLI
	movem.l	(sp)+,d0/a0	;restore regs
	bra	end_startup	;and run the user prog

	;; we were called from the Workbench
fromWorkbench:	
	lea	pr_MsgPort(a4),a0
	move.l  4.w,a6
	jsr	_LVOWaitPort(A6) ;wait for a message
	lea	pr_MsgPort(a4),a0
	jsr	_LVOGetMsg(A6)	;then get it
	move.l	d0,returnMsg	;save it for later reply

	;; do some other stuff here RSN like the command line etc
	nop

	movem.l	(sp)+,d0/a0	;restore
end_startup:	
	bsr.s	Entry		;call our program

	;; returns to here with exit code in d0
	move.l	d0,-(sp)	;save it

	tst.l	returnMsg
	beq.s	exitToDOS	;if I was a CLI

	move.l	4.w,a6
	jsr	_LVOForbid(a6)

	move.l	returnMsg(pc),a1
	jsr	_LVOReplyMsg(a6)

exitToDOS:	
	move.l	(sp)+,d0	;exit code
	rts

	;; startup code variable
returnMsg:	dc.l	0
	endif
