	include "includes.i"
	xdef DrawText8
	xdef font
	
BLIT_LF_MINTERM		equ $ca		; cookie cut
BLIT_WIDTH_WORDS	equ 2		; blit 2 words to allow shifting
BLIT_WIDTH_BYTES	equ 4
FONT_HEIGHT		equ 8
FONT_WIDTH		equ 8
FONTMAP_WIDTH_BYTES	equ 32
_SCREEN_BIT_DEPTH	equ 4
_BITPLANE_WIDTH_BYTES	equ 320/8
	
DrawText8:
	;; a0 - bitplane
	;; a1 - text
	;; d0 - xpos
	;; d1 - ypos	
	movem.l	d0-d4/a1-a4,-(sp)
	WaitBlitter

	;; blitter config that is shared for every character
	move.w	#BC0F_SRCB|BC0F_SRCC|BC0F_DEST|BLIT_LF_MINTERM,d4 	; BLTCON0 value
	move.w 	#FONTMAP_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTBMOD(a6)	; B modulo
	move.w 	#_BITPLANE_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTCMOD(a6)	; C modulo
	move.w 	#_BITPLANE_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTDMOD(a6)	; D modulo
        mulu.w	#_BITPLANE_WIDTH_BYTES*_SCREEN_BIT_DEPTH,d1		; ypos bytes
	move.w	#$0000,BLTALWM(a6) 					; mask out extra word used for shifting
	move.w	#$ffff,BLTADAT(a6) 					; preload source mask so only BLTA?WM mask is used
	move.l	a1,a3							; character pointer
	move.l	#font,a5						; font pointer
	;; move.w	#FONTMAP_WIDTH_BYTES*_SCREEN_BIT_DEPTH*FONT_HEIGHT,d3 	; bytes per font line
.loop:
	clr.l	d2
	move.b	(a3)+,d2	; get next character
	cmp.b	#0,d2		; 0 terminates the string
	beq	.done
	move.l	a0,a4		; bitplane pointer

	move.l	a5,a1		; #font
	
	sub.w	#' ',d2		; index = char - ' '
	move.w	d2,d3


	andi.w	#$1f,d2		; char index in line (char index - start of line index)	
	adda.w	d2,a1		; add offset into font	

	add.w	#1<<5,d3		; while we have a weird font image, ' ' starts on second line	
	;; lsr.w	#5,d3		; char / 32 = fontmap line
	;; lsl.w	#5,d3 		; d3 *= #FONTMAP_WIDTH_BYTES*_SCREEN_BIT_DEPTH*FONT_HEIGHT
	andi.w	#$e0,d3
	lsl.w	#5,d3
	adda.w	d3,a1		; add y offset in lines to font address

 	move.w	d0,d3					; xpos
	lsr.w	#3,d3					; d3 = xpos bytes
	adda.w 	d3,a4					; dest += XPOS_BYTES
	adda.w	d1,a4					; dest += YPOS_BYTES
	
 	move.l	d0,d3					; xpos

	WaitBlitter
	
	btst	#0,d2					; check if odd or even char
	beq	.evenChar				;
.oddChar
	subq	#8,d3					; offset the x position for the odd character
	move.w	#$00FF,BLTAFWM(a6)			; select the second (odd) character in the word
	subq	#1,a4					; move the destination pointer left by one byte
	bra	.continue
.evenChar:
	move.w	#$FF00,BLTAFWM(a6)			; select the first character in the word
.continue:

	
	;; this shift will give us the bits to shift (bits 0-3) in bits (12-15) of d3
	swap	d3					; d3 << 12
	lsr.l	#4,d3					;

	move.w	d3,BLTCON1(A6)				; set the shift bits 12-15, bits 00-11 cleared
	move.l 	a1,BLTBPTH(a6)				; source bitplane		
	or.w	d4,d3					; d3 = BLTCON0 value
	move.w	d3,BLTCON0(a6)				; set minterm, dma channel and shift
	move.l 	a4,BLTCPTH(a6) 				; background top left corner
	move.l 	a4,BLTDPTH(a6) 				; destination top left corner

	move.w 	#(FONT_HEIGHT*_SCREEN_BIT_DEPTH)<<6|(BLIT_WIDTH_WORDS),BLTSIZE(a6)	;rectangle size, starts blit	

	add.l	#FONT_WIDTH,d0	; increment the x position
	bra	.loop
.done:
	movem.l	(sp)+,d0-d4/a1-a4
	rts

DrawChar8:
	;; kills d2,d3,a1,a2,a4
	;; d0  - xpos
	;; d1  - ypos bytes
	;; d2* - char
	;; d4  - bltcon0 value
	;; a4* - bitplane
	;; a5  - #font

	rts	
font:
	incbin	"out/font8x8.bin"


