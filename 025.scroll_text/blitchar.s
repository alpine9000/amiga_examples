	include "includes.i"
	xdef BlitChar8
	
BLIT_LF_MINTERM		equ $ca		; cookie cut
BLIT_WIDTH_WORDS	equ 2		; blit 2 words to allow shifting
BLIT_WIDTH_BYTES	equ 4
FONTMAP_WIDTH_BYTES	equ 32

BlitChar8:
	;; a0 - bitplane
	;; d0 - xpos
	;; d1 - ypos	
	;; d2 - char
	movem.l	d0-d7/a0-a4,-(sp)
	WaitBlitter

	;; blitter config that is shared for every character
	if MASKED_FONT==1
	move.w  #BLIT_SRCA|BLIT_SRCB|BLIT_SRCC|BLIT_DEST|BLIT_LF_MINTERM,d6 ; BLTCON0 value (masked version)
	move.w 	#FONTMAP_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTAMOD(a6)	; A modulo (only used for masked version)
	else
	move.w	#BLIT_SRCB|BLIT_SRCC|BLIT_DEST|BLIT_LF_MINTERM,d6 	; BLTCON0 value
	endif
	move.w 	#FONTMAP_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTBMOD(a6)	; B modulo
	move.w 	#BITPLANE_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTCMOD(a6)	; C modulo
	move.w 	#BITPLANE_WIDTH_BYTES-BLIT_WIDTH_BYTES,BLTDMOD(a6)	; D modulo
        mulu.w	#BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH,d1		; ypos bytes
	move.w	#$0000,BLTALWM(a6) 					; mask out extra word used for shifting
	move.w	#$ffff,BLTADAT(a6) 					; preload source mask so only BLTA?WM mask is used
	move.l	#font,a5						; font pointer
	move.l	#fontMask,d7						; font mask pointer
	move.w	#FONTMAP_WIDTH_BYTES*SCREEN_BIT_DEPTH*FONT_HEIGHT,d3 	; bytes per font line

	move.l	a0,a4		; bitplane pointer
	bsr	DrawChar8	; draw it

	movem.l	(sp)+,d0-d7/a0-a4
	rts

DrawChar8:
	;; kills d2,d4,d5,a1,a2,a4
	;; d0  - xpos
	;; d1  - ypos bytes
	;; d2* - char
	;; d3  - bytes per font line
	;; d6  - bltcon0 value
	;; a4* - bitplane
	;; a5  - #font
	;; d7  - #fontMask

	sub.w	#'!',d2		; index = char - '!'
	move.w	d2,d5
	
	lsr.w	#5,d5		; char / 32 = fontmap line
	andi.w	#$1f,d2		; char index in line (char index - start of line index)
	
	add.l	#1,d5		; while we have a weird font image, '!' starts on second line
	move.l	a5,a1		; #font

	if 1
	mulu.w	d3,d5 		; d5 *= #FONTMAP_WIDTH_BYTES*SCREEN_BIT_DEPTH*FONT_HEIGHT
	else
	move.w	d5,d3
	lsl.w	#7,d3		; d5 *= FONTMAP_WIDTH_BYTES*SCREEN_BIT_DEPTH
	move.w	d3,d5
	add.l	d3,d5
	add.l	d3,d5
	add.l	d3,d5
	add.l	d3,d5
	add.l	d3,d5
	add.l	d3,d5
	add.l	d3,d5
	add.l	d3,d5
	add.l	d3,d5
	endif

	if	MASKED_FONT==1
	move.l	d7,a2		; #fontMask
	add.w	d5,a2		; add y offset in lines to fontMask address
	endif

	add.w	d5,a1		; add y offset in lines to font address

	add.w	d2,a1		; add offset into font
	if MASKED_FONT==1
	add.l	d2,a2		; add offset into mask
	endif

.blitChar8:
	;; kills a4,d2,d4,d5
	;; d0 - xpos
	;; d1 - ypos bytes
	;; d2.0 - odd character = 1, even character = 0
	;; d3 - bytes per font line
	;; d6 - bltcon0 value
	;; a4 - display
	;; a1 - object
	;; a2 - mask	

 	move.l	d0,d4					; xpos
 	move.l	d0,d5					; xpos
	lsr.w	#3,d4					; d4 = xpos bytes
	
	WaitBlitter
	
	btst	#0,d2					; check if odd or even char
	beq	.evenChar				;
.oddChar
	subq	#8,d5					; offset the x position for the odd character
	move.w	#$00FF,BLTAFWM(a6)			; select the second (odd) character in the word
	subq	#1,a4					; move the destination pointer left by one byte
	bra	.continue
.evenChar:
	move.w	#$FF00,BLTAFWM(a6)			; select the first character in the word
.continue:

	;; this shift will give us the bits to shift (bits 0-3) in bits (12-15) of d5
	swap	d5					; d5 << 12
	lsr.l	#4,d5					; 
	
	move.w	d5,BLTCON1(A6)				; set the shift bits 12-15, bits 00-11 cleared

	if MASKED_FONT==1
	move.l 	a2,BLTAPTH(a6)				; mask bitplane
	endif

	move.l 	a1,BLTBPTH(a6)				; source bitplane		
	or.w	d6,d5					; d5 = BLTCON0 value
	move.w	d5,BLTCON0(a6)				; set minterm, dma channel and shift

	add.l 	d4,a4					; dest += XPOS_BYTES
	add.l	d1,a4					; dest += YPOS_BYTES

	move.l 	a4,BLTCPTH(a6) 				; background top left corner
	move.l 	a4,BLTDPTH(a6) 				; destination top left corner

	move.w 	#(FONT_HEIGHT*SCREEN_BIT_DEPTH)<<6|(BLIT_WIDTH_WORDS),BLTSIZE(a6)	;rectangle size, starts blit
	rts

font:
	incbin	"out/font8x8.bin"
fontMask:
	incbin	"out/font8x8-mask.bin"
