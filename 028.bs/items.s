	include "includes.i"

	xdef SetupItemSpriteData
	xdef ScrollItemSprites
	xdef RenderItemSprite
	xdef ResetItems
	xdef EnableItemSprites
	xdef DetectItemCollisions
	xdef InitialiseItems
	xdef SwitchItemSpriteBuffers
	
DeleteItemSprite:
	move.w	#0,ITEM_SPRITE(a1)
	move.w	#0,ITEM_X(a1)
	move.w	#0,ITEM_LAGX(a1)
	move.w	ITEM_Y(a1),d2
	rts
	
ScrollItemSprites:
	move.w	#ITEM_NUM_SLOTS-1,d1
	lea	item1,a1
.loop:
	move.l 	foregroundScrollPixels,d0
	cmp.w	#0,ITEM_SPRITE(a1)
	beq	.skip
	sub.w	d0,ITEM_X(a1)
	cmp.w	#160<<FOREGROUND_SCROLL_SHIFT_CONVERT,ITEM_X(a1)
	bgt	.skip
	move.w	#0,ITEM_SPRITE(a1)
	move.w	#0,ITEM_X(a1)
	move.w	#0,ITEM_LAGX(a1)
	move.w	ITEM_Y(a1),d2
.skip:
	add.l	#ITEM_STRUCT_SIZE,a1		; multiply by 16 (item control structure size)
	dbra	d1,.loop
	rts

DetectItemCollisions:
	move.w	#ITEM_NUM_SLOTS-1,d1
	lea	item1,a1
.loop:
	cmp.w	#0,ITEM_SPRITE(a1)	
	beq	.skip
	move.w	spriteX,d2
	move.w	ITEM_X(a1),d3
	move.w	ITEM_Y(a1),d4
	mulu.w	#ITEM_SPRITE_SPACING,d4
	add.w	#ITEM_SPRITE_VSTART,d4
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d3 ; convert to pixels
	add.w	#ITEM_SPRITE_HORIZONTAL_START_PIXELS,d3
	cmp.w	d2,d3
	bne	.skip
	move.w	spriteY,d2
	add.w	#ITEM_SPRITE_Y_COLLISION_OFFSET,d2	
	cmp.w	d2,d4
	bne	.skip	
	bsr	DeleteItemSprite
	lea	coinCounterText,a0
	jsr	IncrementCounter
	bsr	RenderCoinScore

	PlaySound Chaching

.skip:
	add.l	#ITEM_STRUCT_SIZE,a1
	dbra	d1,.loop	
	rts


RenderCoinScore:
	lea	coinCounterText,a1	
	move.w	#31,d0
	jsr	RenderCounter	
	rts

InitialiseItems:
	move.l	#"0000",coinCounterText
	bsr	RenderCoinScore
	
ResetItems:
	lea	item1,a1	
	move.w  #ITEM_NUM_SLOTS-1,d1
.loop1:
	move.w	#0,ITEM_SPRITE(a1)
	move.w	#0,ITEM_X(a1)
	move.w	#0,ITEM_LAGX(a1)
	move.w	ITEM_Y(a1),d2	
	add.l	#ITEM_STRUCT_SIZE,a1		; multiply by 16 (item control structure size)	
	dbra	d1,.loop1
	move.l	#0,itemSpritesEnabled
	rts


SwitchItemSpriteBuffers:

	move.w	spriteX,spriteLagX	
	
	move.w	#ITEM_NUM_SLOTS-1,d1
	move.w	d1,d0
	lea	item1,a1
.loop:
	move.w	ITEM_X(a1),ITEM_LAGX(a1)
	adda.l	#ITEM_STRUCT_SIZE,a1		
	dbra	d1,.loop
	rts

SetupItemSpriteData:
	;; d0 - item slot	
	move.l	d0,-(sp)
	move.l	d0,d4 					; save item slot
	
	lsl.w	#ITEM_STRUCT_MULU_SHIFT,d0		; multiply by 16 (item control structure size)
	lea	item1,a1
	add.l	d0,a1


	move.w	ITEM_Y(a1),d2
	;; move.l	#5,d2
	
	move.l	ITEM_SPRITE_ADDRESS(a1),a0
	
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
	;; 	 move.w	ITEM_X(a1),ITEM_LAGX(a1)

	cmp.l	#0,itemSpritesEnabled
	beq	.dontEnable

	add.w	#ITEM_SPRITE_HORIZONTAL_START_PIXELS,d0
	move.w	d0,d1
	andi	#1,d1
	move.b	d1,3(a0)	;spriteControl
	lsr.l	#1,d0
	move.b	d0,1(a0)	;spriteHStart

.c1:
	sub.l	d2,a0	;#1*ITEM_SPRITE_VERTICAL_BYTES,a0
	cmp.b	#8,d4
	bge	.arrowSprite
	move.l	a0,SPR2PTH(a6)
	bra	.done
.arrowSprite:
	move.l	a0,SPR4PTH(a6)
	bra	.done	
.dontEnable:
	cmp.b	#8,d4
	bge	.dontEnableArrowSprite	
	move.l	#deadSprite,SPR2PTH(a6)
	bra	.done
.dontEnableArrowSprite:
	move.l	#deadSprite,SPR4PTH(a6)	

.done:
	add.w	#1,ITEM_INDEX(a1)		
	move.l	(sp)+,d0
	rts
	
RenderItemSprite:
	;; d2 - y tile index ?
	movem.l	d2-d3,-(sp)

	move.l	foregroundScrollX,d1
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d1 ; convert to pixels
	andi.w	#$f,d1
	cmp.b	#$f,d1		; only add sprite after tile has scrolled in
	bne	dontAddSprite
	move.l	a2,a3
	add.l	mapSize,a3
	cmpi.w	#0,(a3)
	beq	dontAddSprite

GetSpriteSlot:
	move.w	(a3),d0 		; sprite slot
	sub.w	#1,d0
	
	move.w	d0,d1
	lsl.w	#ITEM_STRUCT_MULU_SHIFT,d0		; multiply by 16 (item control structure size)
	lea	item1,a1
	add.l	d0,a1	
	
	;; move.l	#deadSprite,ITEM_SPRITE_ADDRESS(a1)
	move.w	#336<<FOREGROUND_SCROLL_SHIFT_CONVERT,ITEM_X(a1)
	sub.l	#1,d2
	move.w	d2,ITEM_Y(a1)
	move.w	ITEM_X(a1),ITEM_LAGX(a1)

	add.w	#1,d1
	move.w	d1,ITEM_SPRITE(a1)

	;; move.l	#spriteCoin1,ITEM_SPRITE_ADDRESS(a1)
dontAddSprite:
	movem.l	(sp)+,d2-d3
	rts

EnableItemSprites:
	move.l	#1,itemSpritesEnabled
	rts
	
itemSpritesEnabled:
	dc.l	0

	;; coin1
	ItemControl item1,spriteCoin1
	ItemControl item2,spriteCoin1
	ItemControl item3,spriteCoin1
	ItemControl item4,spriteCoin1
	ItemControl item5,spriteCoin1
	ItemControl item6,spriteCoin1
	ItemControl item7,spriteCoin1
	ItemControl item8,spriteCoin1

	;; arrow1
	ItemControl item9,spriteArrow1
	ItemControl item10,spriteArrow1
	ItemControl item11,spriteArrow1
	ItemControl item12,spriteArrow1
	ItemControl item13,spriteArrow1
	ItemControl item14,spriteArrow1
	ItemControl item15,spriteArrow1
	ItemControl item16,spriteArrow1	

	ItemSprite spriteCoin1,sprite_coin-0.bin
	ItemSprite spriteCoin2,sprite_coin-0.bin
	ItemSprite spriteCoin3,sprite_coin-1.bin
	ItemSprite spriteCoin4,sprite_coin-2.bin
	ItemSprite spriteCoin5,sprite_coin-3.bin
	ItemSprite spriteCoin6,sprite_coin-2.bin
	ItemSprite spriteCoin7,sprite_coin-1.bin

	ItemSprite spriteArrow1,sprite_arrow-0.bin
	ItemSprite spriteArrow2,sprite_arrow-0.bin
	ItemSprite spriteArrow3,sprite_arrow-1.bin
	ItemSprite spriteArrow4,sprite_arrow-2.bin
	ItemSprite spriteArrow5,sprite_arrow-3.bin
	ItemSprite spriteArrow6,sprite_arrow-2.bin
	ItemSprite spriteArrow7,sprite_arrow-1.bin

nextSpriteSlot:
	dc.w	0


coinCounterText:
	dc.b	"0000"
	dc.b	0
	align	4