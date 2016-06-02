DetectBeeCollisions:
	bsr 	DetectDownBeeCollisions
	bsr 	DetectUpBeeCollisions	
	rts
VerticalScrollBees:
	bsr	VerticalScrollDownBee
	bsr	VerticalScrollUpBee
	rts

VerticalScrollDownBee:
	lea	itemBeeDown,a1
	cmp.w	#0,ITEM_SPRITE(a1)
	beq	.done
	move.w	ITEM_Y(a1),d4
	lsl.w	#ITEM_SPRITE_SPACING_SHIFT_CONVERT,d4
	add.w	#ITEM_SPRITE_VSTART,d4
	lsl.w	#ITEM_Y_OFFSET_SHIFT_CONVERT,d4
	move.w	ITEM_Y_OFFSET(a1),d0
	add.w	d0,d4	
	cmp.w	#1,beeDownMovingDown
	bne	.up
.down:	
	add.w	beeDownSpeed,d0
	bra	.c1
.up:
	sub.w	beeDownSpeed,d0
.c1:
	move.w	d0,ITEM_Y_OFFSET(a1)
	cmp.w	#(ITEM_SPRITE_VSTART+(16*5))<<ITEM_Y_OFFSET_SHIFT_CONVERT,d4
	bge	.beeAtBottom
	cmp.w	#0,d0
	ble	.beeAtTop
	bra	.done
.beeAtTop:
	move.w	#1,beeDownMovingDown
	bra	.done	
.beeAtBottom:
	move.w	#0,beeDownMovingDown
.done:
	rts

VerticalScrollUpBee:
	lea	itemBeeUp,a1
	cmp.w	#0,ITEM_SPRITE(a1)
	beq	.done
	move.w	ITEM_Y(a1),d4
	lsl.w	#ITEM_SPRITE_SPACING_SHIFT_CONVERT,d4
	add.w	#ITEM_SPRITE_VSTART,d4
	lsl.w	#ITEM_Y_OFFSET_SHIFT_CONVERT,d4
	move.w	ITEM_Y_OFFSET(a1),d0
	sub.w	d0,d4	
	cmp.w	#1,beeUpMovingDown
	bne	.up
.down:	
	add.w	beeUpSpeed,d0
	bra	.c1
.up:
	sub.w	beeUpSpeed,d0
.c1:
	move.w	d0,ITEM_Y_OFFSET(a1)
	cmp.w	#(ITEM_SPRITE_VSTART)<<ITEM_Y_OFFSET_SHIFT_CONVERT,d4
	ble	.beeAtBottom
	cmp.w	#0,d0
	ble	.beeAtTop
	bra	.done
.beeAtTop:
	move.w	#1,beeUpMovingDown
	bra	.done	
.beeAtBottom:
	move.w	#0,beeUpMovingDown
.done:
	rts	

DetectDownBeeCollisions:
	lea	itemBeeDown,a1
	cmp.w	#0,ITEM_SPRITE_ENABLED(a1)
	beq	.skip
	cmp.w	#0,ITEM_SPRITE(a1)	
	beq	.skip
	move.w	spriteX,d2
	move.w	ITEM_X(a1),d3
	move.w	ITEM_Y(a1),d4
	lsl.w	#ITEM_SPRITE_SPACING_SHIFT_CONVERT,d4
	add.w	#ITEM_SPRITE_VSTART,d4
	move.w	ITEM_Y_OFFSET(a1),d5
	lsr.l	#ITEM_Y_OFFSET_SHIFT_CONVERT,d5	
	add.w	d5,d4
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d3 ; convert to pixels
	add.w	#ITEM_SPRITE_HORIZONTAL_START_PIXELS,d3
	move.w	spriteY,d5
	;; d2 = playerX pixels
	;; d3 = beeX pixels
	;; d4 = beeY pixels
	;; d5 = player Y pixels
	move.w	d3,d6
	add.w	#BEE_COLLIDE_SIZE,d6
	cmp.w	d2,d6 		; r1.x >= r2.x+w
	ble	.skip

	move.w	d2,d6
	add.w	#BEE_COLLIDE_SIZE,d6
	cmp.w	d3,d6		; r1.x+w <= r2.x
	ble	.skip

	move.w	d4,d6
	add.w	#BEE_COLLIDE_SIZE,d6
	cmp.w	d5,d6		; r1.y >= r2.y+h
	ble	.skip

	move.w	d5,d6
	add.w	#BEE_COLLIDE_SIZE,d6
	cmp.w	d4,d6		; r1.y+h < r2.y
	ble	.skip

	bsr	DeleteItemSprite
	add.l	#3*4,a7 ; dirty hack - unwind the call stack
	jmp	BigBang
.skip:
	rts

DetectUpBeeCollisions:
	lea	itemBeeUp,a1
	cmp.w	#0,ITEM_SPRITE_ENABLED(a1)
	beq	.skip
	cmp.w	#0,ITEM_SPRITE(a1)	
	beq	.skip
	move.w	spriteX,d2
	move.w	ITEM_X(a1),d3
	move.w	ITEM_Y(a1),d4
	lsl.w	#ITEM_SPRITE_SPACING_SHIFT_CONVERT,d4
	add.w	#ITEM_SPRITE_VSTART,d4
	move.w	ITEM_Y_OFFSET(a1),d5
	lsr.l	#ITEM_Y_OFFSET_SHIFT_CONVERT,d5	
	sub.w	d5,d4
	lsr.w	#FOREGROUND_SCROLL_SHIFT_CONVERT,d3 ; convert to pixels
	add.w	#ITEM_SPRITE_HORIZONTAL_START_PIXELS,d3
	move.w	spriteY,d5
	;; d2 = playerX pixels
	;; d3 = beeX pixels
	;; d4 = beeY pixels
	;; d5 = player Y pixels
	move.w	d3,d6
	add.w	#BEE_COLLIDE_SIZE,d6
	cmp.w	d2,d6 		; r1.x >= r2.x+w
	ble	.skip

	move.w	d2,d6
	add.w	#BEE_COLLIDE_SIZE,d6
	cmp.w	d3,d6		; r1.x+w <= r2.x
	ble	.skip

	move.w	d4,d6
	add.w	#BEE_COLLIDE_SIZE,d6
	cmp.w	d5,d6		; r1.y >= r2.y+h
	ble	.skip

	move.w	d5,d6
	add.w	#BEE_COLLIDE_SIZE,d6
	cmp.w	d4,d6		; r1.y+h < r2.y
	ble	.skip

	bsr	DeleteItemSprite
	add.l	#3*4,a7 ; dirty hack - unwind the call stack
	jmp	BigBang
.skip:
	rts		

	