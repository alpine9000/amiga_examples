WaitBlitter:	macro
	tst	DMACONR(a6)		;for compatibility
.\@:
	btst	#6,DMACONR(a6)
	bne.s 	.\@
	endm


ItemSprite:	macro
\1:
	dc.b	ITEM_SPRITE_VSTART	 ; vstart
	dc.b	64			 ; hstart
	dc.b	ITEM_SPRITE_VSTART+ITEM_SPRITE_HEIGHT+1; vstop
	dc.b	0
	incbin	"out/\2"
	dc.b	ITEM_SPRITE_VSTART+(16*2); vstart
	dc.b	0			 ; hstart
	dc.b	ITEM_SPRITE_VSTART+(16*2)+ITEM_SPRITE_HEIGHT; vstop
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
\1:
.itemX:
	dc.w	0
.itemLagX:
	dc.w	0
.itemY:
	dc.w	0
.itemLagY:
	dc.w	0
.itemYEnd:
	dc.w	0
.itemLagYEnd:
	dc.w	0
.itemIndex:
	dc.w	0		
.pad	; make the control word 16 bytes
	dc.w	0
	endm