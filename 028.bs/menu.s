	include "includes.i"

	xdef	ShowMenu

SPLASH_COLOR_DEPTH		equ 5
SPLASH_SCREEN_WIDTH_BYTES	equ 40

PLAY_COPPER_WORD		equ $bad1

MENU_SELECTED_TOP_COLOR		equ $be0 ;$e71
MENU_SELECTED_BOTTOM_COLOR	equ $9d4 ;$fe7
MENU_TEXT_COLOR			equ $7ef
MENU_TEXT_BOTTOM_COLOR		equ $5cd	

MENU_OFFSET			equ levelTopColor-playTopColor
MENU_BOTTOM_OFFSET		equ (playBottomColor-playTopColor)
	
ShowMenu:
	lea 	CUSTOM,a6

	jsr	WaitVerticalBlank	
	;; set up default palette
	include "out/menu-palette.s"
	
	;; set up playfield
	move.w  #(RASTER_Y_START<<8)|RASTER_X_START,DIWSTRT(a6)
	move.w	#((RASTER_Y_STOP-256)<<8)|(RASTER_X_STOP-256),DIWSTOP(a6)

	move.w	#(RASTER_X_START/2-SCREEN_RES),DDFSTRT(a6)
	move.w	#(RASTER_X_START/2-SCREEN_RES)+(8*((SCREEN_WIDTH/16)-1)),DDFSTOP(a6)
	
	move.w	#(SPLASH_COLOR_DEPTH<<12)|$200,BPLCON0(a6)
	move.w	#0,BPLCON1(a6)	
	move.w	#SPLASH_SCREEN_WIDTH_BYTES*SPLASH_COLOR_DEPTH-SPLASH_SCREEN_WIDTH_BYTES,BPL1MOD(a6)
	move.w	#SPLASH_SCREEN_WIDTH_BYTES*SPLASH_COLOR_DEPTH-SPLASH_SCREEN_WIDTH_BYTES,BPL2MOD(a6)

	;; poke bitplane pointers
	lea	splash,a1
	lea     splashCopperListBplPtr(pc),a2
	moveq	#SPLASH_COLOR_DEPTH-1,d0
.bitplaneloop:
	move.l 	a1,d1
	move.w	d1,2(a2)
	swap	d1
	move.w  d1,6(a2)
	lea	SPLASH_SCREEN_WIDTH_BYTES(a1),a1 ; bit plane data is interleaved
	addq	#8,a2
	dbra	d0,.bitplaneloop

	;; install copper list, then enable dma
	lea	splashCopperList(pc),a0
	move.l	a0,COP1LC(a6)
	
	;; 	jsr	WaitVerticalBlank			
	move.w	#(DMAF_BLITTER|DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),DMACON(a6)		
	move.w	#(INTF_SETCLR|INTF_VERTB|INTF_INTEN),INTENA(a6)	

	bsr	RefreshDifficulty
	bsr	RenderMenu
	
.wait:
	jsr	WaitVerticalBlank
	jsr	_ProcessJoystick
	rts


RenderMenu:
	lea	splashSave,a0
	lea	splash,a2
	add.l	#(150*40*5)+((320-96)/16),a2

	WaitBlitter	
	move.w #(BC0F_SRCA|BC0F_DEST|$f0),BLTCON0(A6)
	move.w #0,BLTCON1(a6) 
	move.l #$ffffffff,BLTAFWM(a6) 	;no masking of first/last word
	move.w #0,BLTAMOD(a6)		;A modulo
	move.w #(320-96)/8,BLTDMOD(a6)	;D modulo	
	move.l a0,BLTAPTH(a6)		;source graphic top left corner
	move.l a2,BLTDPTH(a6)		;destination top left corner
	move.w 	#((64*5)<<6)|(96/16),BLTSIZE(a6)	

	lea	menu,a1
	lea	splash,a0
	move.w	#(320/2)-(6*8)+4,d0
	move.w	#150,d1
	jsr	DrawMaskedText85
	lea	difficulty,a1
	move.w	#(320/2)-(6*8),d0	
	add.w	#16,d1	
	jsr	DrawMaskedText85
	lea	music,a1
	add.w	#16,d1		
	jsr	DrawMaskedText85
	lea	credits,a1
	add.w	#16,d1			
	move.w	#(320/2)-(6*8)+4,d0	
	jsr	DrawMaskedText85
	rts
	
MenuUp:
	cmp.l	#playTopColor,selectedPtr
	beq	.done
	PlaySound Jump
	move.l	selectedPtr,a0
	move.w 	#MENU_TEXT_COLOR,(a0)
	add.l	#MENU_BOTTOM_OFFSET,a0
	move.w	#MENU_TEXT_BOTTOM_COLOR,(a0)
	sub.l	#MENU_OFFSET,selectedPtr
	move.l	selectedPtr,a0	
	move.w 	#MENU_SELECTED_TOP_COLOR,(a0)
	add.l	#MENU_BOTTOM_OFFSET,a0
	move.w	#MENU_SELECTED_BOTTOM_COLOR,(a0)
.done:
	rts

MenuDown:
	cmp.l	#creditsTopColor,selectedPtr
	beq	.done
	PlaySound Jump		
	move.l	selectedPtr,a0
	move.w 	#MENU_TEXT_COLOR,(a0)
	add.l	#MENU_BOTTOM_OFFSET,a0
	move.w	#MENU_TEXT_BOTTOM_COLOR,(a0)
	add.l	#MENU_OFFSET-MENU_BOTTOM_OFFSET,a0
	move.w 	#MENU_SELECTED_TOP_COLOR,(a0)
	add.l	#MENU_BOTTOM_OFFSET,a0
	move.w	#MENU_SELECTED_BOTTOM_COLOR,(a0)
	add.l	#MENU_OFFSET,selectedPtr
.done:
	rts	

ToggleMusic:
	eor.w	#64,P61_Master
	cmp.w	#64,P61_Master
	beq	.musicOn
.musicOff:
	lea	musicOff,a0
	lea	music,a1
	bsr	StrCpy
	bra	.done
.musicOn:
	lea	musicOn,a0
	lea	music,a1
	bsr	StrCpy
	bra	.done
.done:
	bsr	RenderMenu
	rts

ToggleDifficulty:
	add.l	#4,nextLevelInstaller
	cmp.l	#levelInstallers+8,nextLevelInstaller
	ble	RefreshDifficulty
	move.l	#levelInstallers,nextLevelInstaller
RefreshDifficulty:	
	cmp.l	#levelInstallers,nextLevelInstaller
	beq	.easy
	cmp.l	#levelInstallers+4,nextLevelInstaller
	beq	.medium		
.hard:
	lea	difficultyHard,a0
	lea	difficulty,a1
	bsr	StrCpy
	bra	.done
.medium:
	lea	difficultyMedium,a0
	lea	difficulty,a1
	bsr	StrCpy
	bra	.done	
.easy:
	lea	difficultyEasy,a0
	lea	difficulty,a1
	bsr	StrCpy
	bra	.done
.done:
	bsr	RenderMenu
	rts
	
ButtonPressed:
	cmp.l	#playTopColor,selectedPtr
	beq	.playButton
	cmp.l	#musicTopColor,selectedPtr
	beq	.musicButton
	cmp.l	#levelTopColor,selectedPtr
	beq	.difficultyButton
	cmp.l	#creditsTopColor,selectedPtr
	beq	.creditsButton		
	bra	.done
.difficultyButton:
	bsr	ToggleDifficulty
	bra	.done
.musicButton:
	bsr	ToggleMusic
	bra	.done
.creditsButton:
	jsr	Credits
	bra	ShowMenu
.done:
	bra	_ProcessJoystick	
.playButton:
	rts

WaitForButtonRelease:
.joystickPressed:
	jsr	WaitVerticalBlank
	jsr	PlayNextSound		
	jsr	ReadJoystick
	btst.b	#0,joystick
	bne	.joystickPressed
	rts

WaitForJoystickRelease:
	move.b	joystickpos,-(sp)
.wait:
	jsr	WaitVerticalBlank
	jsr	PlayNextSound		
	jsr	ReadJoystick
	move.b	(sp),d0
	cmp.b	joystickpos,d0
	beq	.wait
	move.b	(sp)+,d7
	rts
	
	
_ProcessJoystick:
	bsr	WaitForButtonRelease
.wait:
	jsr	ReadJoystick
	jsr	WaitVerticalBlank
	jsr	PlayNextSound		
	btst.b	#0,joystick
	bne	.pressed
	cmp.b	#1,joystickpos 	; up
	bne	.notUp
	bsr	MenuUp
	bsr	WaitForJoystickRelease
.notUp:
	cmp.b	#5,joystickpos 	; down
	bne	.notDown
	bsr	MenuDown
	bsr	WaitForJoystickRelease	
.notDown:
	bra	.wait
.pressed:
	bra	ButtonPressed
	rts

StrCpy:
	;; a0 - src
	;; a1 - dest
.loop:
	cmp.b	#0,(a0)
	beq	.done
	move.b	(a0)+,(a1)+
	bra	.loop
.done:
	rts

menu:
	dc.b	" PLAY NOW!  "
	dc.b	0
difficulty:
	dc.b	"LEVEL - EASY"
	dc.b	0
music:
	dc.b	"MUSIC - ON  "
	dc.b	0
credits:
	dc.b	"  CREDITS   "
	dc.b	0
	align	4


difficultyEasy:
	dc.b	"LEVEL - EASY"
	dc.b	0
	align	2
difficultyMedium:	
	dc.b	"LEVEL - MED "
	dc.b	0	
	align	2	
difficultyHard:
	dc.b	"LEVEL - HARD"
	dc.b	0	
	align	2	
musicOn:
	dc.b	"MUSIC - ON  "
	dc.b	0	
musicOff:
	dc.b	"MUSIC - OFF "
	dc.b	0	

	align 4
splashCopperList:
splashCopperListBplPtr:
	dc.w	BPL1PTL,0
	dc.w	BPL1PTH,0
	dc.w	BPL2PTL,0
	dc.w	BPL2PTH,0
	dc.w	BPL3PTL,0
	dc.w	BPL3PTH,0
	dc.w	BPL4PTL,0
	dc.w	BPL4PTH,0
	dc.w	BPL5PTL,0
	dc.w	BPL5PTH,0
	dc.w	BPL6PTL,0
	dc.w	BPL6PTH,0


	dc.w	PLAY_COPPER_WORD,$fffe
	dc.w	COLOR31
playTopColor:	
	dc.w	MENU_SELECTED_TOP_COLOR
	dc.w	PLAY_COPPER_WORD+(($1000/4)*3),$fffe
	dc.w	COLOR31
playBottomColor:	
	dc.w	MENU_SELECTED_BOTTOM_COLOR

	dc.w	PLAY_COPPER_WORD+$1000,$fffe
	dc.w	COLOR31
levelTopColor:	
	dc.w	MENU_TEXT_COLOR
	dc.w	PLAY_COPPER_WORD+$1000+(($1000/4)*3),$fffe
	dc.w	COLOR31,MENU_TEXT_BOTTOM_COLOR

	dc.w	PLAY_COPPER_WORD+$2000,$fffe
	dc.w	COLOR31
musicTopColor:
	dc.w	MENU_TEXT_COLOR
	dc.w	PLAY_COPPER_WORD+$2000+(($1000/4)*3),$fffe
	dc.w	COLOR31,MENU_TEXT_BOTTOM_COLOR

	dc.w	PLAY_COPPER_WORD+$3000,$fffe
	dc.w	COLOR31
creditsTopColor:
	dc.w	MENU_TEXT_COLOR
	dc.w	PLAY_COPPER_WORD+$3000+(($1000/4)*3),$fffe
	dc.w	COLOR31,MENU_TEXT_BOTTOM_COLOR		
	
	dc.l	$fffffffe		

selectedPtr:
	dc.l	playTopColor
splashSave:	
	incbin "out/splashSave.bin"
