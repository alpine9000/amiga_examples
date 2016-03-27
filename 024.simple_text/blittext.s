	include "includes.i"
	xdef DrawText8

BLIT_LF_MINTERM		equ $ca		; cookie cut
BLIT_WIDTH_WORDS	equ 2		; blit 2 words to allow shifting
BLIT_WIDTH_BYTES	equ 4

DrawText8:
	;; a0 - bitplane
	;; a1 - text
	;; d0 - xpos
	;; d1 - ypos	
	movem.l	d0-d5/a0-a3,-(sp)
	jsr	WaitBlitter	
	;; blitter config that is shared for every character
	move.w 	#SCREEN_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTAMOD(a6)	; A modulo
	move.w 	#SCREEN_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTBMOD(a6)	; B modulo	
	move.w 	#SCREEN_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTCMOD(a6)	; C modulo
	move.w 	#SCREEN_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTDMOD(a6)	; D modulo
        mulu.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH,d1			; ypos bytes
	move.l	a1,a3
.loop:
	clr.l	d2
	move.b	(a3)+,d2	; get next character
	cmp.b	#0,d2		; 0 terminates the string
	beq	.done
	bsr	DrawChar8	; draw it
	add.w	#FONT_WIDTH,d0	; increment the x position
	bra	.loop
.done:
	movem.l	(sp)+,d0-d5/a0-a3
	rts

DrawChar8:
	;; kills d2,d3,d4,d5,a1,a2
	;; d0 - xpos
	;; d1 - ypos bytes
	;; d2 - char
	;; a0 - bitplane
	movem.l	a0,-(sp)	
	sub.w	#'!',d2		; index = char - '!'
	move.w	d2,d5
	lsr.w	#5,d5		; fontmap y offset
	
	move.w	d5,d4
	lsl.w	#5,d4		; start of line
	sub.w	d4,d2		;
	
	add.w	#1,d5		; while we have a weird font image, '!' starts on second line
	lea	font(pc),a1
	mulu.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH*FONT_HEIGHT,d5
	if	MASKED_FONT==1
	lea	fontMask,a2
	add.w	d5,a2	
	endif
	add.w	d5,a1
	
	btst	#0,d2		; blitter does words only, so we need to know if its an odd or even character
	beq	.even		; then shift it into position with the blitter shift
.odd:
	moveq	#1,d3
	bra	.c1
.even:	
	moveq	#0,d3
.c1

	add.w	d2,a1		; add offset into font
	if MASKED_FONT==1
	add.w	d2,a2		; add offset into mask
	endif

.blitChar8:
	;; kills a0,d2,d4	
	;; d0 - xpos
	;; d1 - ypos bytes
	;; d3 - odd character = 1, even character = 0
	;; a0 - display
	;; a1 - object
	;; a2 - mask	

 	move.l	d0,d4
 	move.l	d0,d2	
	lsr.w	#3,d4					; d4 = XPOS_BYTES
	
	jsr	WaitBlitter
	
	btst	#0,d3
	beq	.evenChar
.oddChar
	sub.w	#8,d2
	move.w	#$00FF,BLTAFWM(a6)			; select the second (odd) character in the word
	move.w	#$0000,BLTALWM(a6) 			; 
	subq	#1,a0	
	bra	.continue
.evenChar:
	move.w	#$FF00,BLTAFWM(a6)			; select the first character in the word
	move.w	#$0000,BLTALWM(a6) 			
.continue:

	;; this shift will give us the bits to shift (bits 0-3) in bits (12-15) of d2
	lsl.w	#8,d2					; BLIT_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT
	lsl.w	#4,d2 					; BLIT_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT
	
	move.w	d2,BLTCON1(A6)

	if MASKED_FONT==1
	ori.w   #BLIT_SRCA|BLIT_SRCB|BLIT_SRCC|BLIT_DEST|BLIT_LF_MINTERM,d2
	move.l 	a2,BLTAPTH(a6)				; mask bitplane
	else
	ori.w   #BLIT_SRCB|BLIT_SRCC|BLIT_DEST|BLIT_LF_MINTERM,d2
	move.w	#$ffff,BLTADAT(a6) 			; preload source mask so only BLTA?WM mask is used
	endif

	move.l 	a1,BLTBPTH(a6)				; source bitplane		
	move.w	d2,BLTCON0(A6)

	move.l 	a0,d2					; d2 = dest bitplane address
	add.l 	d4,d2					; d2 = += XPOS_BYTES
	add.l	d1,d2					; d2 = += YPOS_BYTES

	move.l 	d2,BLTCPTH(a6) 				; background top left corner
	move.l 	d2,BLTDPTH(a6) 				; destination top left corner

	move.w 	#(FONT_HEIGHT*SCREEN_BIT_DEPTH)<<6|(BLIT_WIDTH_WORDS),BLTSIZE(a6)	;rectangle size, starts blit
	movem.l	(sp)+,a0
	rts

font:
	incbin	"out/font.bin"
fontMask:
	incbin	"out/font-mask.bin"	
