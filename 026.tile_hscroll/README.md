tile hscroll
============

In this example we used the [Tilled](http://www.mapeditor.org/) map editor to create a tile map.

Next we use a new utility I wrote [mapgen](../tools/mapgen) to convert the tiled map data into bitplane offsets that we then use to blit tiles just to the right of the visible screen.

Finally we scroll the screen using a combination of byte offsets for the bitplane data and hardware scroll delay for the sub-byte pixels.

Because we are constantly writing new tiles to the right of the visible area, we can just keep scrolling through the bitplane data until we need to loop back to the start.


screenshot
----------

![Screenshot](screenshot.png?raw=true)


try it
------
  * [Download disk image](bin/tile_hscroll.adf?raw=true)
  * <a href="http://alpine9000.github.io/ScriptedAmigaEmulator/#amiga_examples/tile_hscroll.adf" target="_blank">Run in SAE</a>
