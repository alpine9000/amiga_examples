	include "../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH		equ 320
SCREEN_HEIGHT		equ 256
SCREEN_WIDTH_BYTES	equ (SCREEN_WIDTH/8)
SCREEN_BIT_DEPTH	equ 5
SCREEN_RES		equ 8 	; 8=lo resolution, 4=hi resolution
RASTER_X_START		equ $81	; hard coded coordinates from hardware manual
RASTER_Y_START		equ $2c
RASTER_X_STOP		equ RASTER_X_START+SCREEN_WIDTH
RASTER_Y_STOP		equ RASTER_Y_START+SCREEN_HEIGHT

	
entry:
	;; custom chip base globally in a6
	lea 	CUSTOM,a6

	move	#$7ff,DMACON(a6)	; disable all dma
	move	#$7fff,INTENA(a6)	; disable all interrupts

	include "out/image-palette.s"
	if 0
	;; reset color registers to white to prevent startup flicker
	move.l	#32,d0
	lea	COLOR00(a6),a0
.loop:
	move.w	#$FFF,(a0)
	addq	#2,a0
	dbra	d0,.loop
	endif
	
	;; set up playfield
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a6)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a6)

	move.w	#(RASTER_X_START/2-SCREEN_RES),DDFSTRT(a6)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a6)
	
	move.w	#(SCREEN_BIT_DEPTH<<12)|$200,BPLCON0(a6)
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL1MOD(a6)
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL2MOD(a6)

	;; poke bitplane pointers
	lea	bitplanes(pc),a1
	lea     copper(pc),a2
	moveq	#SCREEN_BIT_DEPTH-1,d0
.bitplaneloop:
	move.l 	a1,d1
	move.w	d1,2(a2)
	swap	d1
	move.w  d1,6(a2)
	lea	SCREEN_WIDTH_BYTES(a1),a1 ; bit plane data is interleaved
	addq	#8,a2
	dbra	d0,.bitplaneloop

	;; install copper list, then enable dma and selected interrupts
	lea	copper(pc),a0
	move.l	a0,COP1LC(a6)
 	move.w  COPJMP1(a6),d0
	move.w	#(DMAF_BLITTER|DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)
	move.w	#(INTF_SETCLR|INTF_INTEN|INTF_EXTER),INTENA(a6)


	moveq	#32,d0
	moveq 	#32,d1	
	
.mainLoop:
	bsr.s	waitvbl
	bsr.s 	doblit
	addq	#1,d0
	cmp.l	#SCREEN_WIDTH-BOB_WIDTH,d0
	bne.s	.skip
	moveq	#0,d0
.skip:	
	bra.s	.mainLoop

waitvbl:
	movem.l d0-a6,-(sp)
.loop	move.l	$dff004,d0
	and.l	#$1ff00,d0
	cmp.l	#303<<8,d0
	bne.b	.loop
	movem.l (sp)+,d0-a6
	rts	

blitWait:
	tst DMACONR(a6)		;for compatibility
.waitblit:
	btst #6,DMACONR(a6)
	bne.s .waitblit
	rts

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


BOB_WIDTH 		equ 64+16 ; Must blit extra word to allow shifting
BOB_HEIGHT		equ 64
BOB_WIDTH_BYTES		equ BOB_WIDTH/8
BOB_WIDTH_WORDS		equ BOB_WIDTH/16
;; BOB_XPOS		equ 16
;; BOB_YPOS		equ 16	
;; BOB_XPOS_BYTES		equ (BOB_XPOS)/8	


doblit:	; d0 xpos, d1 xpoy
	movem.l d0-a6,-(sp)
	bsr blitWait

	;; d0 = BOB_XPOS
	;; d1 = BOB_YPOS
	;; d4 = BOB_XPOS_BYTES

	move.l	d0,d2		; d2 = BOB_XPOS
	move.l	d0,d3		; d3 = BOB_XPOS
	lsr.l	#3,d3		; d3 = BOB_XPOS_BYTES
	move.l	d3,d4		; d4 = BOB_XPOS_BYTES
	move.l	d0,d5
	lsr.l	#4,d5		; d5 = BOB_XPOS_WORDS
	lsl.l	#4,d5		; d5 = BOB_XPOS_WORDS_PIXELS
	sub.l	d5,d2		; d2 = num pixels to shift
	;;move.w #BLIT_A_SOURCE_SHIFT,d2
	lsl.w	#8,d2
	lsl.w	#4,d2 		; BLIT_A_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT

	move.w	d2,BLTCON1(A6)
	ori.w   #BLIT_SRCA|BLIT_SRCB|BLIT_SRCC|BLIT_DEST|BLIT_LF_MINTERM,d2
	move.w	d2,BLTCON0(A6)


	
BLIT_A_SOURCE_SHIFT	equ 8
	
	
	;; 	move.w	#(BLIT_SRCA|BLIT_SRCB|BLIT_SRCC|BLIT_DEST|BLIT_LF_MINTERM|BLIT_A_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT),BLTCON0(A6)
	;; 	move.w	#BLIT_A_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT,BLTCON1(a6)  ; BLTCON1 = BLIT_A_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT
	
	move.w	#$ffff,BLTAFWM(a6)	; no mask for first word
	move.w	#$0000,BLTALWM(a6) 	; mask out last word
	move.w	#-2,BLTAMOD(a6)	      	; negative 2 byte modulo to account for extra blitted word
	move.w	#-2,BLTBMOD(a6)	      	; negative 2 byte modulo to account for extra blitted word
	move.w 	#SCREEN_WIDTH_BYTES-BOB_WIDTH_BYTES,BLTCMOD(a6)	;C modulo
	move.w 	#SCREEN_WIDTH_BYTES-BOB_WIDTH_BYTES,BLTDMOD(a6)	;D modulo
	move.l 	#emojiMask,BLTAPTH(a6)	; mask bitplane
	move.l 	#emoji,BLTBPTH(a6)	; bob bitplane

	move.l	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH,d3	; d3 = SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH
	mulu.w	d1,d3					; d3 = BOB_YPOS*SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH
	move.l 	#bitplanes,d2				; d2 = #bitplanes
	add.l 	d4,d2					; d2 = #bitplanes+BOB_XPOS_BYTES
	add.l	d3,d2					; d2 = #bitplanes+BOB_XPOS_BYTES+(BOB_YPOS*SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH)
	move.l 	d2,BLTCPTH(a6) ;background top left corner
	move.l 	d2,BLTDPTH(a6) ;destination top left corner

	move.w 	#(BOB_HEIGHT*SCREEN_BIT_DEPTH)<<6|(BOB_WIDTH_WORDS),BLTSIZE(a6)	;rectangle size, starts blit
	movem.l (sp)+,d0-a6
	rts
	
copper:
	;; bitplane pointers must be first else poking addresses will be incorrect
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0

	dc.l	$fffffffe	

bitplanes:
	incbin	"out/image.bin"

emoji:
	incbin	"out/emoji.bin"

emojiMask:	
	incbin	"out/emoji-mask.bin"