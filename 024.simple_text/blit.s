	include "includes.i"
	xdef blitObject64

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
BLIT_BOB_HEIGHT		equ 12
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
	;; a0 - display
	;; a1 - object
	;; a2 - mask
blitObject64: 
	movem.l	d0-a6,-(sp)
	bsr	 blitWait

	;; d0 = XPOS
	;; d1 = YPOS
	;; d4 = XPOS_BYTES

 	move.w	d0,d4	; d4 = XPOS
	lsr.w	#3,d4	; d4 = XPOS_BYTES

	if 1
	sub.w	#8,d0
	endif

	;; this shift will give us the bits to shift (bits 0-3) in bits (12-15) of d0
	lsl.w	#8,d0	; BLIT_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT
	lsl.w	#4,d0 	; BLIT_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT

	move.w	d0,BLTCON1(A6)
	ori.w   #BLIT_SRCA|BLIT_SRCB|BLIT_SRCC|BLIT_DEST|BLIT_LF_MINTERM,d0
	move.w	d0,BLTCON0(A6)

	if 1
	move.w	#$00FF,BLTAFWM(a6)	; no mask for first word
	move.w	#$0000,BLTALWM(a6) 	; mask out last word
	else
	move.w	#$ff00,BLTAFWM(a6)	; no mask for first word
	move.w	#$0000,BLTALWM(a6) 	; mask out last word
	endif


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
