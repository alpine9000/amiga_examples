	include "includes.i"

	xdef SetupItemSpriteData
	xdef ScrollItemSprites
	xdef RenderItemSprite
	
ScrollItemSprites:
	move.w	#1,d0
	lsl.w	#ITEM_STRUCT_MULU_SHIFT,d0		; multiply by 16 (item control structure size)
	lea	item1,a1
	add.l	d0,a1

	move.l 	foregroundScrollPixels,d0
	sub.w	d0,ITEM_X(a1)	
	rts

ClearItemSpriteData:
	move.w	#ITEM_SPRITE_NUM_VERTICAL_SPRITES-1,d4
	sub.w	d2,d4 		; this is because of the upside board at the moment
	move.w	d4,d2
	move.w  #ITEM_NUM_COIN_ANIMS-1,d4
	move.l	#spriteCoin1,a0
.l2:
	move.w	#ITEM_SPRITE_NUM_VERTICAL_SPRITES-1,d3
.l1:
	cmp.w	d3,d2
	beq	.skip
	move.b	#0,3(a0)
	move.b	#0,1(a0)

.skip:
	add.l	#ITEM_SPRITE_VERTICAL_BYTES,a0
	dbra.w	d3,.l1
	add.l	#4,a0
	dbra.w	d4,.l2
	rts
	
SetupItemSpriteData:
	;; d0 - item slot	
	move.l	#1,d0
	
	lsl.w	#ITEM_STRUCT_MULU_SHIFT,d0		; multiply by 16 (item control structure size)
	lea	item1,a1
	add.l	d0,a1


	move.w	ITEM_Y(a1),d2
	;; move.l	#5,d2
	
	move.l	currentItemSprite,a0
	
	cmp.w	#(ITEM_NUM_COIN_ANIMS-1)<<3,ITEM_INDEX(a1)
	ble	.dontResetIndex
	move.l	#0,ITEM_INDEX(a1)
.dontResetIndex:
	cmp.l	#deadSprite,a0
	bne	.setupSprite
	bra	.c1
.setupSprite:

	move.l	#0,d0
	move.w	ITEM_INDEX(a1),d0
	lsr.l	#3,d0
	mulu.w	#ITEM_SPRITE_BYTES,d0
	add.l	d0,a0

	mulu.w	#ITEM_SPRITE_VERTICAL_BYTES,d2
	add.l	d2,a0

	move.w	ITEM_LAGX(a1),d0
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0 ; convert to pixels
	move.w	ITEM_X(a1),ITEM_LAGX(a1)
	add.w	#32,d0
	move.w	d0,d1
	andi	#1,d1
	move.b	d1,3(a0)	;spriteControl
	lsr.l	#1,d0
	move.b	d0,1(a0)	;spriteHStart

.c1:
	sub.l	d2,a0	;#1*ITEM_SPRITE_VERTICAL_BYTES,a0
	move.l	a0,SPR2PTH(a6)

	add.w	#1,ITEM_INDEX(a1)		
	rts
	
RenderItemSprite:
	;; d2 - y tile index ?
	movem.l	d2-d3,-(sp)

	move.l	#1,d0
	lsl.w	#ITEM_STRUCT_MULU_SHIFT,d0		; multiply by 16 (item control structure size)
	lea	item1,a1
	add.l	d0,a1	

	move.l	foregroundScrollX,d0
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0 ; convert to pixels
	andi.w	#$f,d0
	cmp.b	#$f,d0
	bne	.dontAddSprite
	move.l	a2,a3
	add.l	mapSize,a3
	cmpi.w	#0,(a3)
	beq	.dontAddSprite

	move.l	#deadSprite,currentItemSprite	
	move.w	#336<<FOREGROUND_SCROLL_SHIFT_CONVERT,ITEM_X(a1)
	sub.l	#1,d2
	move.w	d2,ITEM_Y(a1)
	move.w	ITEM_X(a1),ITEM_LAGX(a1)
	bsr	ClearItemSpriteData					
	move.l	#spriteCoin1,currentItemSprite
.dontAddSprite:
	movem.l	(sp)+,d2-d3
	rts

currentItemSprite:
	dc.l	deadSprite

	ItemControl item1
	ItemControl item2
	ItemControl item3
	ItemControl item4
	ItemControl item5
	ItemControl item6
	ItemControl item7
	ItemControl item8	

	ItemSprite spriteCoin1,sprite_coin-0.bin
	ItemSprite spriteCoin2,sprite_coin-0.bin
	ItemSprite spriteCoin3,sprite_coin-1.bin
	ItemSprite spriteCoin4,sprite_coin-2.bin
	ItemSprite spriteCoin5,sprite_coin-3.bin
	ItemSprite spriteCoin6,sprite_coin-2.bin
	ItemSprite spriteCoin7,sprite_coin-1.bin	


