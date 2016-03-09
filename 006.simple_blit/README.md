perform a basic blit
=====================

We make some changes to [001.simple_image](../001.simple_image):
   1. The bitplane pointers are now reset using the copper.
   2. The palette is now installed once and removed from the copper list.
   2. Interrupt processing is disabled.
   3. A6 is now used as the global base register for CUSTOM.

Next we use some new features in [imagecon](../tools/imagecon) that allow us to generate a shared palette based on two PNG images.

This means a sprite and background can share the single palette.

We then blit the sprite to the background.

screenshot
----------
![Screenshot](screenshot.png?raw=true)

try it
------
  * [Download disk image](bin/blit.adf?raw=true)
  * <a href="http://alpine9000.github.io/ScriptedAmigaEmulator/#amiga_examples/blit.adf" target="_blank">Run in SAE</a>

