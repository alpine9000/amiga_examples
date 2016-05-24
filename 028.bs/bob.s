	include "includes.i"
	include "bob.i"
	
	xdef RenderBob
	xdef ResetBobs
	xdef RestoreBobBackgrounds
	xdef bobBufferOffset
	xdef EnableBobs

	;; BALOON_BOB/CLOUD_BOB
	;; index,y,dx
	
	;; BLITTER_OBJECT
	;; index,startX,y,dx,mapLine,blitHeight
bob:	
	BALOON_BOB 0,15,24
endBob:
	BALOON_BOB 1,150,32

	CLOUD_BOB 2,64,8
	CLOUD_BOB 3,170,12
	dc.l	0	
ResetBobs:
	bsr	RestoreBobBackgrounds
	eor.l	#4,bobBufferOffset
	bsr	RestoreBobBackgrounds
	eor.l	#4,bobBufferOffset
	move.w	#0,bobsEnabled
	rts
	

RestoreBobBackgrounds:
	movem.l d0/a2,-(sp)

	WaitBlitter	

	move.w	#$ffff,BLTAFWM(a6)
	move.w	#$ffff,BLTALWM(a6)
	move.w	#BC0F_SRCA|BC0F_DEST|$f0,BLTCON0(a6)
	move.w	#0,BLTCON1(a6)
	move.w 	#0,BLTAMOD(a6)
	move.w 	#BITPLANE_WIDTH_BYTES-(BOB_BLIT_WIDTH_BYTES),BLTDMOD(a6)

	lea	bob,a5
.loop:
	cmp.l	#0,(a5)
	beq	.done

	lea	BOB_LAST_DEST_ADDRESS(a5),a1
	adda.l	bobBufferOffset,a1
	cmp.l	#0,(a1)
	beq	.skip

	lea	BOB_SAVE_BUFFER_ADDRESS(a5),a2
	adda.l	bobBufferOffset,a2
	
	WaitBlitter	

	move.l 	(a2),BLTAPTH(a6) 	; source	
	move.l 	(a1),BLTDPTH(a6)	; dest
	move.w 	BOB_BLIT_SIZE(a5),BLTSIZE(a6)
	move.l	#0,(a1)
.skip:	
	
	adda.l	#endBob-bob,a5	
	bra	.loop
.done:
	movem.l	(sp)+,d0/a2
	rts
	
SaveBackground:
	;; a5.l	bob address
	;; kills a0,a2


	rts

SaveBobBackgrounds:
	WaitBlitter		
	move.w	#$ffff,BLTAFWM(a6)
	move.w	#$ffff,BLTALWM(a6)
	move.w	#BC0F_SRCA|BC0F_DEST|$f0,BLTCON0(a6)
	move.w	#0,BLTCON1(a6)	
	move.w 	#BITPLANE_WIDTH_BYTES-(BOB_BLIT_WIDTH_BYTES),BLTAMOD(a6)	
	move.w 	#0,BLTDMOD(a6)


	lea	bob,a5	
.loop:
	cmp.l	#0,(a5)
	beq	.done	

	move.l	BOB_X(a5),d2
	sub.l	BOB_DX(a5),d2
	cmp.l	#-32<<BOB_SHIFT_CONVERT,d2
	bgt	.dontReset
	move.l	#320<<BOB_SHIFT_CONVERT,d2
.dontReset:
	move.l	d2,BOB_X(a5)
	add.l	backgroundScrollX,d2

	move.l	d2,d0
	lsr.w	#BOB_SHIFT_CONVERT,d0 ; convert to pixels	
	lsr.w   #3,d0		      ; bytes to scroll

	move.l	backgroundOffscreen,a0
	add.l	d0,a0

	move.l	BOB_Y(a5),d1
	mulu.w	#BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH,d1
	adda.w	d1,a0	
	
	lea	BOB_SAVE_BUFFER_ADDRESS(a5),a2
	adda.l	bobBufferOffset,a2

	WaitBlitter	
	move.l 	a0,BLTAPTH(a6) 		; source	
	move.l 	(a2),BLTDPTH(a6)	; dest
	move.w 	BOB_BLIT_SIZE(a5),BLTSIZE(a6)	
	
	lea	BOB_LAST_DEST_ADDRESS(a5),a2
	adda.l	bobBufferOffset,a2
	
	move.l	a0,(a2)	
	
	adda.l	#endBob-bob,a5
	bra	.loop
.done:
	rts
	
RenderBob:
	cmp.w	#0,bobsEnabled
	beq	.dontRenderBobs
	movem.l	d0-a5,-(sp)

	bsr	 SaveBobBackgrounds

	WaitBlitter	
	;; move.w 	#(48/8)-BOB_BLIT_WIDTH_BYTES,BLTAMOD(a6)	; mask
	move.w 	#BACKGROUND_TILEMAP_WIDTH_BYTES-BOB_BLIT_WIDTH_BYTES,BLTAMOD(a6)	; mask			
	move.w 	#BOB_MODULO,BLTBMOD(a6) ; bob
	move.w 	#BITPLANE_WIDTH_BYTES-BOB_BLIT_WIDTH_BYTES,BLTCMOD(a6)	    ; background	
	move.w 	#BITPLANE_WIDTH_BYTES-BOB_BLIT_WIDTH_BYTES,BLTDMOD(a6)	    ; dest
	move.w	#$ffff,BLTAFWM(a6)
	move.w	#$0000,BLTALWM(a6)
	
	lea	bob,a5	
.loop:
	cmp.l	#0,(a5)
	beq	.done
	move.l	BOB_X(a5),d2
	add.l	backgroundScrollX,d2
	
	lea	BOB_LAST_DEST_ADDRESS(a5),a0
	adda.l	bobBufferOffset,a0
	move.l	(a0),a0
	
	move.l	d2,d0
	;; lsr.w	#BOB_SHIFT_CONVERT,d0 ; convert to pixels	
	lsl.w	#8,d0	; BLIT_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT
	;; 	lsl.w	#4,d0 	; BLIT_SOURCE_SHIFT<<BLIT_ASHIFTSHIFT
	
	WaitBlitter
	move.w	d0,BLTCON1(A6)
	ori.w   #BC0F_SRCA|BC0F_SRCB|BC0F_SRCC|BC0F_DEST|$ca,d0
	move.w	d0,BLTCON0(a6)
	;;       A(mask) B(bob)  C(bg)   D(dest)
	
	move.l 	BOB_MASK_ADDRESS(a5),BLTAPTH(a6)	; mask
	move.l	BOB_SOURCE_ADDRESS(a5),BLTBPTH(a6) 		; bob
	move.l 	a0,BLTCPTH(a6)		; bg
	move.l 	a0,BLTDPTH(a6)		; dest
	move.w 	BOB_BLIT_SIZE(a5),BLTSIZE(a6)	;rectangle size, starts blit
	

	adda.l	#endBob-bob,a5
	bra	.loop
.done:	
	movem.l	(sp)+,d0-a5
.dontRenderBobs:

	rts	

EnableBobs:
	move.w	#1,bobsEnabled
	rts


bobBufferOffset:
	dc.l	0 		; 0 or 4
bobsEnabled:
	dc.w	0
bobMask:
	incbin	"out/backgroundMask-mask.bin"	