
	;; BLITTER_OBJECT
	;; index,startX,y,dx,mapLine,blitHeight

BLITTER_OBJECT: macro
\@:
	dc.l	1
.\@x:
	dc.l	(\2)<<BOB_SHIFT_CONVERT
.\@y:
	dc.l	\3
.\@dx:
	dc.l	0
.\@sourceAddress:
	dc.l	backgroundTilemap+(BACKGROUND_TILEMAP_WIDTH_BYTES*\4*SCREEN_BIT_DEPTH)	
.\@maskAddress:
	dc.l	bobMask+(BACKGROUND_TILEMAP_WIDTH_BYTES*\4*SCREEN_BIT_DEPTH)
.\@saveBufferAddress:
	dc.l	splash+(\1)*(BOB_SAVE_SIZE*2)
	dc.l	splash+(\1)*(BOB_SAVE_SIZE*2)+BOB_SAVE_SIZE
.\@lastDestAddress:
	dc.l	0
	dc.l	0	
.\@blitSize:
	dc.w	((\5)*SCREEN_BIT_DEPTH)<<6|(BOB_BLIT_WIDTH_WORDS)
	align 	4
	endm


BALOON_BOB: macro
	BLITTER_OBJECT \1,BOB_IDLE_X,0,67,29
	endm

CLOUD_BOB: macro
	BLITTER_OBJECT \1,BOB_IDLE_X,0,0,16
	endm	
