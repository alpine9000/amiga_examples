	include "includes.i"
	
	xdef	RenderPathway
	xdef	ClearPathway
	
RenderPathway:
	move.l	pathwayPlayerTileAddress,d5
	andi.w	#$fff0,d5       ; point the address to the last tile of the previous column
	addq	#2,d5		;
	move.l	d5,a4
	move.w	#1,d5
.loopX:	
	move.w	#6,d6 		; y index
	move.w	#0,d7		; number of rows without a pathway
.loopY:
	move.l	pathwayMapPtr,a2
	jsr	GetMapTile
	cmp.l	a4,a2		; search for the start column
	ble	.next	
	cmp.l	pathwayPlayerTileAddress,a2
	beq	.next
	
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
	bra	.next
.dontBlit:
	add.w	#1,d7
	cmp.w	#7,d7
	beq	.skip
.next:
	dbra	d6,.loopY
	add.w	#1,d5
	cmp.w	#(FOREGROUND_PLAYAREA_WIDTH_WORDS/2)-0,d5 ; don't render pathways off the play area
	beq	.pathwayNotComplete
	bra	.loopX
.skip:
	sub.w	#1,pathwayRenderPending	
	rts
.pathwayNotComplete:
	rts




ClearPathway:
	sub.w	#1,pathwayClearPending
	move.l	foregroundPlayerTileAddress,d7
	andi.w	#$fff0,d7	 ; address of the last tile in the previous column
	move.w	#0,d5		 ; x index
.loopX:	
	move.w	#6,d6 		; y index
.loopY:
	move.l	foregroundMapPtr,a2 ;; todo: this will be too slow, it will render too many tiles
	bsr	GetMapTile
	cmp.l	d7,a2		; finished clearing...
	bgt	.done
	move.l	d0,a2
	move.w	(a2),d0

	if 0
	move.l	foregroundMapPtr,a3
	move.w	(a3),d0
	endif

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
	lsr.l   #FOREGROUND_SCROLL_TILE_INDEX_CONVERT,d0
	lsr.l	#1,d0
	and.b   #$f0,d0
	add.l	d0,a2

	move.l	#(FOREGROUND_PLAYAREA_WIDTH_WORDS/2)-1,d1
	sub.w	d5,d1		; x column
	mulu.w  #FOREGROUND_PLAYAREA_HEIGHT_WORDS*2,d1
	sub.l	d1,a2		; player x if y == bottom ?

	sub.l	d1,d1
	move.w	#FOREGROUND_PLAYAREA_HEIGHT_WORDS-1,d1
	sub.w	d6,d1 		; y row
	lsl.w	#1,d1
	add.l	d1,a2

	;; a2 now points at the tile at the coordinate
	move.l	a2,d0
	rts