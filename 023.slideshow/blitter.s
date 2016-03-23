	include "exec/types.i"
	include "hardware/custom.i"
	include "hardware/dmabits.i"
	include "hardware/blit.i"
	include "../include/registers.i"

	xdef	ClearMemory
	xdef	WaitBlitter

WaitBlitter:
	        btst.b  #DMAB_BLTDONE-8,DMACONR(a1)
.wait:
	        btst.b  #DMAB_BLTDONE-8,DMACONR(a1)
	        bne     .wait
	        rts
	
	;;
	;;    This routine uses a side effect in the blitter.  When each
	;;    of the blits is finished, the pointer in the blitter is pointing
	;;    to the next word to be blitted.
	;;
	;;    When this routine returns, the last blit is started and might
	;;    not be finished, so be sure to call waitblit above before
	;;    assuming the data is clear.
	;;
	;;    a0 = pointer to first word to clear
	;;    d0 = number of bytes to clear (must be even)
	;;

ClearMemory:
	        move.l  CUSTOM,a1     ; Get pointer to chip registers
	        bsr     WaitBlitter   ; Make sure previous blit is done
	        move.l  a0,BLTDPT(a1) ; Set up the D pointer to the region to clear
	        clr.w   BLTDMOD(a1)   ; Clear the D modulo (don't skip no bytes)
	        asr.l   #1,d0	      ; Get number of words from number of bytes
	        clr.w   BLTCON1(a1)   ; No special modes
	        move.w  #DEST,BLTCON0(a1) ; only enable destination
	;;
	;;    First we deal with the smaller blits
	;;
	        moveq   #$3f,d1	; Mask out mod 64 words
	        and.w   d0,d1
	        beq     dorest	; none?  good, do one blit
	        sub.l   d1,d0	; otherwise remove remainder
	        or.l    #$40,d1	; set the height to 1, width to n
	        move.w  d1,BLTSIZE(a1) ; trigger the blit
	;;
	;;    Here we do the rest of the words, as chunks of 128k
	;;
dorest:
	        move.w  #$ffc0,d1 	; look at some more upper bits
	        and.w   d0,d1	  	; extract 10 more bits
	        beq     dorest2	  	; any to do?
	        sub.l   d1,d0	  	; pull of the ones we're doing here
	        bsr     WaitBlitter 	; wait for prev blit to complete
	        move.w  d0,BLTSIZE(a1) 	; do another blit
dorest2:
	        swap    d0	; more?
	        beq     done	; nope.
	        clr.w   d1	; do a 1024x64 word blit (128K)
keepon:
	        bsr     WaitBlitter 	; finish up this blit
	        move.w  d1,BLTSIZE(a1) 	; and again, blit
	        subq.w  #1,d0	       	; still more?
	        bne     keepon	       	; keep on going.
done:
	        rts			; finished.  Blit still in progress.
	        end	