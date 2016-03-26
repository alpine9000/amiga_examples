	include "includes.i"
	xdef DrawText

;; BLTCON? configuration
;; http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node011C.html
;; blitter logic function minterm truth table
;; fill in D column for desired function
;;       A(mask) B(bob)  C(bg)   D(dest)
;;       -       -       -       - 
;;       0       0       0       0 
;;       0       0       1       1 
;;       0       1       0       0 
;;       0       1       1       1 
;;       1       0       0       0 
;;       1       0       1       0 
;;       1       1       0       1 
;;       1       1       1       1
;; read D column from bottom up = 11001010 = $ca
;; this is used in the LF? bits

BLIT_LF_MINTERM		equ $ca
BLIT_DEST		equ $100
BLIT_SRCC	    	equ $200
BLIT_SRCB	    	equ $400
BLIT_SRCA	    	equ $800
BLIT_ASHIFTSHIFT	equ 12   ;Bit index of ASH? bits

BLIT_BOB_WIDTH 		equ 32 ; Must blit extra word to allow shifting
BLIT_BOB_HEIGHT		equ 10
BLIT_BOB_WIDTH_BYTES	equ BLIT_BOB_WIDTH/8
BLIT_BOB_WIDTH_WORDS	equ BLIT_BOB_WIDTH/16
	
blitWait:
	tst	DMACONR(a6)		;for compatibility
.waitblit:
	btst	#6,DMACONR(a6)
	bne.s 	.waitblit
	rts

	;; blitobject
	;; d0 - xpos
	;; d1 - ypos
	;; d3 - odd character
	;; a0 - display
	;; a1 - object
	;; a2 - mask
blitText: 
	movem.l	d0-a6,-(sp)
	bsr	 blitWait

	;; d0 = XPOS
	;; d1 = YPOS
	;; d3 = odd character
	;; d4 = XPOS_BYTES

 	move.w	d0,d4	; d4 = XPOS
	lsr.w	#3,d4	; d4 = XPOS_BYTES

	cmp.b	#1,d3
	bne	.evenChar
.oddChar
	sub.w	#8,d0
	move.w	#$00FF,BLTAFWM(a6)	; no mask for first word
	move.w	#$0000,BLTALWM(a6) 	; mask out last word
	sub.l	#1,a0	
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


	move.w 	#SCREEN_WIDTH_BYTES-BLIT_BOB_WIDTH_BYTES,BLTAMOD(a6)	;A modulo
	move.w 	#SCREEN_WIDTH_BYTES-BLIT_BOB_WIDTH_BYTES,BLTBMOD(a6)	;B modulo
	
	move.w 	#SCREEN_WIDTH_BYTES-BLIT_BOB_WIDTH_BYTES,BLTCMOD(a6)	;C modulo
	move.w 	#SCREEN_WIDTH_BYTES-BLIT_BOB_WIDTH_BYTES,BLTDMOD(a6)	;D modulo

	move.l 	a2,BLTAPTH(a6)	; mask bitplane
	move.l 	a1,BLTBPTH(a6)	; bob bitplane

	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH,d3	; d3 = SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH

	mulu.w	d1,d3					; d3 = YPOS*SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH
	move.l 	a0,d0					; d0 = #bitplanes
	add.w 	d4,d0					; d0 = #bitplanes+XPOS_BYTES
	add.w	d3,d0					; d0 = #bitplanes+XPOS_BYTES+(YPOS*SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH)

	move.l 	d0,BLTCPTH(a6) ;background top left corner
	move.l 	d0,BLTDPTH(a6) ;destination top left corner

	move.w 	#(BLIT_BOB_HEIGHT*SCREEN_BIT_DEPTH)<<6|(BLIT_BOB_WIDTH_WORDS),BLTSIZE(a6)	;rectangle size, starts blit
	movem.l (sp)+,d0-a6
	rts

DrawText:
	;; a0 - bitplane
	;; a1 - text
	;; d0 - xpos
	;; d1 - ypos
	

.loop:
	clr.l	d2
	move.b	(a1)+,d2
	cmp.b	#0,d2
	beq	.done
	jsr	DrawChar
	add.l	#8,d0
	bra	.loop
.done:
	rts
	
DrawChar:
	;; d0 - xpos
	;; d1 - ypos
	;; d2 - char
	;; a0 - bitplane
	movem.l	d0-a6,-(sp)
	move.l	#'!',d4 	; fontmap offset
	sub.l	d4,d2		; index = char - '!'
	move.l	d2,d5
	lsr.l	#5,d5		; fontmap y offset
	
	move.l	d5,d4
	lsl.l	#5,d4		; start of line
	sub.l	d4,d2		;
	
	add.l	#1,d5		; temp marker first line xx	
	lea	font,a1
	lea	fontMask,a2
	mulu.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH*BLIT_BOB_HEIGHT,d5
	add.l	d5,a2
	add.l	d5,a1
	

	btst.l	#0,d2
	beq	.even
.odd:
	move.b	#1,d3
	bra	.c1
.even:	
	move.b	#0,d3
.c1

	add.l	d2,a1
	add.l	d2,a2
	jsr	blitText
	movem.l	(sp)+,d0-a6
	rts

font:
	incbin	"out/font.bin"
fontMask:
	incbin	"out/font-mask.bin"	
