	include "includes.i"

	xdef SetupItemSpriteData
	xdef ScrollItemSprites
	xdef RenderItemSprite
	
ScrollItemSprites:	
	sub.w	#1,itemX
	rts
	
SetupItemSpriteData:
	move.l	currentItemSprite,a0
	cmp.w	#11<<3,itemIndex
	ble	.dontResetIndex
	move.l	#0,itemIndex
.dontResetIndex:
	cmp.l	#deadSprite,a0
	bne	.setupSprite
	bra	.c1
.setupSprite:

	move.l	#0,d0
	move.w	itemIndex,d0
	lsr.l	#3,d0
	mulu.w	#64+12,d0
	add.l	d0,a0
	add.w	#1,itemIndex
	move.w	itemLagX,d0
	move.w	itemX,itemLagX
	add.w	#32,d0
	move.w	d0,d1
	andi	#1,d1
	move.b	d1,3(a0)	;spriteControl
	lsr.l	#1,d0
	move.b	d0,1(a0)	;spriteHStart
	move.w	itemY,d0
	move.b	d0,(a0)		;spriteVStart
	move.w	itemYEnd,d0
	move.b	d0,2(a0)	;spriteVStop
.c1:
	move.l	a0,SPR2PTH(a6)	
	rts

RenderItemSprite:
	;; d2 - y tile index ?
	movem.l	d2-d3,-(sp)	
	move.l	foregroundScrollX,d0
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d0 ; convert to pixels
	andi.w	#$f,d0
	cmp.b	#15,d0
	bne	.dontAddSprite
	move.l	a2,a3
	add.l	mapSize,a3
	cmpi.w	#0,(a3)
	beq	.dontAddSprite
	move.l	#spriteCoin1,currentItemSprite
	move.w	#337,itemX
	mulu.w	#16,d2
	move.w	#255-12,d3
	sub.w	d2,d3
	move.w	d3,itemY
	add.w	#16,d3
	move.w	d3,itemYEnd
	move.w	#0,itemIndex
.dontAddSprite:
	movem.l	(sp)+,d2-d3
	rts

currentItemSprite:
	dc.l	deadSprite
itemX:
	dc.w	0
itemLagX:
	dc.w	0
itemY:
	dc.w	0
itemYEnd:
	dc.w	0
itemIndex:
	dc.w	4

spriteCoin1:
	dc.w	0,0
	dc.w	0,0
	incbin	"out/sprite_coin1.bin"
	dc.l	0
spriteCoin2:
	dc.w	0,0
	dc.w	0,0
	incbin	"out/sprite_coin2.bin"
	dc.l	0
spriteCoin3:
	dc.w	0,0
	dc.w	0,0
	incbin	"out/sprite_coin3.bin"
	dc.l	0
spriteCoin4:
	dc.w	0,0
	dc.w	0,0
	incbin	"out/sprite_coin4.bin"
	dc.l	0				
spriteCoin5:
	dc.w	0,0
	dc.w	0,0
	incbin	"out/sprite_coin3.bin"
	dc.l	0
spriteCoin6:
	dc.w	0,0
	dc.w	0,0
	incbin	"out/sprite_coin6.bin"
	dc.l	0
spriteCoin7:
	dc.w	0,0
	dc.w	0,0
	incbin	"out/sprite_coin7.bin"
	dc.l	0
spriteCoin8:
	dc.w	0,0
	dc.w	0,0
	incbin	"out/sprite_coin6.bin"
	dc.l	0	
spriteCoin9:
	dc.w	0,0
	dc.w	0,0
	incbin	"out/sprite_coin3.bin"
	dc.l	0
spriteCoin10:
	dc.w	0,0
	dc.w	0,0
	incbin	"out/sprite_coin4.bin"
	dc.l	0
spriteCoin11:
	dc.w	0,0
	dc.w	0,0
	incbin	"out/sprite_coin3.bin"
	dc.l	0
spriteCoin12:
	dc.w	0,0
	dc.w	0,0
	incbin	"out/sprite_coin2.bin"
	dc.l	0	