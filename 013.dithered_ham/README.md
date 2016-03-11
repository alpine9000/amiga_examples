ditherered ham
==============

More changes to [imagecon](../tools/imagecon). This time I added simple [Floyd-Steinberg dithering](https://en.wikipedia.org/wiki/Floyd%E2%80%93Steinberg_dithering). You can see that while this improves the image, there are some problems somewhere in imagecon that increase the color intensity compared to the original source image.

I also added a very slow and hackish brute force palette computation that tries the find good HAM palette.

dithered
--------
![dithered](screenshots/dithered_new.png?raw=true)

no dither 
---------
![dithered](screenshots/ham.png?raw=true)

try it
------
  * [Download disk image](bin/dithered_ham.adf?raw=true)
  * <a href="http://alpine9000.github.io/ScriptedAmigaEmulator/#amiga_examples/dithered_ham.adf" target="_blank">Run in SAE</a>
