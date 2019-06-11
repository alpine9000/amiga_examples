	;; include funcdef.i
	;; include exec/io.i
	;; include exec/exec_lib.i
	;; include devices/trackdisk.i
bootblock:
	dc.b    "DOS",0
	dc.l    0
	dc.l    880

bootEntry:
	;;  a6 = Exec base
	;;  a1 = trackdisk.device I/O request pointer

	lea     BASE_ADDRESS,a5 ; main.s entry point
	;; move.l #$ff000,a7

	;; Load the progam from the floppy using trackdisk.device

	move.l  #mainEnd-mainStart,36(a1) ;IO_LENGTH(a1)
	move.l  a5,40(a1)		  ;IO_DATA(a1)
	move.l  #mainStart-bootblock,44(a1) ;IO_OFFSET(a1)
	jsr     -456(a6) 	;DoIO

	;; Turn off drive motor
	move.l  #0,36(a1)	;IO_LENGTH(a1)
	move.w  #9,28(a1) 	;#TD_MOTOR,28(a1) ;IO_COMMAND(a1)
	jsr     -456(a6)       	;DoIO

	jmp     (a5)	; -> main.s entry point

	;; Pad the remainder of the bootblock
	cnop    0,1024

mainStart:
	incbin  "out/main.bin"
	cnop    0,512
mainEnd:
	end
