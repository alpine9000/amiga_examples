	include "funcdef.i"
	include "../include/registers.i"
	include "exec/io.i"
	include "exec/exec_lib.i"
	include "devices/trackdisk.i"


bootblock:
	dc.b    "DOS",0
	dc.l    0
	dc.l    880

	
BootEntry:
	;;  a6 = exec base
	;;  a1 = trackdisk.device I/O request pointer

	if SHRINKLER==1
	lea     DECOMPRESS_ADDRESS,a5	; load shrinkler compressed data here
	else
	lea	BASE_ADDRESS,a5 	; main.s entry point
	endif
	
	;; Load the progam from the floppy using trackdisk.device

	move.l  #mainEnd-mainStart,IO_LENGTH(a1)
	move.l  a5,IO_DATA(a1)
	move.l  #mainStart-bootblock,IO_OFFSET(a1)	
	jsr     _LVODoIO(a6)

	;; Turn off drive motor
	move.l  #0,IO_LENGTH(a1)
	move.w  #TD_MOTOR,IO_COMMAND(a1)
	jsr     _LVODoIO(a6)

	if SHRINKLER==0
	jmp     (a5)			; -> main.s entry point

	else				; SHRINKER==1

	; a0 = compressed data
	lea	DECOMPRESS_ADDRESS,a0
	; a1 = decompressed data destination
	lea	BASE_ADDRESS,a1
	; a2 = progress callback, can be zero if no callback is desired.
	lea	Callback(pc),a2
	bsr 	ShrinklerDecompress 	; -> decompress!
	lea	BASE_ADDRESS,a5
	jmp     (a5)			; -> main.s entry point

	include "../tools/external/shrinkler/ShrinklerDecompress.S"

Callback:
	;; d0 = Number of bytes decompressed so far
	;; a0 = Callback argument
	move.l	a6,-(sp)
	lea 	CUSTOM,a6
	move.w  d0,COLOR00(a6)		;  Set wild background colors as we decompress
	move.l	(sp)+,a6
	rts

	endif 				; SHRINKLER==1
	
	;; Pad the remainder of the bootblock
	cnop    0,1024
	
mainStart:
	if SHRINKLER==1

	incbin  "out/shrunk.bin"

	else				; SHRINKLER==0

	incbin  "out/main.bin"

	endif				; SHRINKLER==0
	cnop    0,512
mainEnd:
	end
