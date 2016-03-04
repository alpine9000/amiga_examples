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

BLIT_BOB_WIDTH64 		equ 64+16 ; Must blit extra word to allow shifting
BLIT_BOB_HEIGHT64		equ 64
BLIT_BOB_WIDTH64_BYTES		equ BLIT_BOB_WIDTH64/8
BLIT_BOB_WIDTH64_WORDS		equ BLIT_BOB_WIDTH64/16
	
blitWait:
	tst	DMACONR(a6)		;for compatibility
.waitblit:
	btst	#6,DMACONR(a6)
	bne.s 	.waitblit
	rts

	;; blitobject64
	;; a3 - xpos
	;; a4 - ypos
	;; a0 - display
	;; a1 - object
	;; a2 - mask
blitObject64: 
	movem.l	d0-a6,-(sp)
	
	move.l	(a3),d0
	move.l	(a4),d1
	bsr	 blitWait

	;; d0 = XPOS
	;; d1 = YPOS
	;; d4 = XPOS_BYTES

	move.l	d0,d2	; d2 = XPOS
	move.l	d0,d3	; d3 = XPOS
	lsr.l	#3,d3	; d3 = XPOS_BYTES
	move.l	d3,d4	; d4 = XPOS_BYTES
	move.l	d0,d3	; d3 = XPOS
	lsr.l	#4,d3	; d3 = XPOS_WORDS
	lsl.l	#4,d3	; d3 = XPOS_NEAREST_WORD
	sub.l	d3,d2	; d2 = num pixels to shift
	lsl.w	#8,d2	; BLIT_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT
	lsl.w	#4,d2 	; BLIT_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT

	move.w	d2,BLTCON1(A6)
	ori.w   #BLIT_SRCA|BLIT_SRCB|BLIT_SRCC|BLIT_DEST|BLIT_LF_MINTERM,d2
	move.w	d2,BLTCON0(A6)
	
	move.w	#$ffff,BLTAFWM(a6)	; no mask for first word
	move.w	#$0000,BLTALWM(a6) 	; mask out last word
	move.w	#-2,BLTAMOD(a6)	      	; negative 2 byte modulo to account for extra blitted word
	move.w	#-2,BLTBMOD(a6)	      	; negative 2 byte modulo to account for extra blitted word
	move.w 	#SCREEN_WIDTH_BYTES-BLIT_BOB_WIDTH64_BYTES,BLTCMOD(a6)	;C modulo
	move.w 	#SCREEN_WIDTH_BYTES-BLIT_BOB_WIDTH64_BYTES,BLTDMOD(a6)	;D modulo
	move.l 	a2,BLTAPTH(a6)	; mask bitplane
	move.l 	a1,BLTBPTH(a6)	; bob bitplane

	move.l	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH,d3	; d3 = SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH
	mulu.w	d1,d3					; d3 = YPOS*SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH
	move.l 	a0,d2					; d2 = #bitplanes
	add.l 	d4,d2					; d2 = #bitplanes+XPOS_BYTES
	add.l	d3,d2					; d2 = #bitplanes+XPOS_BYTES+(YPOS*SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH)
	move.l 	d2,BLTCPTH(a6) ;background top left corner
	move.l 	d2,BLTDPTH(a6) ;destination top left corner

	move.w 	#(BLIT_BOB_HEIGHT64*SCREEN_BIT_DEPTH)<<6|(BLIT_BOB_WIDTH64_WORDS),BLTSIZE(a6)	;rectangle size, starts blit
	movem.l (sp)+,d0-a6
	rts
