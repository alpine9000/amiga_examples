perform a masked blit
=====================

Extending [006.simple_blit](../006.simple_blit), we now add a mask to the blit.

Using the "cookie-cut" blitter logic funtion we set up the blitter to use all four DMA channels.

[From the hardware manual](http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node011D.html):
> To draw the car, we might use the A  DMA channel  to fetch the car mask,
> the B  DMA channel  to fetch the actual car data, the C DMA channel to
> fetch the background, and the D DMA channel  to write out the new image.

  ```
A = mask
B = blitter object (sprite)
C = background
D = destination (background)
```

Now we calculate the [logic function minterm](http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node011C.html):

blitter logic function minterm truth table
------------------------------------------
We fill in the desired logic values in the D column. In this case D is set if:
   * The mask bit is set and the bob bit is set
   * The mask bit is not set and the background bit is set

|A(mask)|B(bob)|C(bg)| D(dest)|
|-------|------|-----|--------|
|0|0|0|0| 
|0|0|1|1|
|0|1|0|0|
|0|1|1|1|
|1|0|0|0|
|1|0|1|0|
|1|1|0|1|
|1|1|1|1|

Then we read D column from bottom up to give us the logic function minterm:
  ```
11001010 = $ca
```

This is then ready to be used in the LF1-7 bits of the [BLTCON0](http://amigadev.elowar.com/read/ADCD_2.1/Hardware_Manual_guide/node001A.html) register setup.

[imagecon](../tools/imagecon) generates the interleaved mask bitplanes for the A channel.

We then blit the sprite to the background and notice it now has a shape!

[Download disk image](bin/mask_blit.adf?raw=true)

Screenshot:

![Screenshot](screenshot.png?raw=true)
