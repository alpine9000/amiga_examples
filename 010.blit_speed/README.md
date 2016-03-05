how fast are my blits?
======================

Blitting a 5 bitplane 64x64 rectangle with the cookie cut function (4 active DMA channels) probably isn't going to be very fast.

How fast is it ?

I added a feature to [imagecon](../tools/imagecon) to generate a greyscale version of the palette.

Then in the main loop I now:

* wait for the vertical blank
* set the greyscale palette
* do 4 blits
* set the color palette


  ```
.mainLoop:
        bsr 	waitVerticalBlank
        bsr     installGreyscalePalette
        move.l	#4,d0 ; blit the object 4 times each frame
.blitLoop:
        bsr	moveBlitterObject
        dbra	d0,.blitLoop
        bsr.s	installColorPalette
        bra.s	.mainLoop
```

So when the screen changes to color, that's how many scan lines we have used blitting stuff.

The `NUM_COLORS` variable in the [Makefile](Makefile) sets the number of colors. This automatically creates the correct bitplane and palette data as well as reconfiguring the example code. So now we can see what impact the number of bitplanes has on blit speed:

5 bitplanes
-----------
![5 bitplanes](5bitplanes-screenshot.png?raw=true)

At 5 bitplanes we don't have enough time to do 5 blits.

4 bitplanes
-----------
![4 bitplanes](4bitplanes-screenshot.png?raw=true)

3 bitplanes
-----------
![3 bitplanes](3bitplanes-screenshot.png?raw=true)

2 bitplanes
-----------
![5 bitplanes](2bitplanes-screenshot.png?raw=true)

1 bitplanes
-----------
![5 bitplanes](1bitplanes-screenshot.png?raw=true)

Lots of time left over with 1 bitplane :-D

[Download disk image](bin/blit_speed.adf?raw=true)


