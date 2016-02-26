	include registers.i
	include hardware/dmabits.i
	include hardware/intbits.i
	
LEVEL_3_INTERRUPT_VECTOR equ $6c
	
entry:	
	lea	level3InterruptHandler(pc),a3
	move.l	a3,LEVEL_3_INTERRUPT_VECTOR

	lea 	CUSTOM,a1
	lea	copper1(pc),a0
	move.l	a0,cop1lc(a1)
	move.w  COPJMP1(a1),d0
	move.w  #(DMAF_SETCLR!DMAF_COPPER!DMAF_RASTER!DMAF_MASTER),dmacon(a1)
	
.mainLoop:
	bra.b	.mainLoop

level3InterruptHandler:
	movem.l	d0-a6,-(sp)

.checkVerticalBlank:
	lea	CUSTOM,a5
	move.w	INTREQR(a5),d0
	and.w	#INTF_VERTB,d0	
	beq.s	.checkCopper

.verticalBlank:
	move.w	#INTF_VERTB,INTREQ(a5)	; Clear interrupt bit	
	lea.l	CUSTOM,a5
	lea.l	counter(pc),a3
	move.l	(a3),d1
	cmpi.l  #1,d1
	beq.s   .installCopper2
.installCopper1:
	lea	copper1(pc),a0
	addi.l 	#1,d1
	bra.s   .loadCopper
.installCopper2:
	lea	copper2(pc),a0
	move.l	#0,d1
.loadCopper:
	move.l	a0,COP1LC(a5)
	move.l d1,(a3)
	
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

counter:
	dc.l	0
	
copper1:
	;;
	;;   Set up pointers to two bitplanes
	;;
	        DC.W    BPL1PTH,$0002 ;Move $0002 into register $0E0 (BPL1PTH)
	        DC.W    BPL1PTL,$1000 ;Move $1000 into register $0E2 (BPL1PTL)
	        DC.W    BPL2PTH,$0002 ;Move $0002 into register $0E4 (BPL2PTH)
	        DC.W    BPL2PTL,$5000 ;Move $5000 into register $0E6 (BPL2PTL)
	;;
	;;   Load color registers
	;;
	        DC.W    COLOR00,$0FFF ;Move white into register $180 (COLOR00)
	        DC.W    COLOR01,$0F00 ;Move red into register   $182 (COLOR01)
	        DC.W    COLOR02,$00F0 ;Move green into register $184 (COLOR02)
	        DC.W    COLOR03,$000F ;Move blue into register  $186 (COLOR03)
	;;
	;;    Specify 2 Lores bitplanes
	;;
	        DC.W    BPLCON0,$2200 ;2 lores planes, coloron
	;;
	;;   Wait for line 150
	;;
	        DC.W    $9601,$FF00 ;Wait for line 150, ignore horiz. position
	;;
	;;   Change color registers mid-display
	;;
	        DC.W    COLOR00,$0000 ;Move black into register $0180 (COLOR00)
	        DC.W    COLOR01,$0FF0 ;Move yellow into register $0182 (COLOR01)
	        DC.W    COLOR02,$00FF ;Move cyan into register $0184 (COLOR02)
	        DC.W    COLOR03,$0F0F ;Move magenta into register $0186 (COLOR03)
	;;
	;;  End Copper list by waiting for the impossible
	;;
	        DC.W    $FFFF,$FFFE ;Wait for line 255, H = 254 (never happens)


copper2:	
	;;
	;;   Set up pointers to two bitplanes
	;;
	        DC.W    BPL1PTH,$0002 ;Move $0002 into register $0E0 (BPL1PTH)
	        DC.W    BPL1PTL,$1000 ;Move $1000 into register $0E2 (BPL1PTL)
	        DC.W    BPL2PTH,$0002 ;Move $0002 into register $0E4 (BPL2PTH)
	        DC.W    BPL2PTL,$5000 ;Move $5000 into register $0E6 (BPL2PTL)
	;;
	;;   Load color registers
	;;
	        DC.W    COLOR00,$0F00 ;Move red imto register   $180 (COLOR00)
	        DC.W    COLOR01,$0FFF ;Move white into register $182 (COLOR01)
	        DC.W    COLOR02,$00F0 ;Move green into register $184 (COLOR02)
	        DC.W    COLOR03,$000F ;Move blue into register  $186 (COLOR03)
	;;
	;;    Specify 2 Lores bitplanes
	;;
	        DC.W    BPLCON0,$2200 ;2 lores planes, coloron
	;;
	;;  End Copper list by waiting for the impossible
	;;
	        DC.W    $FFFF,$FFFE ;Wait for line 255, H = 254 (never happens)