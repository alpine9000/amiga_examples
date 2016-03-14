vertically scrolling the playfield
==================================

Vertically scrolling the playfield is the easiest thing to do on the amiga ;-)

Just offset the bitplane pointer addresses by the number of lines you want to scroll, and make sure you have enough bitplane data.

Set the scroll speed by changing ```SCROLL_SPEED``` in [constants.i](constants.i)

try it
------
  * [Download disk image](bin/vert_scroll.adf?raw=true)
  * <a href="http://alpine9000.github.io/ScriptedAmigaEmulator/#amiga_examples/vert_scroll.adf" target="_blank">Run in SAE</a>

