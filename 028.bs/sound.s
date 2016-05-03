	include "includes.i"
	xdef	PlayJumpSound
	xdef	PlayFallingSound
	
PlayJumpSound:
	lea     jump(pc),a1
        move.l  a1,AUD3LCH(a6)
        move.w  #123,AUD3PER(a6)
        move.w  #64,AUD3VOL(a6)
	move.w  #(endJump-jump)/2,AUD3LEN(a6) ;Set length in words
	move.w	#(DMAF_AUD3|DMAF_SETCLR),DMACON(a6)
	rts


PlayFallingSound:
	lea     falling(pc),a1
        move.l  a1,AUD3LCH(a6)
        move.w  #256,AUD3PER(a6)
        move.w  #25,AUD3VOL(a6) 
	move.w  #(endFalling-falling)/4,AUD3LEN(a6) ;Set length in words
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