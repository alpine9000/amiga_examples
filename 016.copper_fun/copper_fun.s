	include "../include/registers.i"
	include "hardware/dmabits.i"
	include "hardware/intbits.i"
	
LVL3_INT_VECTOR		equ $6c
SCREEN_WIDTH		equ 320
SCREEN_HEIGHT		equ 256
SCREEN_WIDTH_BYTES	equ (SCREEN_WIDTH/8)
SCREEN_BIT_DEPTH	equ 1
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
	
	;; set up playfield
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a6)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a6)

	move.w	#(RASTER_X_START/2-SCREEN_RES),DDFSTRT(a6)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a6)
	
	move.w	#(SCREEN_BIT_DEPTH<<12)|$200,BPLCON0(a6)
	move.w	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES,BPL1MOD(a6)
	
	;; install copper list, then enable dma and selected interrupts
	if 0
	lea	copper(pc),a0	
	move.l	a0,COP1LC(a6)
	endif
	move.w  COPJMP1(a6),d0
	move.w	#(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)
	move.w	#(INTF_SETCLR|INTF_INTEN|INTF_EXTER),INTENA(a6)

.mainLoop:
	bsr waitVerticalBlank

	lea 	bitplane(pc),a1
	lea.l	BPL1PT(a6),a0
	move.l	a1,(a0)

	move.l	counter,d0
	cmpi.l	#5,counter
	bne	.ok
	move.l	#0,counter
	move.l	copperptr,a0
	move.l	a0,COP1LC(a6)
	add.l	#size,copperptr
	move.l	copperptr,d0
	cmpi.l	#end,d0
	bne	.ok
	move.l	#copper,copperptr
.ok
	addi.l	#1,counter
	bra.b	.mainLoop

	include "utils.s"

size	equ out00003-out00001

counter:
	dc.l    0
	
copperptr:
	dc.l	out00001
bitplane:
	dcb.b   (SCREEN_WIDTH*SCREEN_HEIGHT)/8,$00
copper:
 	include "out/copper-new.s"
end:	