	include exec/io.i
	include lvo/exec_lib.i
	include devices/trackdisk.i
bootblock:
	dc.b    "DOS",0
	dc.l    0
	dc.l    880

bootEntry:
	;;  a6 = Exec base
	;;  a1 = trackdisk.device I/O request pointer

	lea     BASE_ADDRESS,a5 ; main.s entry point 

	;; Load the progam from the floppy using trackdisk.device

	move.l  #mainEnd-mainStart,IO_LENGTH(a1)
	move.l  a5,IO_DATA(a1)
	move.l  #mainStart-bootblock,IO_OFFSET(a1)	
	jsr     _LVODoIO(a6)

	;; Turn off drive motor
	move.l  #0,IO_LENGTH(a1)
	move.w  #TD_MOTOR,IO_COMMAND(a1)
	jsr     _LVODoIO(a6)
	
	jmp     (a5)	; -> main.s entry point
	
	;; Pad the remainder of the bootblock
	cnop    0,1024

mainStart:
	incbin  "out/main.bin"
	cnop    0,512
mainEnd:
	end