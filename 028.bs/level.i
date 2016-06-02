Level:	macro
InstallLevel\1:
	movem.l	d0/a0-a1,-(sp)
	move.w	#\d,beeUpSpeed
	move.w	#\e,beeDownSpeed
	move.l	#\cPlayerSpriteConfig,playerSpriteConfig
	move.l	#level\1StartMessage,startMessage
	move.l	#level\1CompleteMessage,levelCompleteMessage
	move.l	#palette\8_playAreaPalette,playAreaPalette
	move.l	#palette\8_playareaFade,playareaFade
	move.l	#palette\8_flagsFade,flagsFade
	move.l	#palette\8_tileFade,tileFade
	move.w	#\3,pathwayFadeTimerCount
	move.l	#\4,pathwayFadeRate
	move.w	#\5,playerLevelPausePixels
	move.w	#\6,playerLevelMissPixels
	move.l	#\9,playerXColumnLastSafe
	move.l	#\9,playerXColumn

	jsr     InstallPlayerColorPalette
	
	if \b=0
	lea	levelData,a0
	lea	level\1Start,a1
	move.l	#level\1End-level\1Start,d0
	jsr	LoadDiskData	
	move.l	#levelData+(level\1ForegroundMap-level\1Start),startForegroundMapPtr
	move.l	#levelData+(level\1PathwayMap-level\1Start),startPathwayMapPtr
	move.l	#levelData+(level\1ForegroundMap-level\1Start),foregroundMapPtr
	move.l	#levelData+(level\1PathwayMap-level\1Start),pathwayMapPtr	
	move.l	#levelData+(level\1PathwayMap-level\1Start)+8,pathwayLastSafeTileAddress
	move.l	#levelData+(level\1ForegroundMapEnd-level\1Start),endForegroundMapPtr
	move.l	#levelData+(level\1ItemsMapEnd-level\1Start),itemsMapEndPtr
	move.l	#level\1ItemsMap-level\1ForegroundMap,itemsMapOffset
	else
	move.l	#level\1ForegroundMap,startForegroundMapPtr
	move.l	#level\1PathwayMap,startPathwayMapPtr
	move.l	#level\1ForegroundMap,foregroundMapPtr
	move.l	#level\1PathwayMap,pathwayMapPtr	
	move.l	#level\1PathwayMap+8,pathwayLastSafeTileAddress
	move.l	#level\1ForegroundMapEnd,endForegroundMapPtr
	move.l	#level\1ItemsMapEnd,itemsMapEndPtr
	move.l	#level\1ItemsMap-level\1ForegroundMap,itemsMapOffset
	endif
	move.w	#\a,d0
	jsr	StartMusic
	movem.l	(sp)+,d0/a0-a1
	rts

	align 4
level\1StartMessage:
	dc.b	\2
	dc.b	0
	align 	4

level\1CompleteMessage:
	dc.b	\7
	dc.b	0
	align 4


	if \b=0
	section	.noload
	cnop	0,512
	endif
level\1Start:
level\1ForegroundMap:
	include "out/level\1_foreground-map.s"
level\1ForegroundMapEnd:
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
	dc.w	$FFFF
level\1PathwayMap:
	include "out/level\1_pathway-map.s"
level\1ItemsMap:
	include "out/level\1_items-indexes.s"
level\1ItemsMapEnd:
	cnop 0,512
level\1End:
	if \b=0
	section	CODE
	endif
	endm


Palette:	macro
palette\1_playAreaPalette:
	include	"out/palette\1_foreground-palette-table.s"
	include	"out/background-palette-table.s"	

palette\1_playareaFade:
	include "out/palette\1_playarea_fade.s"

palette\1_flagsFade:
	include "out/palette\1_flags_fade.s"	

palette\1_tileFade:
	include "out/palette\1_tileFade.s"
	endm