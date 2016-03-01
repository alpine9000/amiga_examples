Display a simple image
======================

Building on [trackdisk.device](../000.trackdisk), we now display a simple color image.

I display a 5 bitplane (32 color) low res image.

The image data is prepared using a new tool I wrote called [imagecon](../tools/imagecon/imagecon.c). This takes (almost) any 320x256 PNG and using [libimagequant](https://pngquant.org/lib/) it reduces the palette to 32 colors, then dumps out the copper list and interleaved bitplane data ready to be included into [image.s](image.s).

The original version of this example used [vilcans amiga-startup](https://github.com/vilcans/amiga-startup) as a starting point, however almost all of that code has been replaced as my understanding exanded.
