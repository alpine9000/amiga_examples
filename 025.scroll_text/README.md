scroll text
===========

This example explores using the blitter to scroll text using it's shift function. Once again, this is probably not the best way to implement this outcome.

Basically, we blit a whole screen row (font height) in place using a left shift to scroll. Characters are rendered to the right of the visible region such that text smoothly scrolls onto the screen.

The first thing to note about shifting with the blitter is that if we want to left shift we need to use [descending mode](http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node0120.html).

Descending mode is pretty easy to set up:

```
Descending mode is turned on by setting bit one of  BLTCON1  (defined as
BLITREVERSE). If you use descending mode the address pointers will be
decremented by two (bytes) instead of incremented by two for each word
fetched.  In addition, the modulo values will be subtracted rather than
added.   Shifts  are then towards the left, rather than the right, the
first word  mask  masks the last word in a row (which is still the first
word fetched), and the last word  mask  masks the first word in a row.

Thus, for a standard memory copy, the only difference in blitter setup
(assuming no  shifting  or  masking ) is to initialize the
 address pointer registers  to point to the last word in a block, rather
than the first word.  The  modulo values ,  blit size , and all other
parameters should be set the same.

```

So we move all of the bitplane pointers to the last word:

```
  ;; a0 - dest bitplane pointer
  ;; a1 - source bitplane pointer
  ;; d1 - height in pixels
  ;; d2 - y destination in pixels
  add.l   d1,d2                   ; point to end of data for descending mode
  mulu.w  #BITPLANE_WIDTH_BYTES*SCREEN_BIT_DEPTH,d2
  add.l   d2,a0                   ; end of dest bitplane
  add.l   d2,a1                   ; end of source bitplane
```

then enable descending mode:

```
 swap    d0                      ; lsl.l #ASHIFTSHIFT,d0
 lsr.l   #4,d0                   ; d0 has ASHIFTSHIFT bits set
 ori.w   #BC1F_DESC,d0           ; BLTCON1 value. shift and descending mode
 move.w  d0,BLTCON1(a6)          ;
```

Now we can do a blit with left shift.

We use a simplified version of the text renderer used in the previous example to render a single character off screen, we then wait until that character has been fully shifted on screen and render the next one. The logic can be seen in [scroll_text.s)](scroll_text.s). Finally we throw in a copper list to make it look a little less boring.

screenshot
----------

![Screenshot](screenshot.png?raw=true)


try it
------
  * [Download disk image](bin/scroll_text.adf?raw=true)
  * <a href="http://alpine9000.github.io/ScriptedAmigaEmulator/#amiga_examples/scroll_text.adf" target="_blank">Run in SAE</a>
