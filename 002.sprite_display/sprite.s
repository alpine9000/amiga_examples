	include ../include/registers.i
	include hardware/dmabits.i
	include hardware/intbits.i
	
LVL3_INT_VECTOR		equ $6c
	
entry:	
	lea	level3InterruptHandler(pc),a3
	move.l	a3,LVL3_INT_VECTOR
	;;
	;;  sprite_display.asm
	;;
	;;  This example displays the spaceship sprite at location V = 65,
	;;  H = 128. Remember to include the file hw_examples.i.
	;;
	;;  First, we set up a single bitplane.
	;;
	LEA     CUSTOM,a0 ;Point a0 at custom chips
	MOVE.W  #$1200,BPLCON0(a0) ;1 bitplane color is on
	MOVE.W  #$0000,BPL1MOD(a0) ;Modulo = 0
	MOVE.W  #$0000,BPLCON1(a0) ;Horizontal scroll value = 0
	MOVE.W  #$0024,BPLCON2(a0) ;Sprites have priority over playfields
	MOVE.W  #$0038,DDFSTRT(a0) ;Set data-fetch start
	MOVE.W  #$00D0,DDFSTOP(a0) ;Set data-fetch stop
	
	;;  Display window definitions.

	MOVE.W  #$2C81,DIWSTRT(a0) ;Set display window start
	;; Vertical start in high byte.
	;; Horizontal start * 2 in low byte.
	MOVE.W  #$F4C1,DIWSTOP(a0) ;Set display window stop
	;; Vertical stop in high byte.
	;; Horizontal stop * 2 in low byte.
	;;
	;;  Set up color registers.
	;;
	        MOVE.W  #$0008,COLOR00(a0) ;Background color = dark blue
	MOVE.W  #$0000,COLOR01(a0) ;Foreground color = black
	MOVE.W  #$0FF0,COLOR17(a0) ;Color 17 = yellow
	MOVE.W  #$00FF,COLOR18(a0) ;Color 18 = cyan
	MOVE.W  #$0F0F,COLOR19(a0) ;Color 19 = magenta
	;;
	;;  Move Copper list to $20000.
	;;
	MOVE.L  #$20000,a1 ;Point A1 at Copper list destination
	LEA     COPPERL(pc),a2 ;Point A2 at Copper list source
CLOOP:	
	MOVE.L  (a2),(a1)+ ;Move a long word
	CMP.L   #$FFFFFFFE,(a2)+ ;Check for end of list
	BNE     CLOOP		 ;Loop until entire list is moved
	;;
	;;  Move sprite to $25000.
	;;
	MOVE.L  #$25000,a1 ;Point A1 at sprite destination
	LEA     SPRITE(pc),a2 ;Point A2 at sprite source
SPRLOOP:	
	MOVE.L  (a2),(a1)+ ;Move a long word
	CMP.L   #$00000000,(a2)+ ;Check for end of sprite
	BNE     SPRLOOP		 ;Loop until entire sprite is moved
	;;
	;;  Now we write a dummy sprite to $30000, since all eight sprites are activated
	;;  at the same time and we're only going to use one.  The remaining sprites
	;;  will point to this dummy sprite data.
	;;
	MOVE.L  #$00000000,$30000 ;Write it
	;;
	;;  Point Copper at Copper list.
	;;
	MOVE.L  #$20000,COP1LC(a0)
	;;
	;;  Fill bitplane with $FFFFFFFF.
	;;
	MOVE.L  #$21000,a1 ;Point A1 at bitplane
	MOVE.W  #1999,d0   ;2000-1(for dbf) long words = 8000 bytes
FLOOP
	MOVE.L  #$FFFFFFFF,(a1)+ ;Move a long word of $FFFFFFFF
	DBF     d0,FLOOP	 ;Decrement, repeat until false.
	;;
	;;  Start DMA.
	;;
	MOVE.W  d0,COPJMP1(a0)	;Force load into Copper
	;;   program counter
	MOVE.W  #$83A0,DMACON(a0) ;Bitplane, Copper, and sprite DMA
.mainLoop:
	bra.s .mainLoop

level3InterruptHandler:
	movem.l	d0-a6,-(sp)

.checkVerticalBlank:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_VERTB,d0	
	beq.s	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; Clear interrupt bit	

.checkCopper:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_COPER,d0	
	beq.s	.interruptComplete
.copperInterrupt:
	move.w	#INTF_COPER,INTREQ(a5)	; Clear interrupt bit	
	
.interruptComplete:
	movem.l	(sp)+,d0-a6
	rte

	;;
	;;  This is a Copper list for one bitplane, and 8 sprites.
	;;  The bitplane lives at $21000.
	;;  Sprite 0 lives at $25000; all others live at $30000 (the dummy sprite).
	;;
COPPERL:
	        DC.W    BPL1PTH,$0002 ;Bitplane 1 pointer = $21000
	        DC.W    BPL1PTL,$1000
	        DC.W    SPR0PTH,$0002 ;Sprite 0 pointer = $25000
	        DC.W    SPR0PTL,$5000
	        DC.W    SPR1PTH,$0003 ;Sprite 1 pointer = $30000
	        DC.W    SPR1PTL,$0000
	        DC.W    SPR2PTH,$0003 ;Sprite 2 pointer = $30000
	        DC.W    SPR2PTL,$0000
	        DC.W    SPR3PTH,$0003 ;Sprite 3 pointer = $30000
	        DC.W    SPR3PTL,$0000
	        DC.W    SPR4PTH,$0003 ;Sprite 4 pointer = $30000
	        DC.W    SPR4PTL,$0000
	        DC.W    SPR5PTH,$0003 ;Sprite 5 pointer = $30000
	        DC.W    SPR5PTL,$0000
	        DC.W    SPR6PTH,$0003 ;Sprite 6 pointer = $30000
	        DC.W    SPR6PTL,$0000
	        DC.W    SPR7PTH,$0003 ;Sprite 7 pointer = $30000
	        DC.W    SPR7PTL,$0000
	        DC.W    $FFFF,$FFFE ;End of Copper list
	;;
	;;  Sprite data for spaceship sprite.  It appears on the screen at V=65 and H=128.
	;;
SPRITE:
	        DC.W    $6D60,$7200 ;VSTART, HSTART, VSTOP
	        DC.W    $0990,$07E0 ;First pair of descriptor words
	        DC.W    $13C8,$0FF0
	        DC.W    $23C4,$1FF8
	        DC.W    $13C8,$0FF0
	        DC.W    $0990,$07E0
	        DC.W    $0000,$0000 ;End of sprite data
	