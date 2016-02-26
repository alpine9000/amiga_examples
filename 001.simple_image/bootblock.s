 	include exec/io.i
	include lvo/exec_lib.i

bootblock:
	dc.b    "DOS",0
	dc.l    0
	dc.l    880

bootEntry:
	;;  a6 = Exec base
	;;  a1 = trackdisk.device I/O request pointer

	lea     $70000,a5 ; main.s entry point 

	;; Load the progam from the floppy using trackdisk.device
	move.l  #mainEnd-mainStart,IO_LENGTH(a1)
	move.l  a5,IO_DATA(a1)
	move.l  #mainStart-bootblock,IO_OFFSET(a1)	
	jsr     _LVODoIO(a6) 
	
	jmp     (a5)	; -> main.s entry point
	
	;; Pad the remainder of the bootblock
	cnop    0,1024

mainStart:
	incbin  "out/main.bin"
	cnop    0,512
mainEnd:
	end