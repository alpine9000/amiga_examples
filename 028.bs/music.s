	xdef 	StartMusic

StartMusic:
	;; a0 - destination address
	;; a1 - start address
	;; d0 - size	

	lea	module,a0
	lea	diskmodule,a1
	move.l	#enddiskmodule-diskmodule,d0
        jsr	LoadDiskData
	lea     module,a0
        sub.l   a1,a1
        sub.l   a2,a2
        moveq   #0,d0
        jsr     P61_Init
	rts

	section	.bss
module
	ds.b	enddiskmodule-diskmodule

	section	.noload
	cnop	0,512	
diskmodule:
	if SFX=1
	incbin	"assets/P61.placeholder"
	else
	incbin	"assets/P61.song1"
	endif
	cnop	0,512
enddiskmodule:	