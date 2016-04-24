	include "includes.i"

	xdef BlitChar8

DESCENDING		equ 1
BLIT_LF_MINTERM		equ $ca		; cookie cut
BLIT_WIDTH_WORDS	equ 1		; blit 2 words to allow shifting
BLIT_WIDTH_BYTES	equ BLIT_WIDTH_WORDS*2
FONTMAP_WIDTH_BYTES	equ 32
_SCREEN_BIT_DEPTH	equ 4
_BITPLANE_WIDTH_BYTES	equ 320/8
MASKED_FONT		equ 1
FONT_WIDTH		equ 8
FONT_HEIGHT		equ 8
	
	if MASKED_FONT==1
BLTCON0_VALUE		equ BC0F_SRCA|BC0F_SRCB|BC0F_SRCC|BC0F_DEST|BLIT_LF_MINTERM
	else
BLTCON0_VALUE		equ BC0F_SRCB|BC0F_SRCC|BC0F_DEST|BLIT_LF_MINTERM
	endif
	
BlitChar8:
	;; a0 - bitplane
	;; d0 - xpos
	;; d1 - ypos	
	;; d2 - char
	movem.l	d0-d3/a0-a2,-(sp)
        mulu.w	#_BITPLANE_WIDTH_BYTES*_SCREEN_BIT_DEPTH,d1		; ypos bytes
	lea	font(pc),a1						; font pointer

	sub.w	#'!',d2		; index = char - '!'
	move.w	d2,d3	
	lsr.w	#5,d3		; char / 32 = fontmap line
	andi.w	#$1f,d2		; char index in line (char index - start of line index)	
	add.l	#1,d3		; while we have a weird font image, '!' starts on second line
	mulu.w	#FONTMAP_WIDTH_BYTES*_SCREEN_BIT_DEPTH*FONT_HEIGHT,d3 	; d3 *= #FONTMAP_WIDTH_BYTES*_SCREEN_BIT_DEPTH*FONT_HEIGHT

	add.l	#(FONT_HEIGHT*_SCREEN_BIT_DEPTH*FONTMAP_WIDTH_BYTES)-FONTMAP_WIDTH_BYTES+0,a1 ; last word - descending mode
	
	add.w	d3,a1		; add y offset in lines to font address
	add.w	d2,a1		; add offset into font
	lsr.w	#3,d0		; d0 = xpos bytes	

	add.l 	d0,a0		; dest += XPOS_BYTES
	add.l	d1,a0		; dest += YPOS_BYTES
	add.l	#(FONT_HEIGHT*_SCREEN_BIT_DEPTH*_BITPLANE_WIDTH_BYTES)-_BITPLANE_WIDTH_BYTES+0,a0 ; last word - descending mode
	
	WaitBlitter

	if MASKED_FONT==1
	move.w 	#FONTMAP_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTAMOD(a6)	; A modulo (only used for masked version)
	endif
	move.w 	#FONTMAP_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTBMOD(a6)	; B modulo
	move.w 	#_BITPLANE_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTCMOD(a6)	; C modulo
	move.w 	#_BITPLANE_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTDMOD(a6)	; D modulo
	move.w	#$ffff,BLTAFWM(a6) 					; don't mask first word
	

	btst	#0,d2					; check if odd or even char
	beq	.evenChar				;
.oddChar:
	move.w	#$00ff,BLTALWM(a6)			; select the second (odd) character in the word
	move.w	#BLTCON0_VALUE|$8000,BLTCON0(a6)
	move.w	#$8002,BLTCON1(a6)			; set the shift bits 12-15, bits 00-11 cleared
	bra	.continue
.evenChar:
	move.w	#$FF00,BLTALWM(a6)			; select the first character in the word
	move.w	#BLTCON0_VALUE,BLTCON0(a6)	
	move.w	#$2,BLTCON1(a6)				; set the shift bits 12-15, bits 00-11 cleared
.continue:

	
	move.l 	a1,BLTBPTH(a6)				; source bitplane		

	if MASKED_FONT==1
	add.l	#fontMask-font,a1
	move.l 	a1,BLTAPTH(a6)				; mask bitplane
	endif
	
	
	move.l 	a0,BLTCPTH(a6) 				; background top left corner
	move.l 	a0,BLTDPTH(a6) 				; destination top left corner

	move.w 	#(FONT_HEIGHT*_SCREEN_BIT_DEPTH)<<6|(BLIT_WIDTH_WORDS),BLTSIZE(a6)	;rectangle size, starts blit

	movem.l	(sp)+,d0-d3/a0-a2
	rts

font:
	incbin	"out/font8x8.bin"
fontMask:
	incbin	"out/font8x8-mask.bin"
