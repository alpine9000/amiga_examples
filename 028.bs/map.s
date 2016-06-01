	include "includes.i"
	
	xdef	RenderPathway
	xdef	ClearPathway
	
RenderPathway:
	move.l	pathwayLastSafeTileAddress,d5
	;; 	add.l	#2,d5
	move.l	d5,a4
	moveq	#0,d5

	move.l	foregroundScrollX,d3
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d3		; convert to pixels
	lsr.w   #3,d3		; bytes to scroll
	move.l	foregroundOffscreen,a3
	
	bsr	BlitTileLoopSetup
.loopX:	
	moveq	#6,d6 		; y index
	moveq	#0,d7		; number of rows without a pathway
.loopY:
	move.l	pathwayMapPtr,a2
	bsr	GetMapTile
	cmp.l	a4,a2		; search for the start column
	ble	.nextX
	
	move.w	(a2),d0
	cmp.w	#0,d0
	beq	.dontBlit
	
	lea 	foregroundTilemap,a1	
	adda.w	d0,a1 	; source tile	

	move.l	a3,a0	; move.l foregroundOffscreen,a0 
	adda.w	d3,a0

	move.w	#-BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*8,d0
	move.w	d5,d4	
	add.w	d4,d4 		; mulu.w	#2,d4
	add.w	d4,d0
	add.w	#10,d0
	adda.w	d0,a0
	moveq	#10,d2
	sub.w	d6,d2
	bsr	BlitTileLoop
	bra	.next
.dontBlit:
	cmp.l	pathwayPlayerTileAddress,a2
	ble	.next
	add.w	#1,d7
	cmp.w	#7,d7
	beq	.skip
.next:
	dbra	d6,.loopY
.nextX:
	cmp.w	#(FOREGROUND_PLAYAREA_WIDTH_WORDS/2)-2,d5 ; don't render pathways off the play area
	bge	.pathwayNotComplete
	add.w	#1,d5	
	bra	.loopX
.skip:
	sub.w	#1,pathwayRenderPending	
	rts
.pathwayNotComplete:
	rts




ClearPathway:
	sub.w	#1,pathwayClearPending
	move.l	foregroundLastSafeTileAddress,d7
	moveq	#0,d5		 ; x index
	lea 	foregroundTilemap,a3

	;;  stuff that is the same for every tile
	move.l	foregroundScrollX,d3
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d3 ; convert to pixels
	lsr.w   #3,d3	; bytes to scroll

	bsr	BlitTileLoopSetup
	
.loopX:	
	moveq	#6,d6 		; y index
.loopY:
	move.l	foregroundMapPtr,a2 ;; todo: this will be too slow, it will render too many tiles
	bsr	GetMapTile
	cmp.l	d7,a2		; finished clearing...
	bgt	.done
	move.w	(a2),d0

	move.l	a3,a1 	; lea foregroundTilemap,a1	
	add.w	d0,a1 	; source tile

	move.l	foregroundOffscreen,a0
	add.l	d3,a0

	move.l	#-BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*8,d0
	move.w	d5,d4	
	add.w	d4,d4 ;; mulu.w	#2,d4
	
	add.l	d4,d0
	add.l	#10,d0
	add.l	d0,a0
	move.l	#10,d2
	sub.l	d6,d2
	bsr	BlitTileLoop
	bra	.next
.dontBlit:
.next:
	dbra	d6,.loopY
	add.w	#1,d5
	bra	.loopX
	;; dbra	d5,.loopX
.done
	rts	


RenderMapTile:
	;; d5 - x map index
	;; d6 - y map index

	move.l	foregroundMapPtr,a2
	bsr	GetMapTile
	move.l	d0,a2
	move.w	(a2),d0
	cmp.w	#0,d0
	beq	.dontBlit
	
	lea 	foregroundTilemap,a1	
	add.w	d0,a1 	; source tile
	
	move.l	foregroundScrollX,d0
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0		; convert to pixels
	lsr.w   #3,d0		; bytes to scroll
	move.l	foregroundOffscreen,a0
	add.l	d0,a0

	move.l	#-BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*8,d0
	move.w	d5,d4
	mulu.w	#2,d4
	add.l	d4,d0
	add.l	#10,d0
	add.l	d0,a0
	move.l	#10,d2
	sub.l	d6,d2
	jsr	BlitTile
.dontBlit:
	rts


GetMapTile:
	;; d5 - x board index
	;; d6 - y board index
	;; a2 - map
	;;
	;; d0 - pathwayOffset
	
	
	;; calculate the a2 offset of the top right tile based on foreground scroll
	move.l	foregroundScrollX,d0		
	lsr.w   #FOREGROUND_SCROLL_TILE_INDEX_CONVERT+1,d0
	and.b   #$f0,d0
	adda.w	d0,a2

	move.l	#(FOREGROUND_PLAYAREA_WIDTH_WORDS/2)-1,d1
	sub.w	d5,d1		; x column
	lsl.w	#4,d1 		; mulu.w  #FOREGROUND_PLAYAREA_HEIGHT_WORDS*2,d1
	suba.w	d1,a2		; player x if y == bottom ?

	sub.l	d1,d1
	moveq	#FOREGROUND_PLAYAREA_HEIGHT_WORDS-1,d1
	sub.w	d6,d1 		; y row
	lsl.w	#1,d1
	adda.w	d1,a2

	;; a2 now points at the tile at the coordinate
	move.l	a2,d0
	rts

BlitTileLoopSetup:
	WaitBlitter	
	move.w	#0,BLTCON1(a6)
	move.w	#BC0F_SRCA|BC0F_DEST|$f0,BLTCON0(a6)	
	move.w 	#TILEMAP_WIDTH_BYTES-2,BLTAMOD(a6)
	move.w 	#BITPLANE_WIDTH_BYTES-2,BLTDMOD(a6)		;
	move.w	#$ffff,BLTAFWM(a6)
	move.w	#$ffff,BLTALWM(a6)
	rts
	
BlitTileLoop:
	;; a0.l - dest bitplane pointer
	;; a1.l - source tile pointer
	;; d2.w - y tile index
	;; kills d2,a0,a2

	lea	blitTileLoopMuluTable(pc),a2
	add.w	d2,d2
	adda.w	0(a2,d2.w),a0

	WaitBlitter	
	move.l 	a1,BLTAPTH(a6) 		; source
	move.l 	a0,BLTDPTH(a6)		; dest
	move.w 	#(16*SCREEN_BIT_DEPTH)<<6|(1),BLTSIZE(a6)	;rectangle size, starts blit
	rts

blitTileLoopMuluTable:
	dc.w	BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*16*0
	dc.w	BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*16*1
	dc.w	BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*16*2
	dc.w	BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*16*3
	dc.w	BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*16*4
	dc.w	BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*16*5
	dc.w	BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*16*6
	dc.w	BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*16*7
	dc.w	BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*16*8
	dc.w	BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*16*9
	dc.w	BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*16*10
	dc.w	BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*16*11
	dc.w	BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*16*12
	dc.w	BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*16*13
	dc.w	BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*16*14
	dc.w	BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH*16*15	
