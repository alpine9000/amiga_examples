	include "includes.i"
	xdef	PlaySound
	xdef	PlayFalling	
	
PlaySound:
	LEA     jump(pc),a1 ;Address of data to
        MOVE.L  a1,AUD3LCH(a6) ;The 680x0 writes this as though it were a
        MOVE.W  #123,AUD3PER(a6)
        MOVE.W  #64,AUD3VOL(a6) ;Use maximum volume
	MOVE.W  #(endJump-jump)/2,AUD3LEN(a6) ;Set length in words
	move.w	#(DMAF_AUD3|DMAF_SETCLR),DMACON(a6)

	if 0
	move.l	#1000,d0
.loop:
	dbra	d0,.loop
	
	MOVE.W  #2,AUD3LEN(a6) ;Set length in words
	move.l	#jump,AUD3LCH(a6)
	endif
	rts


PlayFalling:
	LEA     falling(pc),a1 ;Address of data to
        MOVE.L  a1,AUD3LCH(a6) ;The 680x0 writes this as though it were a
        MOVE.W  #256,AUD3PER(a6)
        MOVE.W  #25,AUD3VOL(a6) ;Use maximum volume
	MOVE.W  #(endFalling-falling)/4,AUD3LEN(a6) ;Set length in words
	move.w	#(DMAF_AUD3|DMAF_SETCLR),DMACON(a6)
	rts	

	align	4
jump:
	incbin	"out/jump.raw"
endJump:	
	align	4
falling:
	incbin	"out/falling.raw"
endFalling: