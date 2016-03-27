	include "includes.i"
	xdef DrawText8

	;; This will only work for 8 pixel wide fonts
	
BLIT_LF_MINTERM		equ $ca		; cookie cut
BLIT_WIDTH_WORDS	equ 2		; blit 2 words to allow shifting
BLIT_WIDTH_BYTES	equ 4

DrawText8:
	;; a0 - bitplane
	;; a1 - text
	;; d0 - xpos
	;; d1 - ypos	
	movem.l	d0/d2/a1,-(sp)
	;; blitter config that is shared for every character
	move.w 	#SCREEN_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTAMOD(a6)	;A modulo
	move.w 	#SCREEN_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTBMOD(a6)	;B modulo	
	move.w 	#SCREEN_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTCMOD(a6)	;C modulo
	move.w 	#SCREEN_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTDMOD(a6)	;D modulo

.loop:
	move.b	(a1)+,d2	; get next character
	cmp.b	#0,d2		; 0 terminates the string
	beq	.done
	jsr	DrawChar8	; draw it
	add.w	#FONT_WIDTH,d0	; increment the x position
	bra	.loop
.done:
	movem.l	(sp)+,d0/d2/a1
	rts

DrawChar8:
	;; d0 - xpos
	;; d1 - ypos
	;; d2 - char
	;; a0 - bitplane
	movem.l	d0-d5/a0-a2,-(sp)
	move.w	#'!',d4 	; fontmap offset
	sub.w	d4,d2		; index = char - '!'
	move.w	d2,d5
	lsr.w	#5,d5		; fontmap y offset
	
	move.w	d5,d4
	lsl.w	#5,d4		; start of line
	sub.w	d4,d2		;
	
	add.w	#1,d5		; while we have a weird font image, '!' starts on second line
	lea	font,a1
	lea	fontMask,a2
	mulu.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH*FONT_HEIGHT,d5
	add.w	d5,a2
	add.w	d5,a1
	
	btst	#0,d2		; blitter does words only, so we need to know if its an odd or even character
	beq	.even		; then shift it into position with the blitter shift
.odd:
	move.b	#1,d3
	bra	.c1
.even:	
	move.b	#0,d3
.c1

	add.w	d2,a1
	add.w	d2,a2
	jsr	BlitChar8
	movem.l	(sp)+,d0-d5/a0-a2
	rts

BlitChar8:
	;; kills a0,d0,d3
	;; d0 - xpos
	;; d1 - ypos
	;; d3 - odd character = 1, even character = 0
	;; a0 - display
	;; a1 - object
	;; a2 - mask	

	jsr	WaitBlitter
	
	;; d0 = XPOS
	;; d1 = YPOS
	;; d3 = odd character
	;; d4 = XPOS_BYTES

 	move.l	d0,d4	; d4 = XPOS
	lsr.w	#3,d4	; d4 = XPOS_BYTES

	cmp.b	#1,d3
	bne	.evenChar
.oddChar
	sub.w	#8,d0
	move.w	#$00FF,BLTAFWM(a6)	; no mask for first word
	move.w	#$0000,BLTALWM(a6) 	; mask out last word
	subq	#1,a0	
	bra	.continue
.evenChar:
	move.w	#$ff00,BLTAFWM(a6)	; no mask for first word
	move.w	#$0000,BLTALWM(a6) 	; mask out last word
.continue:

	;; this shift will give us the bits to shift (bits 0-3) in bits (12-15) of d0
	lsl.w	#8,d0	; BLIT_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT
	lsl.w	#4,d0 	; BLIT_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT

	move.w	d0,BLTCON1(A6)
	ori.w   #BLIT_SRCA|BLIT_SRCB|BLIT_SRCC|BLIT_DEST|BLIT_LF_MINTERM,d0
	move.w	d0,BLTCON0(A6)

	move.l 	a2,BLTAPTH(a6)	; mask bitplane
	move.l 	a1,BLTBPTH(a6)	; bob bitplane

	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH,d3	; d3 = SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH

	mulu.w	d1,d3					; d3 = YPOS*SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH
	move.l 	a0,d0					; d0 = #bitplanes
	add.l 	d4,d0					; d0 = #bitplanes+XPOS_BYTES
	add.l	d3,d0					; d0 = #bitplanes+XPOS_BYTES+(YPOS*SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH)

	move.l 	d0,BLTCPTH(a6) ;background top left corner
	move.l 	d0,BLTDPTH(a6) ;destination top left corner

	move.w 	#(FONT_HEIGHT*SCREEN_BIT_DEPTH)<<6|(BLIT_WIDTH_WORDS),BLTSIZE(a6)	;rectangle size, starts blit
	rts

font:
	incbin	"out/font.bin"
fontMask:
	incbin	"out/font-mask.bin"	
