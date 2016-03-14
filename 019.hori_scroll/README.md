horizontally scrolling the playfield
====================================

[Hardware reference link](http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0088.html)

Unfortunately, horizontal scrolling is slightly more involved compared to vertical scrolling.  Firstly, we can only scroll on word boundaries using the bitplane pointers, so we need to add a delay to allow for pixel scrolling. 

Firstly, we need to [modify the data fetch](http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0089.html) to start one word earlier (See [init.s](init.s)): 

 ```
  move.w  #(RASTER_X_START/2-SCREEN_RES)-8,DDFSTRT(a6)
```

Then we need to adjust the modulo to account for this. Also the modulo needs to also account for the new large bitmap size. We change the base screen width bytes symbole in [constants.i](constants.i) to allow for the new 2x wider bitplane:

 ```
  SCREEN_WIDTH_BYTES      equ (2*SCREEN_WIDTH/8)
 ```
 
We set the modulo with extra bytes for the extra width, and [two less counts](http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node008A.html) for the extra scrolling byte.
 
  ```
  move.w  #(SCREEN_WIDTH_BYTES*SCREEN_BIT_DEPTH-SCREEN_WIDTH_BYTES)+(SCREEN_WIDTH_BYTES/\
2)-2,BPL1MOD(a6)
```

Finally we set the delay for the pixel portion of the scroll in BPLCON1:

 ```
SetupHoriScrollBitDelay:
;; d0 = number of bits to scroll                                                       
    movem.l d0/d1,-(sp)
    move.w  d0,d1
    lsl.w   #4,d1
    or.w    d1,d0
    move.w   d 0,BPLCON1(a6)
    movem.l (sp)+,d0/d1
    rts
 ````


try it
------
  * [Download disk image](bin/hori_scroll.adf?raw=true)
  * <a href="http://alpine9000.github.io/ScriptedAmigaEmulator/#amiga_examples/hori_scroll.adf" target="_blank">Run in SAE</a>

