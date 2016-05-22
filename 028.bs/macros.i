PlaySound:	macro
	if	SFX=1
	jsr	Play\1Sound	
	endif
	endm

KillSound:	macro
	if	SFX=1
	cmp.w	#1,dontKillSound
	beq	.\@skip
	move.w	#(DMAF_AUD3),DMACON(a6)
        move.w  #1,AUD3PER(a6)	
	move.w  #2,AUD3LEN(a6) ; set the empty sound for the next sample to be played
	move.l	#emptySound,AUD3LCH(a6)	
	WaitScanLines 1
	move.w	#(DMAF_AUD3|DMAF_SETCLR),DMACON(a6)
.\@skip:
	endif
	endm

WaitScanLines: macro
	if \1 != 0
	lea 	$dff006,a0
	move.w	#\1-1,d2
.\@nTimes:
	move.w	(a0),d0
	lsr.w	#8,d0
.\@loop:
	move.w	(a0),d1
	lsr.w	#8,d1
	cmp.w	d0,d1
	beq	.\@loop
	dbra	d2,.\@nTimes
.\@done:
	endif
	endm

WaitBlitter:	macro
	tst	DMACONR(a6)		;for compatibility
.\@:
	btst	#6,DMACONR(a6)
	bne.s 	.\@
	endm


ItemSprite:	macro
	_ItemSprite \1,\2
	_ItemSprite \1_1,\2
	endm

_ItemSprite:	macro
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


ItemSingleSprite:	macro
	_ItemSingleSprite \1,\2
	_ItemSingleSprite \1_1,\2
	endm

_ItemSingleSprite:	macro
\1:
	dc.b	ITEM_SPRITE_VSTART	 ; vstart
	dc.b	0			 ; hstart
	dc.b	ITEM_SPRITE_VSTART+ITEM_SPRITE_HEIGHT; vstop
	dc.b	0
	incbin	"out/\2"
	dc.l	0
	endm

ItemControl:	macro
	align 4
\1:
.itemX:
	dc.w	0
.itemYOffset:
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
	cmp.w	#PATHWAY_CONFIG_VERTICAL,pathwayLastConfig
	beq	.\@miss
	cmp.w	#PATHWAY_CONFIG_TOP_LEFT,pathwayLastConfig
	beq	.\@miss
	cmp.w	#PATHWAY_CONFIG_BOT_LEFT,pathwayLastConfig
	beq	.\@miss		
	bra	.\@ok
.\@miss:	
	move.w	#1,pathwayMissPending
.\@ok:
	move.w	playerJumpPixels,d1
	add.w	playerPausePixels,d1
	move.w	d1,spriteR
	move.w	#PLAYER_MOVE_RIGHT,spriteLastMove
	PlaySound Jump
	sub.l	#1,playerXColumn
	jsr	UpdatePlayerScore
	endm

PlayerMoveUp:	macro
	move.w	playerJumpPixels,d1
	add.w	playerPausePixels,d1
	move.w	d1,spriteU	
	move.w	#PLAYER_MOVE_UP,spriteLastMove	
	PlaySound Jump
	jsr	UpdatePlayerScore
	endm

PlayerMoveDown:	macro
	move.w	playerJumpPixels,d1
	add.w	playerPausePixels,d1
	move.w	d1,spriteD
	move.w	#PLAYER_MOVE_DOWN,spriteLastMove	
	PlaySound Jump
	jsr	UpdatePlayerScore
	endm

PlayerMoveLeft:	macro
	cmp.w	#PATHWAY_CONFIG_VERTICAL,pathwayLastConfig
	beq	.\@miss
	cmp.w	#PATHWAY_CONFIG_TOP_RIGHT,pathwayLastConfig
	beq	.\@miss
	cmp.w	#PATHWAY_CONFIG_BOT_RIGHT,pathwayLastConfig
	beq	.\@miss
	bra	.\@ok
.\@miss:	
	move.w	#1,pathwayMissPending
.\@ok:
	move.w	playerJumpPixels,d1
	add.w	playerPausePixels,d1
	move.w	d1,spriteL
	move.w	#PLAYER_MOVE_LEFT,spriteLastMove	
	PlaySound Jump
	add.l   #1,playerXColumn
	jsr	UpdatePlayerScore
	endm

P61Module: macro
	cnop	0,512	
diskmodule\1:
	incbin	\2
	cnop	0,512
enddiskmodule\1:
	endm

AddToScore: macro 
	 add.l	#\1,__score
	 move.l	__score,d0	 
	 cmp.l	__nextPlayerBonus,d0
	 blt	.\@skip
	 movem.l d0-a6,-(sp)
	 PlaySound Yay
	 lea	livesCounterText,a0
	 jsr	IncrementCounter
	 lea	livesCounterShortText,a1
	 move.w	#PANEL_LIVES_X,d0
	 add.l	#LIVES_PLAYER_BONUS,__nextPlayerBonus
	 jsr	RenderCounter	
	 movem.l (sp)+,d0-a6
.\@skip:
	 cmp.l	#SCORE_MAX,__score
	 blt	.\@skip2
	 move.l	#0,__score
	 move.l	#LIVES_PLAYER_BONUS,__nextPlayerBonus
.\@skip2:
	 endm

ResetScore: macro
	 move.l	#0,__score
	 move.l	#LIVES_PLAYER_BONUS,__nextPlayerBonus
	 endm

CompareScore: macro
	 cmp.l	#\1,__score
	 endm
