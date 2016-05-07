PlaySound:	macro
	if	SFX=1
	jsr	Play\1Sound	
	endif
	endm

WaitBlitter:	macro
	tst	DMACONR(a6)		;for compatibility
.\@:
	btst	#6,DMACONR(a6)
	bne.s 	.\@
	endm


ItemSprite:	macro
\1:
	dc.b	ITEM_SPRITE_VSTART	 ; vstart
	dc.b	0			 ; hstart
	dc.b	ITEM_SPRITE_VSTART+ITEM_SPRITE_HEIGHT; vstop
	dc.b	0
	incbin	"out/\2"
	dc.b	ITEM_SPRITE_VSTART+(16*1); vstart
	dc.b	0			 ; hstart
	dc.b	ITEM_SPRITE_VSTART+(16*1)+ITEM_SPRITE_HEIGHT; vstop
	dc.b	0	
	incbin	"out/\2"
	dc.b	ITEM_SPRITE_VSTART+(16*2); vstart
	dc.b	0			 ; hstart
	dc.b	ITEM_SPRITE_VSTART+(16*2)+ITEM_SPRITE_HEIGHT; vstop
	dc.b	0		
	incbin	"out/\2"
	dc.b	ITEM_SPRITE_VSTART+(16*3); vstart
	dc.b	0			 ; hstart
	dc.b	ITEM_SPRITE_VSTART+(16*3)+ITEM_SPRITE_HEIGHT; vstop
	dc.b	0			
	incbin	"out/\2"
	dc.b	ITEM_SPRITE_VSTART+(16*4); vstart
	dc.b	0			 ; hstart
	dc.b	ITEM_SPRITE_VSTART+(16*4)+ITEM_SPRITE_HEIGHT; vstop
	dc.b	0			
	incbin	"out/\2"
	dc.b	ITEM_SPRITE_VSTART+(16*5); vstart
	dc.b	0			 ; hstart
	dc.b	ITEM_SPRITE_VSTART+(16*5)+ITEM_SPRITE_HEIGHT; vstop
	dc.b	0			
	incbin	"out/\2"
	dc.l	0
	endm



ItemControl:	macro
	align 4
\1:
.itemX:
	dc.w	0
.itemLagX:
	dc.w	0
.itemY:
	dc.w	0
.itemSprite:
	dc.w	0
.itemIndex:
	dc.w	0
.itemEnabled:
	dc.w	\3
.spriteAddress:
	dc.l	\2
	endm


PlayerMoveRight: macro
	move.w	playerJumpPixels,d1
	add.w	playerPausePixels,d1
	move.w	d1,spriteR
	move.w	#SPRITE_MOVE_RIGHT,spriteLastMove
	PlaySound Jump
	endm

PlayerMoveUp:	macro
	move.w	playerJumpPixels,d1
	add.w	playerPausePixels,d1
	move.w	d1,spriteU	
	move.w	#SPRITE_MOVE_UP,spriteLastMove	
	PlaySound Jump
	endm

PlayerMoveDown:	macro
	move.w	playerJumpPixels,d1
	add.w	playerPausePixels,d1
	move.w	d1,spriteD
	move.w	#SPRITE_MOVE_DOWN,spriteLastMove	
	PlaySound Jump
	endm

PlayerMoveLeft:	macro
	move.w	playerJumpPixels,d1
	add.w	playerPausePixels,d1
	move.w	d1,spriteL
	move.w	#SPRITE_MOVE_LEFT,spriteLastMove	
	PlaySound Jump
	endm