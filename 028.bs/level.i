Level:	macro
InstallLevel\1:
	move.l	#level\1StartMessage,startMessage
	move.l	#level\1CompleteMessage,levelCompleteMessage
	move.l	#level\1ForegroundMap,startForegroundMapPtr
	move.l	#level\1PathwayMap,startPathwayMapPtr
	move.l	#level\1ForegroundMap,foregroundMapPtr
	move.l	#level\1PathwayMap,pathwayMapPtr	
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
	move.w	#\a,d0
	jsr	StartMusic
	rts

	align 4
level\1ForegroundMap:
	include "out/level\1_foreground-map.s"
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

level\1StartMessage:
	dc.b	\2
	dc.b	0
	align 	4

level\1CompleteMessage:
	dc.b	\7
	dc.b 	" COMPLETE!"
	dc.b	0
	align 	4


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