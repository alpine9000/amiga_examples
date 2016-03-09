interlaced playfield
====================

For interlace mode, we can enable it by simply setting the LACE bit in BPLCON0:

  ```
	move.w	#(SCREEN_BIT_DEPTH<<12)|COLOR_ON|HOMOD|LACE,BPLCON0(a6)
```

Now each alternating frame will be offset vertically by half a scan line.

So for this to work, we need to make some other changes.  Firstly we need twice the number of rows in our bitplane data.  Then on each alternating frame we need to set up the bitplane pointers such that they point at the correct set of row data. For this we set up two copper lists, then poke offset bitplane pointers into one of them:

   ```
	;; poke the bitplane pointers for the two copper lists.
	move.l	#SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH,d0
	lea 	copper(pc),a0
	bsr.s	pokeBitplanePointers
	
	moveq.l	#0,d0
	lea 	copperLOF(pc),a0
	bsr.s	pokeBitplanePointers	
```

Then, during the vertical blank, depending on the LOF bit in the VPOSR register, we install the correct copper list:

```
 .mainLoop:
	bsr 	waitVerticalBlank
	btst.w	#VPOSRLOFBIT,VPOSR(a6)
	beq.s	.lof
	lea	copper(pc),a0
	move.l	a0,COP1LC(a6)
	bra	.done
 .lof:
	lea	copperLOF(pc),a0
	move.l	a0,COP1LC(a6)
 .done
	bra	.mainLoop
```

This example allows your to enable/disable INTERLACE mode in the [Makefile](Makefile):
     ```
INTERLACE=1
```

try it
------
  * [Download disk image](bin/laced_mode.adf?raw=true)
  * <a href="http://alpine9000.github.io/ScriptedAmigaEmulator/#amiga_examples/laced_mode.adf" target="_blank">Run in SAE</a>
