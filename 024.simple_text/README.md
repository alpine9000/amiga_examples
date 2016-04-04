simple text
===========

In this example I try to render a bitmaped font using the blitter.  This is almost certainly not the optimal way to achieve the goal, so don't use this as an example of how to render text, it's more an example of how to use the blitter.

Firstly I created a simple bitmapped font file using dpaint:

![font](../assets/font8x8.png?raw=true)

Once again, this is not the optimal way to organise a font file. Just the way I did it :-)

The only complication is bliting an 8 bit font is that the blitter operates only on 16 bit words, so we must mask the correct 8 bits worth of character data.

```
        beq     .evenChar                               ;
.oddChar
        subq    #8,d5                                   ; offset the x position for the odd character
        move.w  #$00FF,BLTAFWM(a6)                      ; select the second (odd) character in the word
        subq    #1,a4                                   ; move the destination pointer left by one byte
        bra     .continue
.evenChar:
        move.w  #$FF00,BLTAFWM(a6)                      ; select the first character in the word
.continue:
```

We use the blitter shift register to allow pixel positioning of the text, so when we need to render the second character in a word, we offset the X position by 8 bits and also move the destination pointer.

There are two operating modes that can be configured in [constants.i](constants.i)

non masked mode
---------------

```
 MASKED_FONT             equ 0
```

In this mode, the font is blitted with the font file background included. This mode is interesting because we still use a cookie cut logic function ```$ca``` however instread of enabling the DMA A source channel, we pre-load the A data register with all 1s so that the A channel can be used to mask out 8 bits of the 16 bit blit.

```
   move.w  #$ffff,BLTADAT(a6) ;  ; preload source mask so only BLTA?WM mask is used
```

masked mode
-----------

```
 MASKED_FONT             equ 1
```

In this mode, the font is blitted using a cookie cut function so the font is blitted over the destination background. Ee use the A DMA channel as the mask and point it at a mask bitplane.  We still need to use the A channel first word mask for masking out the unwanted character as we blit a whole word:

This routine should be able to handle any number of bitplanes, althought it not run at 50 fps with more than 16 colors.

See the [Makefile](Makefile)

```
   NUM_COLORS=16
```

screenshot
----------

![Screenshot](screenshot.png?raw=true)


try it
------
  * [Download disk image](bin/simple_text.adf?raw=true)
  * <a href="http://alpine9000.github.io/ScriptedAmigaEmulator/#amiga_examples/simple_text.adf" target="_blank">Run in SAE</a>
